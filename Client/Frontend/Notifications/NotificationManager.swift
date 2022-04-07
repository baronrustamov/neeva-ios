// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import Foundation
import Shared
import SwiftUI

private let logger = Logger.browser

class NotificationManager: ObservableObject {
    static let promoIdKey = "PromoId"
    static let shared = NotificationManager()

    public struct notificationKey {
        public static let deeplinkURL = "deeplinkURL"
        public static let campaignID = "campaignID"
        public static let localNotificationURL = "localNotificationURL"
    }

    @Published private(set) var notifications = [BaseNotification]() {
        didSet {
            saveNotitificationsToDevice(notifications)
        }
    }

    private var upcomingNotifications: [BaseNotification] {
        notifications.filter { $0.dateReceived > Date() }
    }

    private var readNotifications: [BaseNotification] {
        notifications.filter { !$0.isUnread }
    }

    private var unreadNotifications: [BaseNotification] {
        notifications.filter { $0.isUnread && $0.dateReceived <= Date() }
    }

    private var shouldShowBadge: Bool {
        unreadNotifications.count > 0
    }

    // MARK: - Updates
    func handleReceivedNotification(_ notification: UNNotification, present: Bool = false) {
        let request = notification.request
        let content = request.content
        let deeplinkURL = content.userInfo[notificationKey.deeplinkURL] as? String
        let campaignID = content.userInfo[notificationKey.campaignID] as? String

        let notification: BaseNotification = {
            if let type = NotificationType(rawValue: request.identifier) {
                return NeevaPromoNotification(
                    id: request.identifier,
                    promoId: request.content.userInfo[NotificationManager.promoIdKey] as? String,
                    localURL:
                        request.content.userInfo[
                            NotificationManager.notificationKey.localNotificationURL] as? String,
                    type: type, title: content.title, subtitle: content.subtitle,
                    body: content.body,
                    deeplinkUrl: deeplinkURL, campaignID: campaignID,
                    dateReceived: notification.date)
            } else {
                return BaseNotification(
                    id: request.identifier,
                    type: nil,
                    title: content.title, subtitle: content.subtitle, body: content.body,
                    deeplinkUrl: deeplinkURL, campaignID: campaignID,
                    dateReceived: notification.date)
            }
        }()

        notifications.insert(notification, at: 0)

        if present {
            showInAppNotification(notification: notification)
        }
    }

    // MARK: - Storage
    private var storageURL: URL? {
        guard
            let path = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: AppInfo.sharedContainerIdentifier)?.path
        else {
            return nil
        }

        return URL(fileURLWithPath: path).appendingPathComponent("notifications")
    }

    private func saveNotitificationsToDevice(_ notifications: [BaseNotification]) {
        guard let path = storageURL?.absoluteString else {
            return
        }

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(notifications)
            FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
        } catch {
            logger.info("Failed to save notifications to device: \(error)")
        }
    }

    private func retrieveNotificationsFromDevice() -> [BaseNotification] {
        guard let url = storageURL,
            FileManager.default.fileExists(atPath: url.absoluteString),
            let notificationData = try? Data(contentsOf: url)
        else {
            return [BaseNotification]()
        }

        do {
            if let notifications = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                notificationData)
                as? [BaseNotification]
            {
                return notifications
            }
        } catch {
            logger.info("Failed to retrieve notifications from device: \(error)")
        }

        return [BaseNotification]()
    }

    /// Deletes all read notifications that are 7+ days old.
    private func purgeOldNotifications() {
        notifications = notifications.filter {
            $0.isUnread || $0.dateRead?.daysFromToday() ?? 0 <= 7
        }
    }

    // MARK: - Notification Creation
    func createLocalNotification(
        identifier: String,
        promoId: String,
        type: NotificationType? = nil,
        timeInterval: TimeInterval,
        title: String,
        subtitle: String? = nil,
        body: String?,
        urlStr: String? = nil,
        deeplinkUrl: String? = nil,
        completionHandler: @escaping (Result<BaseNotification, Error>) -> Void
    ) {
        if NeevaFeatureFlags.latestValue(.disableLocalNotification) {
            return
        }
        let content = UNMutableNotificationContent()
        content.title = title
        if let subtitle = subtitle {
            content.subtitle = subtitle
        }
        if let body = body {
            content.body = body
        }
        content.userInfo[NotificationManager.promoIdKey] = promoId
        if let urlStr = urlStr {
            content.userInfo[NotificationManager.notificationKey.localNotificationURL] = urlStr
        }
        if let deeplinkUrl = deeplinkUrl {
            content.userInfo[NotificationManager.notificationKey.deeplinkURL] = deeplinkUrl
        }

        // Create the trigger as a repeating event.
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false)

        // Create the request
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if let error = error {
                completionHandler(.failure(error))
            } else {
                let baseNotification = NeevaPromoNotification(
                    id: identifier, promoId: promoId, localURL: nil,
                    type: type, title: title,
                    subtitle: subtitle, body: body,
                    deeplinkUrl: deeplinkUrl,
                    dateReceived: Date(timeIntervalSinceNow: timeInterval))
                self.notifications.append(baseNotification)
                if type == .neevaPromo {
                    Defaults[.lastScheduledNeevaPromoID] = promoId
                }
                completionHandler(.success(baseNotification))
            }
        }
    }

    func cancelLocalNotification(identifier: String) {
        UNUserNotificationCenter
            .current()
            .removePendingNotificationRequests(withIdentifiers: [identifier])

        if let index = notifications.firstIndex(where: { $0.id == identifier }) {
            notifications.remove(at: index)
        }
    }

    private func rescheduleNotification(identifier: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { pendingNotifications in
            for notification in pendingNotifications where notification.identifier == identifier {
                self.cancelLocalNotification(identifier: identifier)

                if let trigger = notification.trigger as? UNTimeIntervalNotificationTrigger {
                    self.createLocalNotification(
                        identifier: notification.identifier,
                        promoId:
                            notification.content.userInfo[NotificationManager.promoIdKey] as? String
                            ?? "",
                        timeInterval: trigger.timeInterval,
                        title: notification.content.title, subtitle: notification.content.subtitle,
                        body: notification.content.body
                    ) { _ in }
                }
            }
        }
    }

    private var subscriptions: Set<AnyCancellable> = []

    private func setupFeatureFlagUpdateHandler() {
        NeevaFeatureFlags.shared.$flagsUpdated.sink { flagsUpdated in
            if flagsUpdated {
                let notificationContent = NeevaFeatureFlags.latestValue(.localNotificationContent)
                let neevaPromo =
                    LocalNotitifications.parseNotificationPromoContent(content: notificationContent)
                if let neevaPromo = neevaPromo,
                    neevaPromo.promoId != Defaults[.lastScheduledNeevaPromoID]
                {
                    LocalNotitifications.scheduleNeevaPromoCallbackIfAuthorized(
                        callSite: LocalNotitifications.ScheduleCallSite.featureFlagUpdate
                    )
                }
            }
        }.store(in: &subscriptions)
    }

    // MARK: - Notification Handler
    private func handleNotification(notification: BaseNotification, bvc: BrowserViewController) {
        notification.markNotificationAsRead()

        if let notification = notification as? NeevaPromoNotification, let type = notification.type
        {
            switch type {
            case .neevaPromo:
                handleNeevaPromoNotification(
                    promoId: notification.promoId, urlStr: notification.localURL, bvc: bvc)
            case .neevaOnboardingNewsProvider, .neevaOnboardingProductSearch,
                .neevaOnboardingFastTap:
                handleOnboardingNotification(
                    promoId: notification.promoId, urlStr: notification.localURL, bvc: bvc)
            }
        }

        if let urlStr = notification.deeplinkUrl,
            let deeplink = URL(string: urlStr),
            let routerpath = NavigationPath(bvc: bvc, url: deeplink)
        {
            NavigationPath.handle(nav: routerpath, with: bvc)
        }

        if let campaignID = notification.campaignID {
            let attributes = [
                ClientLogCounterAttribute(
                    key: LogConfig.NotificationAttribute.notificationCampaignId,
                    value: campaignID)
            ]
            ClientLogger.shared.logCounter(.OpenNotification, attributes: attributes)
        }
    }

    func handleNotification(request: UNNotificationRequest, bvc: BrowserViewController) {
        let promoId = request.content.userInfo[NotificationManager.promoIdKey] as? String
        let urlStr =
            request.content.userInfo[
                NotificationManager.notificationKey.localNotificationURL] as? String

        switch NotificationType(rawValue: request.identifier) {
        case .neevaPromo:
            handleNeevaPromoNotification(promoId: promoId, urlStr: urlStr, bvc: bvc)
        case .neevaOnboardingNewsProvider, .neevaOnboardingProductSearch, .neevaOnboardingFastTap:
            handleOnboardingNotification(promoId: promoId, urlStr: urlStr, bvc: bvc)
        case .none:
            break
        }

        // handle deeplink
        if let urlStr = request.content.userInfo[notificationKey.deeplinkURL] as? String,
            let deeplink = URL(string: urlStr),
            let routerpath = NavigationPath(bvc: bvc, url: deeplink)
        {
            NavigationPath.handle(nav: routerpath, with: bvc)
        }

        if let campaignID = request.content.userInfo[notificationKey.campaignID] as? String {
            let attributes = [
                ClientLogCounterAttribute(
                    key: LogConfig.NotificationAttribute.notificationCampaignId,
                    value: campaignID)
            ]
            ClientLogger.shared.logCounter(.OpenNotification, attributes: attributes)
        }
    }

    private func handleNeevaPromoNotification(
        promoId: String?, urlStr: String?, bvc: BrowserViewController
    ) {
        var tapAction: LocalNotitifications.LocalNotificationTapAction
        if !NeevaUserInfo.shared.isUserLoggedIn {
            bvc.presentIntroViewController(true)
            tapAction = LocalNotitifications.LocalNotificationTapAction.openIntroView
        } else {
            if let urlStr = urlStr, let url = URL(string: urlStr) {
                bvc.openURLInNewTab(url)
                tapAction = LocalNotitifications.LocalNotificationTapAction.openCustomURL
            } else {
                bvc.openURLInNewTab(NeevaConstants.appWelcomeToursURL)
                tapAction = LocalNotitifications.LocalNotificationTapAction.openWelcomeTour
            }
        }

        var attributes = [
            ClientLogCounterAttribute(
                key: LogConfig.NotificationAttribute.localNotificationTapAction,
                value: tapAction.rawValue)
        ]

        if let promoId = promoId {
            attributes.append(
                ClientLogCounterAttribute(
                    key: LogConfig.NotificationAttribute.localNotificationPromoId,
                    value: promoId)
            )
        }

        ClientLogger.shared.logCounter(
            .OpenLocalNotification,
            attributes: attributes
        )
    }

    private func handleOnboardingNotification(
        promoId: String?, urlStr: String?, bvc: BrowserViewController
    ) {
        var attributes: [ClientLogCounterAttribute] = []
        if let promoId = promoId {
            attributes.append(
                ClientLogCounterAttribute(
                    key: LogConfig.NotificationAttribute.localNotificationPromoId,
                    value: promoId)
            )
        }

        ClientLogger.shared.logCounter(
            .OpenLocalNotification,
            attributes: attributes
        )

        if !NeevaUserInfo.shared.isUserLoggedIn {
            bvc.presentIntroViewController(true)
        } else {
            if let urlStr = urlStr, let url = URL(string: urlStr) {
                bvc.openURLInNewTab(url)
            } else {
                bvc.openURLInNewTab(NeevaConstants.appWelcomeToursURL)
            }
        }
    }

    private func showInAppNotification(notification: BaseNotification) {
        guard let bvc = SceneDelegate.getBVCOrNil() else {
            return
        }

        bvc.notificationViewManager.enqueue(
            view: NotificationRow(
                notification: notification, showUnreadBadge: false,
                action: {
                    self.handleNotification(notification: notification, bvc: bvc)
                }))
    }

    // MARK: - Init
    init() {
        notifications = retrieveNotificationsFromDevice()
    }
}
