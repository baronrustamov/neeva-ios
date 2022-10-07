// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared
import XCGLogger

private let log = Logger.browser

enum ClientLoggerStatus {
    case enabled
    case disabled
}

struct DebugLog: Hashable {
    struct Attribute: Hashable, Identifiable {
        let id = UUID()

        let key: String
        let value: String?
    }

    let path: String
    let attributes: [Attribute]

    init(_ path: LogConfig.Interaction, attributes: [ClientLogCounterAttribute] = []) {
        self.init(pathString: path.rawValue, attributes: attributes)
    }

    init(pathString: String, attributes: [ClientLogCounterAttribute] = []) {
        self.path = pathString
        self.attributes = attributes.map { item -> Attribute in
            let key = item.key?.underlying ?? "nil"
            let value = item.value?.underlying

            return Attribute(key: key, value: value)
        }
    }

    var attributeStr: String {
        attributes
            .map { attribute in
                "\(attribute.key) : \(attribute.value ?? "")"
            }
            .joined(separator: ",")
    }
}

class ClientLogger {
    var env: ClientLogEnvironment
    private let status: ClientLoggerStatus

    static let shared = ClientLogger()
    @Published var debugLoggerHistory = [DebugLog]()

    var loggingQueue = [ClientLog]()

    init() {
        self.env = ClientLogEnvironment.init(rawValue: "Prod")!
        // disable client logging until we have a plan for privacy control
        self.status = .enabled
    }

    // MARK: - Public Methods
    func logCounter(
        _ path: LogConfig.Interaction, attributes: [ClientLogCounterAttribute] = []
    ) {
        self.logCounter(path, attributes: attributes, enforceIncognito: true)
    }

    // TODO: - Document usage
    /// Register a logging event without performing incognito checks
    ///
    /// This method is only intended to be used with payloads that had already been scanned for incognito
    /// For example, on such payload is aggregated statistics from an app session, where the statistics collected also
    /// do not collect incognito usage.
    /// - Warning: This method does not verify if BVC is in incognito beforing transmitting the logs. Please read documentation on its intended usage
    func logCounterBypassIncognito(
        _ path: LogConfig.Interaction, attributes: [ClientLogCounterAttribute] = []
    ) {
        self.logCounter(path, attributes: attributes, enforceIncognito: false)
    }

    func flushLoggingQueue() {
        for clientLog in loggingQueue {
            performLogMutation(clientLog)
        }
        loggingQueue.removeAll()
    }

    // MARK: - Private Methods
    private func logCounter(
        _ path: LogConfig.Interaction,
        attributes: [ClientLogCounterAttribute],
        enforceIncognito: Bool
    ) {
        guard self.status == ClientLoggerStatus.enabled else {
            return
        }

        // If it is performance logging, it is okay because no identity info is logged
        // If there is no tabs, assume that logging is OK for allowed actions
        if enforceIncognito,
            LogConfig.category(for: path) != .Stability
                && SceneDelegate.getBVCOrNil()?.incognitoModel.isIncognito ?? true
        {
            return
        }

        guard LogConfig.featureFlagEnabled(for: LogConfig.category(for: path)) else {
            return
        }

        var loggingAttributes = attributes
        if LogConfig.shouldAddSessionID(for: path) {
            loggingAttributes.append(
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.SessionUUIDv2,
                    value: Defaults[.sessionUUIDv2]
                )
            )
        }

        let clientLogCounter = ClientLogCounter(path: path.rawValue, attributes: loggingAttributes)
        let clientLog = ClientLog(counter: clientLogCounter)

        #if DEBUG
            if !Defaults[.forceProdGraphQLLogger] {
                debugLoggerHistory.insert(
                    DebugLog(
                        path,
                        attributes: loggingAttributes
                    ),
                    at: 0
                )
                return
            }
        #endif

        if let shouldCollectUsageStats = Defaults[.shouldCollectUsageStats] {
            if shouldCollectUsageStats {
                performLogMutation(clientLog)
            }
        } else {
            // Queue up events in the case user hasn't decided to opt in usage collection
            loggingQueue.append(clientLog)
        }
    }

    private func performLogMutation(_ clientLog: ClientLog) {
        if Defaults[.shouldCollectUsageStats] ?? false {
            let clientLogBase = ClientLogBase(
                id: "co.neeva.app.ios.browser",
                version: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
                    as! String, environment: self.env)

            GraphQLAPI.shared.perform(
                mutation: LogMutation(
                    input: ClientLogInput(
                        base: clientLogBase,
                        log: [clientLog]
                    )
                )
            ) { result in
                switch result {
                case .failure(let error):
                    print("LogMutation Error: \(error)")
                case .success:
                    if let counter = clientLog.counter,
                        let path = counter?.path
                    {
                        log.info("logging sent for counter_path: \(path)")
                    }
                }
            }
        }
    }
}
