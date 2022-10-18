// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared
import UserNotifications
import XCGLogger

private let log = Logger.browser

enum NotificationPermissionStatus: Int {
    case undecided = 0
    case authorized = 1
    case denied = 2
}

enum NotificationAuthorizationCallSite: String {
    case tourFlow
    case promoCard
    case settings
    case defaultBrowserInterstitial
    case appLaunch
    case cookieCutterOnboarding
}

class NotificationPermissionHelper {
    static let shared = NotificationPermissionHelper()

    #if DEBUG
        static let pushTokenEnvironment = "sandbox"
    #else
        static let pushTokenEnvironment = "prod"
    #endif

    var permissionStatus: NotificationPermissionStatus {
        return NotificationPermissionStatus(rawValue: Defaults[.notificationPermissionState])
            ?? .undecided
    }

    func didAlreadyRequestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus != .notDetermined)
            }
        }
    }

    func isAuthorized(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(
                settings.authorizationStatus != .denied
                    && settings.authorizationStatus != .notDetermined)
        }
    }

    func requestPermissionIfNeeded(
        from bvc: BrowserViewController? = nil,
        showChangeInSettingsDialogIfNeeded: Bool = false,
        callSite: NotificationAuthorizationCallSite,
        completion: ((Bool) -> Void)? = nil
    ) {
        isAuthorized { [self] authorized in
            guard !authorized else {
                completion?(true)
                return
            }

            didAlreadyRequestPermission { requested in
                if !requested {
                    ClientLogger.shared.logCounter(
                        .ShowSystemNotificationPrompt,
                        attributes: [
                            ClientLogCounterAttribute(
                                key:
                                    LogConfig.NotificationAttribute
                                    .notificationAuthorizationCallSite,
                                value: callSite.rawValue
                            )
                        ]
                    )

                    self.requestPermissionFromSystem(completion: completion, callSite: callSite)
                } else if showChangeInSettingsDialogIfNeeded,
                    let bvc = bvc ?? SceneDelegate.getBVCOrNil()
                {
                    /// If we can't show the iOS system notification because the user denied our first request,
                    /// ask the user if they would like to change that in settings.
                    self.showChangeNotificationPreferencesInSettingsDialog(from: bvc)
                    completion?(false)
                } else {
                    completion?(false)
                }
            }
        }
    }

    /// Shows the iOS system popup to request notification permission.
    /// Will only show **once**, and if the user has not denied permission already.
    func requestPermissionFromSystem(
        completion: ((Bool) -> Void)? = nil,
        callSite: NotificationAuthorizationCallSite
    ) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [
                .alert, .sound, .badge, .providesAppNotificationSettings,
            ]) { granted, _ in
                print("Notification permission granted: \(granted)")
                DispatchQueue.main.async {
                    ClientLogger.shared.logCounter(
                        granted
                            ? .AuthorizeSystemNotification
                            : .DenySystemNotification,
                        attributes: [
                            ClientLogCounterAttribute(
                                key:
                                    LogConfig.NotificationAttribute
                                    .notificationAuthorizationCallSite,
                                value: callSite.rawValue
                            )
                        ]
                    )
                }

                completion?(granted)

                guard granted else {
                    Defaults[.notificationPermissionState] =
                        NotificationPermissionStatus.denied.rawValue
                    return
                }

                Defaults[.notificationPermissionState] =
                    NotificationPermissionStatus.authorized.rawValue

                self.registerAuthorizedNotification()
                LocalNotifications.scheduleNeevaPromoCallback(
                    callSite: LocalNotifications.ScheduleCallSite.authorizeNotification
                )
            }
    }

    func showChangeNotificationPreferencesInSettingsDialog(from bvc: BrowserViewController) {
        bvc.overlayManager.showModal(style: .grouped) {
            ChangeNotificationPreferenceDialogView {
                SystemsHelper.openSystemSettingsNeevaPage()
                bvc.overlayManager.hideCurrentOverlay(ofPriority: .modal)
            } onCancel: {
                bvc.overlayManager.hideCurrentOverlay(ofPriority: .modal)
            }
        }
    }

    func registerAuthorizedNotification() {
        isAuthorized { authorized in
            guard authorized else { return }

            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func unregisterRemoteNotifications() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }

    func registerDeviceTokenWithServer(deviceToken: String) {
        guard NeevaUserInfo.shared.hasLoginCookie() else {
            return
        }

        GraphQLAPI.shared.perform(
            mutation: AddDeviceTokenIosMutation(
                input: DeviceTokenInput(
                    deviceToken: deviceToken,
                    deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "",
                    environment: NotificationPermissionHelper.pushTokenEnvironment
                )
            )
        ) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                log.error("Failed to add device token \(error)")
                break
            }
        }
    }

    func deleteDeviceTokenFromServer() {
        if let vendorID = UIDevice.current.identifierForVendor?.uuidString {
            GraphQLAPI.shared.perform(
                mutation: DeleteDeviceTokenIosMutation(
                    input: DeleteDeviceTokenInput(
                        deviceId: vendorID
                    )
                )
            ) { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    log.error("Failed to delete device tokens \(error)")
                    break
                }
            }
        }
    }

    func updatePermissionState() {
        guard !AppConstants.IsRunningTest else {
            return
        }

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                Defaults[.notificationPermissionState] =
                    NotificationPermissionStatus.authorized.rawValue
            case .denied:
                Defaults[.notificationPermissionState] =
                    NotificationPermissionStatus.denied.rawValue
            default:
                Defaults[.notificationPermissionState] =
                    NotificationPermissionStatus.undecided.rawValue
            }
        }
    }

    init() {
        updatePermissionState()
    }
}
