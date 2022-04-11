// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Apollo
import Defaults
import Foundation
import Shared

enum ClientLoggerStatus {
    case enabled
    case disabled
}

public struct DebugLog: Hashable {
    let pathStr: String
    let attributeStr: String
}

public class ClientLogger {
    public var env: ClientLogEnvironment
    private let status: ClientLoggerStatus

    public static let shared = ClientLogger()
    @Published public var debugLoggerHistory = [DebugLog]()

    public init() {
        self.env = ClientLogEnvironment.init(rawValue: "Prod")!
        // disable client logging until we have a plan for privacy control
        self.status = .enabled
    }

    public func logCounter(
        _ path: LogConfig.Interaction, attributes: [ClientLogCounterAttribute] = []
    ) {
        if self.status != ClientLoggerStatus.enabled {
            return
        }

        // If it is performance logging, it is okay because no identity info is logged
        // If there is no tabs, assume that logging is OK for allowed actions
        if LogConfig.category(for: path) != .Stability
            && SceneDelegate.getBVCOrNil()?.incognitoModel.isIncognito ?? true
        {
            return
        }

        if !LogConfig.featureFlagEnabled(for: LogConfig.category(for: path)) {
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

        let clientLogBase = ClientLogBase(
            id: NeevaConstants.currentTarget == .xyz
                ? "xyz.neeva.app.ios.browser" : "co.neeva.app.ios.browser",
            version: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
                as! String, environment: self.env)
        let clientLogCounter = ClientLogCounter(path: path.rawValue, attributes: loggingAttributes)
        let clientLog = ClientLog(counter: clientLogCounter)

        #if DEBUG
            if !Defaults[.forceProdGraphQLLogger] {
                let attributes = loggingAttributes.compactMap {
                    "\(String(describing: $0.key)): \(String(describing: $0.value))"
                }
                let path = path.rawValue
                debugLoggerHistory.insert(
                    DebugLog(
                        pathStr: path,
                        attributeStr: attributes.joined(separator: ",")
                    ),
                    at: 0
                )
                return
            }
        #endif

        LogMutation(
            input: ClientLogInput(
                base: clientLogBase,
                log: [clientLog]
            )
        ).perform { result in
            switch result {
            case .failure(let error):
                print("LogMutation Error: \(error)")
            case .success:
                break
            }
        }

    }
}
