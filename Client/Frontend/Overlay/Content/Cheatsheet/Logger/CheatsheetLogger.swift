// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

// MARK: - CheatsheetLogger
class CheatsheetLogger {
    // MARK: - Private Properties
    private let clientLogger: ClientLogger
    private let defaults: UserDefaults

    // Prevent disk copy from being mutated until logs from previous session has been sent
    private var isSafeToOverride: Bool = false

    private var incrementCounters: [CheatsheetIntAttribute: Int]
    private var stringCounters: [CheatsheetStringAttribute: String]
    // Queue used to synchronize in memory counter updates
    private let updateQueue = DispatchQueue(
        label: bundleID + ".CheatsheetLogger.updateQueue",
        qos: .utility
    )

    // MARK: - Static Properties
    static let shared = CheatsheetLogger(clientLogger: .shared, defaults: .standard)
    static var bundleID: String {
        Bundle.main.bundleIdentifier ?? "co.neeva.app.ios.browser"
    }

    // MARK: - Init
    init(clientLogger: ClientLogger, defaults: UserDefaults) {
        self.clientLogger = clientLogger
        self.defaults = defaults

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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovedToBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    // MARK: - Public Methods
    func sendLogsOnAppStarted() {
        clientLogger.logCounter(
            .CheatsheetUGCStatsForSession,
            attributes: EnvironmentHelper.shared.getAttributes() + self.makeLoggerAttributes()
        )

        resetPersistentStorage()

        isSafeToOverride = true
    }

    /// Increment the attributes in the array each by one
    /// Incrementing is done asynchronously.
    /// Supplying multiple values of the same attribute into the array will result in the value
    /// being incremented multiple times
    func increment(_ attributes: [CheatsheetIntAttribute]) {
        self.updateQueue.async { [self] in
            for attribute in attributes {
                self.incrementCounters[attribute, default: attribute.defaultValue] += 1
            }

            // Write crucial logs straight away
            if attributes.contains(.numOfUGCClears) {
                self.writeToPersistentStorage()
            }
        }
    }

    /// Set the string attributes
    ///
    /// Setter is called asynchronously
    func setStrings(to values: [CheatsheetStringAttribute: String]) {
        self.updateQueue.async { [self] in
            for (attribute, value) in values {
                print(value)
                self.stringCounters[attribute] = value
            }

            // Write crucial logs straight away
            if values[.redditFilterHealth] != nil {
                self.writeToPersistentStorage()
            }
        }
    }

    // MARK: - Private Methods
    @objc
    private func appMovedToBackground() {
        writeToPersistentStorage()
    }

    /// Read from file storage to make client counters
    private func makeLoggerAttributes() -> [ClientLogCounterAttribute] {
        var attributes = [ClientLogCounterAttribute]()

        attributes.append(
            contentsOf: self.incrementCounters.keys.map {
                return ClientLogCounterAttribute(
                    key: $0.name,
                    value: String(readValueFromPresistentStorage(for: $0) ?? $0.defaultValue)
                )
            }
        )

        attributes.append(
            contentsOf: self.stringCounters.keys.map {
                return ClientLogCounterAttribute(
                    key: $0.name,
                    value: readValueFromPresistentStorage(for: $0) ?? $0.defaultValue
                )
            }
        )

        return attributes
    }

    private func readValueFromPresistentStorage(for attribute: CheatsheetIntAttribute) -> Int? {
        // UserDefaults.interger(forKey:) return 0 if key is not found.
        return self.defaults.object(forKey: attribute.name) as? Int
    }

    private func readValueFromPresistentStorage(
        for attribute: CheatsheetStringAttribute
    ) -> String? {
        return self.defaults.string(forKey: attribute.name)
    }

    /// Write in memory values to UserDefaults
    private func writeToPersistentStorage() {
        guard isSafeToOverride else {
            return
        }

        // Write int values
        for (attribute, value) in self.incrementCounters {
            self.defaults.set(value, forKey: attribute.name)
        }
        // Write string values
        for (attribute, value) in self.stringCounters {
            self.defaults.set(value, forKey: attribute.name)
        }
    }

    /// Clear values stored in UserDefaults
    private func resetPersistentStorage() {
        self.incrementCounters.keys.forEach { attribute in
            self.defaults.removeObject(forKey: attribute.name)
        }

        self.stringCounters.keys.forEach { attribute in
            self.defaults.removeObject(forKey: attribute.name)
        }
    }
}
