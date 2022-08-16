// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AdServices
import Defaults
import Foundation
import Shared
import StoreKit

private enum AttributionTokenErrorType: String {
    case olderIOSRequest
    case requestError
    case emptyToken
}

/// Reports conversion events to SKAdNetwork. Avoids reporting the same event
/// more than once, so it is safe to call `log(event:)` multiple times for the
/// same event.
class ConversionLogger {
    enum Event: Int {
        case launchedApp = 0
        case visitedDefaultBrowserSettings = 10
        case handledNavigationAsDefaultBrowser = 20
    }

    static var shouldRetryRequestAfterFailure = true

    static func log(event: Event) {
        guard event.rawValue > Defaults[.lastReportedConversionEvent] else {
            return
        }
        Defaults[.lastReportedConversionEvent] = event.rawValue
        if event.rawValue == 0 {
            SKAdNetwork.registerAppForAdNetworkAttribution()
            #if !targetEnvironment(simulator)
                logAttributionToken()
            #endif
        } else {
            SKAdNetwork.updateConversionValue(event.rawValue)
        }
    }

    private static func logAttributionToken() {
        if #available(iOS 14.3, *) {
            if let token = try? AAAttribution.attributionToken() {
                var neevaTokenRequest = URLRequest(url: NeevaConstants.neevaTokenApiURL)
                neevaTokenRequest.httpMethod = "POST"
                let encodedToken = token.replacingOccurrences(of: "+", with: "%2B")
                let neevaTokenData =
                    "sessionUUID=\(Defaults[.sessionUUIDv2])&aaaToken=\(encodedToken)"
                neevaTokenRequest.httpBody = Data(neevaTokenData.utf8)
                neevaTokenRequest.setValue(
                    "application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

                URLSession.shared.dataTask(with: neevaTokenRequest) { _, response, error in
                    guard error == nil else {
                        logNeevaRequestError(token: token, errorType: .requestError)
                        return
                    }
                    if let response = response, let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode != 200 {
                            logNeevaRequestError(token: token, errorType: .requestError)
                        }
                    }
                }.resume()
            } else {
                logNeevaRequestError(token: nil, errorType: .emptyToken)
            }
        } else {
            logNeevaRequestError(token: nil, errorType: .olderIOSRequest)
        }
    }

    // This logger function is called from a background thread
    private static func logNeevaRequestError(
        token: String?,
        errorType: AttributionTokenErrorType
    ) {
        DispatchQueue.main.async {
            var attributes = EnvironmentHelper.shared.getFirstRunAttributes()
            attributes.append(
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.AttributionTokenErrorType,
                    value: errorType.rawValue
                )
            )
            if let token = token {
                attributes.append(
                    ClientLogCounterAttribute(
                        key: LogConfig.Attribute.AttributionTokenErrorToken,
                        value: token
                    )
                )
            }
            ClientLogger.shared.logCounter(
                .NeevaAttributionRequestError,
                attributes: attributes
            )
        }
    }
}
