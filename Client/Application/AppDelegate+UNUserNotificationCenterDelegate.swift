// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    // MARK: - Registering
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        Defaults[.notificationToken] = token
        ClientLogger.shared.logCounter(
            .RegisterNotificationToken,
            attributes: [
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.pushNotificationToken,
                    value: token
                ),
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.pushNotificationTokenEnvironment,
                    value: NotificationPermissionHelper.pushTokenEnvironment
                ),
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.isUserSignedIn,
                    value: String(NeevaUserInfo.shared.hasLoginCookie())
                ),
            ]
        )
        Defaults[.didRegisterNotificationTokenOnServer] = true
        NotificationPermissionHelper.shared.registerDeviceTokenWithServer(deviceToken: token)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register notifications: \(error)")
    }

    // MARK: - Handle Notifications
    func userNotificationCenter(
        _ center: UNUserNotificationCenter, willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) ->
            Void
    ) {
        let state = application?.applicationState
        NotificationManager.shared.handleReceivedNotification(
            notification, present: state == .active)
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let bvc = SceneDelegate.getBVC(for: nil)
        let request = response.notification.request

        NotificationManager.shared.handleNotification(request: request, bvc: bvc)

        completionHandler()
    }
}
