// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct NotificationRow: View {
    weak var viewDelegate: BannerViewDelegate?

    let notification: BaseNotification
    var showUnreadBadge = true
    let action: () -> Void

    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(Color.DefaultBackground)
                    .shadow(
                        color: Color(red: 0, green: 0, blue: 0, opacity: 0.40), radius: 48, x: 0,
                        y: 16
                    )
                    .frame(minHeight: ToastViewUX.height)

                HStack {
                    if notification.isUnread && showUnreadBadge {
                        NotificationBadge(count: nil, fontSize: nil)
                            .padding(.trailing)
                    }

                    GenericNotificationRow(notification: notification)

                    VStack {
                        Text("\(notification.dateReceived.timeFromNowString())")
                            .withFont(.bodyMedium)
                        Spacer()
                    }
                }
                .padding()
            }
            .padding(.horizontal, 16)
            .fixedSize(horizontal: false, vertical: true)
            .onTapGesture {
                action()
                viewDelegate?.dismiss()
            }

            Spacer()
        }
        .modifier(
            DraggableBannerModifier(bannerViewDelegate: viewDelegate)
        )
    }
}

struct GenericNotificationRow: View {
    let notification: BaseNotification

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(notification.title)
                    .withFont(.headingMedium)
                Text(notification.body ?? "")
                    .withFont(.bodyMedium)
            }.foregroundColor(.label)

            Spacer()
        }
    }
}
