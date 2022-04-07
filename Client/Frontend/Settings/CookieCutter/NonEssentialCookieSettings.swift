// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct NonEssentialCookieSettings: View {
    @EnvironmentObject var cookieCutterModel: CookieCutterModel
    @EnvironmentObject var browserModel: BrowserModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List {
            Section(
                footer:
                    VStack(alignment: .leading) {
                        Text(
                            "If a site does not support selecting these options individually, then all non-essential cookies for the site will be accepted."
                        )
                    }
            ) {
                Toggle(isOn: $cookieCutterModel.marketingCookiesAllowed) {
                    DetailedSettingsLabel(
                        title: "Marketing Cookies",
                        description: "Tracks your online activity for advertising purposes"
                    ).padding(.vertical, 8)
                }

                Toggle(isOn: $cookieCutterModel.analyticCookiesAllowed) {
                    DetailedSettingsLabel(
                        title: "Analytics Cookies",
                        description: "Collects information about your visits and actions on a site"
                    ).padding(.vertical, 8)
                }

                Toggle(isOn: $cookieCutterModel.socialCookiesAllowed) {
                    DetailedSettingsLabel(
                        title: "Social Cookies",
                        description:
                            "Personalization and social media features from third party providers"
                    ).padding(.vertical, 8)
                }
            }
        }
        .listStyle(.insetGrouped)
        .pickerStyle(.inline)
        .applyToggleStyle()
        .navigationTitle(Text("Non-essential Cookies"))
        .onChange(of: cookieCutterModel.cookieNoticeStateShouldReset) { value in
            if value {
                cookieCutterModel.cookieNoticeStateShouldReset = false
                cookieCutterModel.cookieNotices = .declineNonEssential

                let toastViewManager = browserModel.toastViewManager
                toastViewManager.makeToast(
                    content: ToastViewContent(
                        normalContent: ToastStateContent(
                            text: "Non-essential cookies will be set to decline.",
                            buttonText: "Reload",
                            buttonAction: {
                                self.presentationMode.wrappedValue.dismiss()
                            }))
                ).enqueue(manager: toastViewManager)
            }
        }
    }
}

struct NonEssentialCookieSettings_Previews: PreviewProvider {
    static var previews: some View {
        NonEssentialCookieSettings()
            .environmentObject(CookieCutterModel())
    }
}
