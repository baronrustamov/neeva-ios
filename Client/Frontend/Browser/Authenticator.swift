/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import Storage
import SwiftUI

class Authenticator {
    fileprivate static let MaxAuthenticationAttempts = 3

    static func handleAuthRequest(
        _ bvc: BrowserViewController,
        challenge: URLAuthenticationChallenge
    ) -> Deferred<Maybe<LoginRecord>> {
        // If there have already been too many login attempts, we'll just fail.
        if challenge.previousFailureCount >= Authenticator.MaxAuthenticationAttempts {
            return deferMaybe(LoginRecordError(description: "Too many attempts to open site"))
        }

        var credential = challenge.proposedCredential

        // If we were passed an initial set of credentials from iOS, try and use them.
        if let proposed = credential {
            if !(proposed.user?.isEmpty ?? true) {
                if challenge.previousFailureCount == 0 {
                    return deferMaybe(
                        LoginRecord(
                            credentials: proposed, protectionSpace: challenge.protectionSpace))
                }
            } else {
                credential = nil
            }
        }

        // No credentials, so show an empty prompt.
        return self.promptForUsernamePassword(
            bvc, protectionSpace: challenge.protectionSpace)
    }

    fileprivate static func promptForUsernamePassword(
        _ bvc: BrowserViewController,
        protectionSpace: URLProtectionSpace
    ) -> Deferred<Maybe<LoginRecord>> {
        if protectionSpace.host.isEmpty {
            print("Unable to show a password prompt without a hostname")

            return deferMaybe(
                LoginRecordError(description: "Unable to show a password prompt without a hostname")
            )
        }

        let deferred = Deferred<Maybe<LoginRecord>>()

        bvc.overlayManager.showModal(style: .grouped) {
            HTTPAuthPromptOverlayContent(
                url: protectionSpace.urlString(),
                onSubmit: { username, password in
                    let login = LoginRecord(
                        credentials: URLCredential(
                            user: username, password: password, persistence: .forSession),
                        protectionSpace: protectionSpace)
                    deferred.fill(Maybe(success: login))
                }
            )
        } onDismiss: {
            if !deferred.isFilled {
                deferred.fill(
                    Maybe(failure: LoginRecordError(description: "Save password cancelled")))
            }
        }

        return deferred
    }
}
