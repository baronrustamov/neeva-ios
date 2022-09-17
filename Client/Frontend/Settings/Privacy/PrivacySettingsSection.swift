// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct PrivacySettingsSection: View {
    @State var openCookieCutterPage = false

    @Default(.closeIncognitoTabs) var closeIncognitoTabs

    // Can't directly use Defaults because it's optional type and Toggle doesn't like it
    @State var usageCollectionCheckbox =
        Defaults[.shouldCollectUsageStats] != nil ? Defaults[.shouldCollectUsageStats]! : false

    @Environment(\.onOpenURL) var openURL
    @EnvironmentObject var cookieCutterModel: CookieCutterModel

    var body: some View {
        NavigationLink(
            "Clear Browsing Data",
            destination: DataManagementView()
                .onAppear {
                    ClientLogger.shared.logCounter(
                        .ViewDataManagement, attributes: EnvironmentHelper.shared.getAttributes())
                }
        )

        Toggle(isOn: $closeIncognitoTabs) {
            DetailedSettingsLabel(
                title: "Close Incognito Tabs",
                description: "When Leaving Incognito Mode"
            )
        }

        NavigationLink(isActive: $openCookieCutterPage) {
            CookieCutterSettings(cookieCutterEnabled: cookieCutterModel.cookieCutterEnabled)
        } label: {
            Text("Neeva Shield")
        }.id("cookie-cutter-setting")

        NavigationLinkButton("Privacy Policy") {
            ClientLogger.shared.logCounter(
                .ViewPrivacyPolicy, attributes: EnvironmentHelper.shared.getAttributes())
            openURL(NeevaConstants.appPrivacyURL)
        }

        Toggle(isOn: $usageCollectionCheckbox) {
            DetailedSettingsLabel(
                title: "Help improve Neeva",
                description: "Automatically send usage statistics to Neeva")
        }.onChange(of: usageCollectionCheckbox) { value in
            Defaults[.shouldCollectUsageStats] = value
        }
    }
}

struct PrivacySettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        SettingPreviewWrapper {
            Section(header: Text("Privacy")) {
                PrivacySettingsSection()
            }
        }
    }
}
