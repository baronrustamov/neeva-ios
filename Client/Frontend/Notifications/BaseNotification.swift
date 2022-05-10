// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

enum NotificationType: String, Codable {
    case neevaPromo = "neevaPromo"
    case neevaOnboardingProductSearch = "neevaOnboardingProductSearch"
    case neevaOnboardingNewsProvider = "neevaOnboardingNewsProvider"
    case neevaOnboardingFastTap = "neevaOnboardingFastTap"
    case neevaOnboardingDefaultBrowser = "neevaOnboardingDefaultBrowser"
    case neevaOnboardingCookieCutter = "neevaOnboardingCookieCutter"
}

class BaseNotification: Codable, Identifiable {
    let id: String
    let type: NotificationType?

    let title: String
    let subtitle: String?
    let body: String?

    let deeplinkUrl: String?
    let campaignID: String?

    let dateReceived: Date
    var dateRead: Date? = nil

    var isUnread: Bool {
        dateRead == nil
    }

    func markNotificationAsRead() {
        dateRead = Date()
    }

    init(
        id: String = UUID().uuidString, type: NotificationType? = nil, title: String,
        subtitle: String? = nil, body: String? = nil, deeplinkUrl: String? = nil,
        campaignID: String? = nil, dateReceived: Date, dateRead: Date? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.deeplinkUrl = deeplinkUrl
        self.campaignID = campaignID
        self.dateReceived = dateReceived
        self.dateRead = dateRead
    }
}

class NeevaPromoNotification: BaseNotification {
    let promoId: String?
    let localURL: String?

    init(
        id: String = UUID().uuidString, promoId: String?, localURL: String?,
        type: NotificationType? = nil, title: String,
        subtitle: String? = nil, body: String? = nil,
        deeplinkUrl: String? = nil, campaignID: String? = nil,
        dateReceived: Date, dateRead: Date? = nil
    ) {
        self.promoId = promoId
        self.localURL = localURL

        super.init(
            id: id,
            type: type,
            title: title,
            subtitle: subtitle,
            body: body,
            deeplinkUrl: deeplinkUrl,
            campaignID: campaignID,
            dateReceived: dateReceived,
            dateRead: dateRead
        )
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
