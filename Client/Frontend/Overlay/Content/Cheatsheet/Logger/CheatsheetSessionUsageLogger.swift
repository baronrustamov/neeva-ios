// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared

// MARK: - CheatsheetAttribute
protocol CheatsheetAttribute {
    associatedtype Value: Codable

    /// String used as key in ClientLoggerAttribute and UserDefaults
    var name: String { get }
    /// Default value if no logs were recorded during the app lifecycle
    var defaultValue: Value { get }
}

enum CheatsheetIntAttribute: String, CaseIterable {
    case numOfUGCTests
    case numOfUGCCanonicalError
    case numOfUGCNoResult
    case numOfUGCHits
    case numOfUGCClears
}

extension CheatsheetIntAttribute: CheatsheetAttribute {
    var name: String { self.rawValue }
    var defaultValue: Int { 0 }
}

enum CheatsheetStringAttribute: String, CaseIterable {
    case redditFilterHealth
}

extension CheatsheetStringAttribute: CheatsheetAttribute {
    var name: String { self.rawValue }
    var defaultValue: String { "" }
}

enum CheatsheetAttributeGroupKey {
    case intAttributes
    case stringAttributes
}

private class CheatsheetAttributeStorage {
    // MARK: - Private Properties
    private var incrementCounters: [CheatsheetIntAttribute: Int]
    private var stringCounters: [CheatsheetStringAttribute: String]
    // Queue used to synchronize in memory counter updates
    private let updateQueue = DispatchQueue(
        label: bundleID + ".CheatsheetAttributeStorage.updateQueue",
        qos: .utility
    )

    // MARK: - Static Properties
    static var bundleID: String {
        Bundle.main.bundleIdentifier!
    }

    init() {
        let incrementCounters = Dictionary(
            uniqueKeysWithValues: CheatsheetIntAttribute.allCases.map { attribute in
                return (
                    attribute,
                    attribute.defaultValue
                )
            }
        )
        let stringCounters = Dictionary(
            uniqueKeysWithValues: CheatsheetStringAttribute.allCases.map { attribute in
                return (
                    attribute,
                    attribute.defaultValue
                )
            }
        )

        self.incrementCounters = incrementCounters
        self.stringCounters = stringCounters
    }

    /// Increment the attributes
    ///
    /// Setter is called asynchronously and schedules mutating the in memory values to be done on `updateQueue`
    ///
    /// - Parameters:
    ///     - attributes: Increment the attributes in the array each by one. Supplying multiple values of the same attribute into the array will result in the value being incremented multiple times
    ///     - completionHandler: Supply a completion handler to receive a copy of the attributes after mutation. This is an escaping completion handler
    func increment(
        _ attributes: [CheatsheetIntAttribute],
        completionHandler: (([CheatsheetIntAttribute: Int]) -> Void)?
    ) {
        self.updateQueue.async { [self] in
            for attribute in attributes {
                self.incrementCounters[attribute, default: attribute.defaultValue] += 1
            }

            completionHandler?(self.incrementCounters)
        }
    }

    /// Set the string attributes
    ///
    /// Setter is called asynchronously and schedules mutating the in memory values to be done on `updateQueue`
    ///
    /// - Parameters:
    ///     - values: Set the string attribtues to these values
    ///     - completionHandler: Supply a completion handler to receive a copy of the attributes after mutation. This is an escaping completion handler
    func setStrings(
        to values: [CheatsheetStringAttribute: String],
        completionHandler: (([CheatsheetStringAttribute: String]) -> Void)?
    ) {
        self.updateQueue.async { [self] in
            for (attribute, value) in values {
                print(value)
                self.stringCounters[attribute] = value
            }

            completionHandler?(self.stringCounters)
        }
    }

    /// Get a copy of the value in memory asynchronously. This waits for all currently scheduled mutations to finish
    func getValues(completionHandler: @escaping ([CheatsheetAttributeGroupKey: Any]) -> Void) {
        self.updateQueue.async {
            completionHandler(
                [
                    .intAttributes: self.incrementCounters as Any,
                    .stringAttributes: self.stringCounters as Any,
                ]
            )
        }
    }

    /// Get a copy of the value in memory synchronously. This waits for all currently scheduled mutations to finish
    ///
    /// This function must not be called from `updateQueue`
    func getAwaitedValues() -> [CheatsheetAttributeGroupKey: Any] {
        dispatchPrecondition(condition: .notOnQueue(self.updateQueue))
        return self.updateQueue.sync {
            return [
                .intAttributes: self.incrementCounters as Any,
                .stringAttributes: self.stringCounters as Any,
            ]
        }
    }

    /// Get a copy of the value in memory asynchronously. This waits for all currently scheduled mutations to finish
    @available(iOS 15, *)
    func getValues() async -> [CheatsheetAttributeGroupKey: Any] {
        return await withCheckedContinuation { continuation in
            self.updateQueue.async {
                continuation.resume(
                    returning: [
                        .intAttributes: self.incrementCounters as Any,
                        .stringAttributes: self.stringCounters as Any,
                    ]
                )
            }
        }
    }
}

// MARK: - CheatsheetLogger
class CheatsheetSessionUsageLogger {
    // MARK: - Private Properties
    private let clientLogger: ClientLogger
    private let defaults: UserDefaults

    // Prevent disk copy from being mutated until logs from previous session has been sent
    private var isSafeToOverride: Bool = false
    private let inMemoryStorage: CheatsheetAttributeStorage

    private var observer: NSObjectProtocol!

    // MARK: - Static Properties
    static let shared = CheatsheetSessionUsageLogger(clientLogger: .shared, defaults: .standard)

    // MARK: - Init
    init(clientLogger: ClientLogger, defaults: UserDefaults) {
        self.clientLogger = clientLogger
        self.defaults = defaults

        self.inMemoryStorage = CheatsheetAttributeStorage()

        self.observer = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.appMovedToBackground()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self.observer as Any)
    }

    // MARK: - Public Methods
    /// Read value from persistent storage to log aggregated states and unblock writing to persistent storage
    ///
    /// Because ``makeLoggerAttributes`` is not safe from concurrent updates to UserDefaults, this function reads values
    /// to make the logging call first, and then it clears the persistent copy and sets `isSafeToOverride` to allow
    /// recording values from this session
    func sendLogsOnAppStarted() {
        clientLogger.logCounterBypassIncognito(
            .CheatsheetUGCStatsForSession,
            attributes: EnvironmentHelper.shared.getAttributes() + self.makeLoggerAttributes()
        )

        resetPersistentStorage()

        isSafeToOverride = true
    }

    /// Increment the attributes in the array each by one
    /// Supplying multiple values of the same attribute into the array will result in the value being incremented multiple times
    ///
    /// Setter is called asynchronously
    /// If the values contain crucial infromation that must be logged, it will acquire a copy of the in memory string values
    /// and submit a task on main to update the persistent copy in `UserDefaults`
    func increment(_ attributes: [CheatsheetIntAttribute]) {
        var completionHandler: (([CheatsheetIntAttribute: Int]) -> Void)? = .none
        if attributes.contains(.numOfUGCClears) {
            completionHandler = { copy in
                DispatchQueue.main.async { [self] in
                    self.writeToPersistentStorage(incrementCounters: copy, stringCounters: [:])
                }
            }
        }

        self.inMemoryStorage.increment(attributes, completionHandler: completionHandler)
    }

    /// Set the string attributes
    ///
    /// Setter is called asynchronously and schedules mutating the in memory values to be done on `updateQueue`
    /// If the values contain crucial infromation that must be logged, it will acquire a copy of the in memory string values
    /// and submit a task on main to update the persistent copy in `UserDefaults`
    func setStrings(to values: [CheatsheetStringAttribute: String]) {
        var completionHandler: (([CheatsheetStringAttribute: String]) -> Void)? = .none
        if values[.redditFilterHealth] != nil {
            completionHandler = { copy in
                DispatchQueue.main.async { [self] in
                    self.writeToPersistentStorage(incrementCounters: [:], stringCounters: copy)
                }
            }
        }

        self.inMemoryStorage.setStrings(to: values, completionHandler: completionHandler)
    }

    // MARK: - Private Methods
    /// Write current in memory values to user defaults when app is backgrounded
    ///
    /// The notification is received on `main` to ensure that we call ``writeToPersistentStorage`` on main
    /// This method should also synchronously complete writing values to avoid process being terminated too quickly
    private func appMovedToBackground() {
        let copy = self.inMemoryStorage.getAwaitedValues()
        writeToPersistentStorage(
            incrementCounters: copy[.intAttributes] as! [CheatsheetIntAttribute: Int],
            stringCounters: copy[.stringAttributes] as! [CheatsheetStringAttribute: String]
        )
    }

    /// Read from UserDefaults to make client counters
    ///
    /// Individual values are guaranteed to be thread safe by relying on UserDefault's thread safety promise
    /// However, the suite of values may not be thread safe since consequtive calls to UserDefaults are not atomic
    private func makeLoggerAttributes() -> [ClientLogCounterAttribute] {
        var attributes: [ClientLogCounterAttribute] = [
            ClientLogCounterAttribute(
                key: LogConfig.CheatsheetAttribute.UGCStat.isEnabled.rawValue,
                value: String(Defaults[.useCheatsheetBloomFilters])
            )
        ]

        attributes.append(
            contentsOf: CheatsheetIntAttribute.allCases.map {
                return ClientLogCounterAttribute(
                    key: $0.name,
                    value: String(readValueFromPresistentStorage(for: $0) ?? $0.defaultValue)
                )
            }
        )

        attributes.append(
            contentsOf: CheatsheetStringAttribute.allCases.map {
                return ClientLogCounterAttribute(
                    key: $0.name,
                    value: readValueFromPresistentStorage(for: $0) ?? $0.defaultValue
                )
            }
        )

        return attributes
    }

    /// Read stored values from UserDefaults and return nil if not found
    ///
    /// This method relies on the inherent thread safety promise from UserDefaults
    private func readValueFromPresistentStorage(for attribute: CheatsheetIntAttribute) -> Int? {
        // UserDefaults.interger(forKey:) return 0 if key is not found.
        return self.defaults.object(forKey: attribute.name) as? Int
    }

    /// Read stored values from UserDefaults and return nil if not found
    ///
    /// This method relies on the inherent thread safety promise from UserDefaults
    private func readValueFromPresistentStorage(
        for attribute: CheatsheetStringAttribute
    ) -> String? {
        return self.defaults.string(forKey: attribute.name)
    }

    /// Write supplied values to UserDefaults
    ///
    /// Writing to UserDefaults must be done on main to avoid crash triggered by KVO in Defaults library
    /// if empty dictionaries are supplied, no value is written. To clear values, use ``resetPersistentStorage``
    ///
    /// To prevent ``makeLoggerAttributes`` from reading unsafe values, this function is also guarded by `isSafeToOverride`
    private func writeToPersistentStorage(
        incrementCounters: [CheatsheetIntAttribute: Int],
        stringCounters: [CheatsheetStringAttribute: String]
    ) {
        assert(Thread.isMainThread)

        guard isSafeToOverride else {
            return
        }

        // Write int values
        for (attribute, value) in incrementCounters {
            self.defaults.set(value, forKey: attribute.name)
        }
        // Write string values
        for (attribute, value) in stringCounters {
            self.defaults.set(value, forKey: attribute.name)
        }
    }

    /// Clear values stored in UserDefaults
    ///
    /// Writing to UserDefaults must be done on main to avoid crash triggered by KVO in Defaults library
    private func resetPersistentStorage() {
        assert(Thread.isMainThread)

        CheatsheetIntAttribute.allCases.forEach { attribute in
            self.defaults.removeObject(forKey: attribute.name)
        }

        CheatsheetStringAttribute.allCases.forEach { attribute in
            self.defaults.removeObject(forKey: attribute.name)
        }
    }
}
