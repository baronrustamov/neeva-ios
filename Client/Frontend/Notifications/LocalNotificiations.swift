// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared
import UserNotifications

class LocalNotifications {
    static let notificationManager = NotificationManager.shared

    struct NeevaPromo {
        let promoId: String
        let title: String
        let body: String
        let urlStr: String?
    }

    public enum LocalNotificationTapAction: String {
        case openWelcomeTour = "openWelcomeTour"
        case openIntroView = "openIntroView"
        case openCustomURL = "openCustomURL"
    }

    public enum ScheduleCallSite: String {
        case enterForeground = "enterForeground"
        case authorizeNotification = "authorizedNotification"
        case featureFlagUpdate = "featureFlagUpdate"
    }

    // MARK: - Create Notifications
    static func scheduleNeevaPromoCallback(callSite: ScheduleCallSite) {
        rescheduleNotificationIfNeeded(
            for: .neevaPromo,
            completion: { exists, rescheduled in
                var scheduled = rescheduled
                if !exists {
                    scheduled = createNeevaPromoCallback()
                }
                if scheduled {
                    var attributes = [
                        ClientLogCounterAttribute(
                            key: LogConfig.NotificationAttribute.localNotificationScheduleCallSite,
                            value: callSite.rawValue)
                    ]
                    if let promoId = Defaults[.lastScheduledNeevaPromoID] {
                        attributes.append(
                            ClientLogCounterAttribute(
                                key: LogConfig.NotificationAttribute.localNotificationPromoId,
                                value: promoId)
                        )
                    }
                    DispatchQueue.main.async {
                        ClientLogger.shared.logCounter(
                            .ScheduleLocalNotification,
                            attributes: attributes
                        )
                    }
                }
            })
    }

    static func scheduleNeevaOnboardingCallback(
        notificationType: NotificationType
    ) {
        rescheduleNotificationIfNeeded(
            for: notificationType,
            completion: { exists, rescheduled in
                var scheduled = rescheduled
                if !exists {
                    scheduled = createNeevaOnboardingCallback(
                        notificationType: notificationType)
                }
                if scheduled {
                    let attributes = [
                        ClientLogCounterAttribute(
                            key: LogConfig.NotificationAttribute.localNotificationPromoId,
                            value: notificationType.rawValue)
                    ]
                    DispatchQueue.main.async {
                        ClientLogger.shared.logCounter(
                            .ScheduleLocalNotification,
                            attributes: attributes
                        )
                    }
                }
            })
    }

    static func scheduleNeevaPromoCallbackIfAuthorized(callSite: ScheduleCallSite) {
        NotificationPermissionHelper.shared.isAuthorized { authorized in
            if authorized {
                scheduleNeevaPromoCallback(callSite: callSite)
            }
        }
    }

    static func scheduleAllNeevaOnboardingCallbackIfAuthorized() {
        NotificationPermissionHelper.shared.isAuthorized { authorized in
            if authorized {
                scheduleNeevaOnboardingCallback(notificationType: .neevaOnboardingProductSearch)
                scheduleNeevaOnboardingCallback(notificationType: .neevaOnboardingNewsProvider)
                scheduleNeevaOnboardingCallback(notificationType: .neevaOnboardingFastTap)
            }
        }
    }

    static func scheduleNeevaOnboardingCallbackIfAuthorized(notificationType: NotificationType) {
        NotificationPermissionHelper.shared.isAuthorized { authorized in
            if authorized {
                scheduleNeevaOnboardingCallback(notificationType: notificationType)
            }
        }
    }

    // MARK: - Rescheduling
    static func isNotificationScheduled(
        type: NotificationType, completion: @escaping (Bool) -> Void
    ) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { pendingNotifications in
            var exists = false

            for notification in pendingNotifications where notification.identifier == type.rawValue
            {
                exists = true
            }

            completion(exists)
        }
    }

    static func rescheduleNotificationIfNeeded(
        for type: NotificationType, completion: @escaping (Bool, Bool) -> Void
    ) {
        isNotificationScheduled(type: type) { exists in
            var rescheduled = false
            if exists {
                notificationManager.cancelLocalNotification(identifier: type.rawValue)
                switch type {
                case .neevaPromo:
                    rescheduled = createNeevaPromoCallback()
                case .neevaOnboardingProductSearch:
                    rescheduled = createNeevaOnboardingCallback(
                        notificationType: .neevaOnboardingProductSearch)
                case .neevaOnboardingNewsProvider:
                    rescheduled = createNeevaOnboardingCallback(
                        notificationType: .neevaOnboardingNewsProvider)
                case .neevaOnboardingFastTap:
                    rescheduled = createNeevaOnboardingCallback(
                        notificationType: .neevaOnboardingFastTap)
                case .neevaOnboardingDefaultBrowser:
                    rescheduled = createNeevaOnboardingCallback(
                        notificationType: .neevaOnboardingDefaultBrowser)
                }
            }

            completion(exists, rescheduled)
        }
    }

    static func parseNotificationPromoContent(content: String) -> NeevaPromo? {
        let components = content.components(separatedBy: "##")
        // there should always be promoId, title and body in the content
        if components.count < 3 {
            return nil
        }

        var urlStr: String?

        if components.count > 3 {
            urlStr = components[3]
        }

        return NeevaPromo(
            promoId: components[0],
            title: components[1],
            body: components[2],
            urlStr: urlStr
        )
    }

    // MARK: - Helpers
    private static func createNeevaPromoCallback() -> Bool {
        let type = NotificationType.neevaPromo
        let neevaPromo =
            parseNotificationPromoContent(
                content: NeevaFeatureFlags.latestValue(.localNotificationContent)
            )
        let notificationTriggerInterval = TimeInterval(
            NeevaFeatureFlags.latestValue(
                .localNotificationTriggerInterval
            )
        )

        if let neevaPromo = neevaPromo,
            shouldScheduleNeevaPromoNotification(
                triggerInterval: notificationTriggerInterval,
                promoId: neevaPromo.promoId
            )
        {
            notificationManager.createLocalNotification(
                identifier: type.rawValue,
                promoId: neevaPromo.promoId,
                type: type,
                timeInterval: notificationTriggerInterval,
                title: neevaPromo.title,
                body: neevaPromo.body,
                urlStr: neevaPromo.urlStr
            ) { _ in }
            Defaults[.lastNeevaPromoScheduledTimeInterval] = Int(Date().timeIntervalSince1970)
            return true
        } else {
            return false
        }
    }

    private static func createNeevaOnboardingCallback(
        notificationType: NotificationType
    ) -> Bool {
        var title: String?
        var body: String?
        var timeInterval: TimeInterval?
        var deeplinkUrl: String?
        var urlStr: String?

        switch notificationType {
        case .neevaOnboardingProductSearch:
            title = "Search better with Neeva"
            body =
                "Find the best reviewed products around the web, never ads. See the difference!"
            timeInterval = TimeInterval(Defaults[.productSearchPromoTimeInterval])
            let query = "best headphones"
            if let encodedQuery = query.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed), !encodedQuery.isEmpty
            {
                urlStr = "\(NeevaConstants.appSearchURL)?q=\(encodedQuery)"
            }
        case .neevaOnboardingNewsProvider:
            title = "Search better with Neeva"
            body =
                "Set your favorite News sources to personalize your search results!"
            timeInterval = TimeInterval(Defaults[.newsProviderPromoTimeInterval])
            deeplinkUrl = "neeva://configure-news-provider"
        case .neevaOnboardingFastTap:
            title = "Search better with Neeva"
            body =
                "Skip the search results page with FastTap, and go directly to the website of your choice. Start typing and see for yourself!"
            timeInterval = TimeInterval(Defaults[.fastTapPromoTimeInterval])
            deeplinkUrl = "neeva://fast-tap?query=tv%20shows"
        case .neevaOnboardingDefaultBrowser:
            title = "Safe, Blazing Fast Browsing. Every Time"
            body =
                "Ditch those trackers slowing you down. Make Neeva your default browser and see the difference for yourself."
            timeInterval = TimeInterval(Defaults[.defaultBrowserPromoTimeInterval])
            deeplinkUrl = "neeva://open-default-browser-education"
        default:
            break
        }

        if let title = title,
            let body = body,
            let timeInterval = timeInterval
        {
            notificationManager.createLocalNotification(
                identifier: notificationType.rawValue,
                promoId: notificationType.rawValue,
                type: notificationType,
                timeInterval: timeInterval,
                title: title,
                body: body,
                urlStr: urlStr,
                deeplinkUrl: deeplinkUrl
            ) { _ in }
            return true
        }

        return false
    }

    private static func shouldScheduleNeevaPromoNotification(
        triggerInterval: TimeInterval,
        promoId: String
    ) -> Bool {
        if triggerInterval == 0 {
            return false
        }

        guard let lastScheduledTimeInterval = Defaults[.lastNeevaPromoScheduledTimeInterval],
            let lastPromoId = Defaults[.lastScheduledNeevaPromoID]
        else {
            return true
        }

        let timeIntervalElapsed =
            Date().timeIntervalSince1970 - TimeInterval(lastScheduledTimeInterval)

        return timeIntervalElapsed < TimeInterval(triggerInterval) || lastPromoId != promoId
    }
}
