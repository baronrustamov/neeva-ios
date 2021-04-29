/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared

typealias UIAlertActionCallback = (UIAlertAction) -> Void

// MARK: - Extension methods for building specific UIAlertController instances used across the app
extension UIAlertController {

    /**
    Builds the Alert view that asks the user if they wish to restore their tabs after a crash.

    - parameter okayCallback: Okay option handler
    - parameter noCallback:   No option handler

    - returns: UIAlertController for asking the user to restore tabs after a crash
    */
    class func restoreTabsAlert(okayCallback: @escaping UIAlertActionCallback, noCallback: @escaping UIAlertActionCallback) -> UIAlertController {
        let alert = UIAlertController(
            title: .RestoreTabsAlertTitle,
            message: .RestoreTabsAlertMessage,
            preferredStyle: .alert
        )

        let noOption = UIAlertAction(
            title: .RestoreTabsAlertNo,
            style: .cancel,
            handler: noCallback
        )

        let okayOption = UIAlertAction(
            title: .RestoreTabsAlertOkay,
            style: .default,
            handler: okayCallback
        )

        alert.addAction(okayOption)
        alert.addAction(noOption)
        return alert
    }

    class func clearPrivateDataAlert(okayCallback: @escaping (UIAlertAction) -> Void) -> UIAlertController {
        let alert = UIAlertController(
            title: "",
            message: .ClearPrivateDataAlertMessage,
            preferredStyle: .alert
        )

        let noOption = UIAlertAction(
            title: .ClearPrivateDataAlertCancel,
            style: .cancel,
            handler: nil
        )

        let okayOption = UIAlertAction(
            title: .ClearPrivateDataAlertOk,
            style: .destructive,
            handler: okayCallback
        )

        alert.addAction(okayOption)
        alert.addAction(noOption)
        return alert
    }

    class func clearWebsiteDataAlert(okayCallback: @escaping (UIAlertAction) -> Void) -> UIAlertController {
        let alert = UIAlertController(
            title: "",
            message: .ClearWebsiteDataAlertMessage,
            preferredStyle: .alert
        )

        let noOption = UIAlertAction(
            title: .ClearWebsiteDataAlertCancel,
            style: .cancel,
            handler: nil
        )

        let okayOption = UIAlertAction(
            title: .ClearWebsiteDataAlertOk,
            style: .destructive,
            handler: okayCallback
        )

        alert.addAction(okayOption)
        alert.addAction(noOption)
        return alert
    }

    /**
     Creates an alert view to warn the user that their logins will either be completely deleted in the
     case of local-only logins or deleted across synced devices in synced account logins.

     - parameter deleteCallback: Block to run when delete is tapped.
     - parameter hasSyncedLogins: Boolean indicating the user has logins that have been synced.

     - returns: UIAlertController instance
     */
    class func deleteLoginAlertWithDeleteCallback(
        _ deleteCallback: @escaping UIAlertActionCallback,
        hasSyncedLogins: Bool) -> UIAlertController {

        let deleteAlert: UIAlertController
        if hasSyncedLogins {
            deleteAlert = UIAlertController(title: .DeleteLoginAlertTitle, message: .DeleteLoginAlertSyncedMessage, preferredStyle: .alert)
        } else {
            deleteAlert = UIAlertController(title: .DeleteLoginAlertTitle, message: .DeleteLoginAlertLocalMessage, preferredStyle: .alert)
        }

        let cancelAction = UIAlertAction(title: .DeleteLoginAlertCancel, style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: .DeleteLoginAlertDelete, style: .destructive, handler: deleteCallback)

        deleteAlert.addAction(cancelAction)
        deleteAlert.addAction(deleteAction)

        return deleteAlert
    }
}
