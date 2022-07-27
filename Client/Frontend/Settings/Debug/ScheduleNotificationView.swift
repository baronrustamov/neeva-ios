// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct ScheduleNotificationView: View {
    @Environment(\.dismissScreen) var dismissScreen

    @Default(.debugNotificationTitle) var debugNotificationTitle
    @Default(.debugNotificationBody) var debugNotificationBody
    @Default(.debugNotificationDeeplink) var debugNotificationDeeplink
    @Default(.debugNotificationTimeInterval) var debugNotificationTimeInterval

    var body: some View {
        List {
            OptionalStringField("Title", text: $debugNotificationTitle)
            OptionalStringField("Body", text: $debugNotificationBody)
            OptionalStringField("Deeplink", text: $debugNotificationDeeplink)
            NumberField("TimeInterval", number: $debugNotificationTimeInterval)
            Button {
                NotificationManager.shared.createLocalNotification(
                    identifier: "debug_notification",
                    promoId: "debug_campaign",
                    type: nil,
                    timeInterval: TimeInterval(debugNotificationTimeInterval),
                    title: debugNotificationTitle ?? "",
                    body: debugNotificationBody,
                    deeplinkUrl: debugNotificationDeeplink
                ) { _ in
                    DispatchQueue.main.async {
                        dismissScreen()
                    }
                }
            } label: {
                Text(verbatim: "Schedule")
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct ScheduleNotification_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScheduleNotificationView()
                .navigationTitle(String("Schedule Notification"))
                .navigationBarTitleDisplayMode(.inline)
        }.navigationViewStyle(.stack)
    }
}
