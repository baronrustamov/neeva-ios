// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared

private let log = Logger.browser

enum InteractionLoggerStatus {
    case enabled
    case disabled
}

public class InteractionLogger {
    public var env: ClientLogEnvironment
    private let status: InteractionLoggerStatus
    public static let shared = InteractionLogger()

    public init() {
        self.env = ClientLogEnvironment.init(rawValue: "Prod")!
        self.status = .enabled
    }

    public func logInteraction(
        requestEventID: String, actionType: InteractionV3Type,
        category: InteractionV3Category? = nil, element: String? = nil, elementAction: String? = nil
    ) {
        if self.status != InteractionLoggerStatus.enabled || requestEventID.isEmpty {
            return
        }

        let logBase = ClientLogBase(
            id: "co.neeva.app.ios.browser",
            version: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
                as! String, environment: self.env)

        let interactionActionInput = InteractionV3ActionInput(
            actionType: actionType, category: category, element: element,
            elementAction: elementAction)
        let interactionEvent = InteractionV3EventInput(
            loggingContexts: nil, action: interactionActionInput, requestEventId: requestEventID)
        let clientLog = ClientLog(interactionV3Event: interactionEvent)

        let mutation = LogMutation(
            input: ClientLogInput(
                base: logBase,
                log: [clientLog]
            )
        )
        GraphQLAPI.shared.perform(mutation: mutation) { result in
            switch result {
            case .failure(let error):
                log.info("Error sending interaction log: \(error)")
            case .success:
                break
            }
        }
    }
}
