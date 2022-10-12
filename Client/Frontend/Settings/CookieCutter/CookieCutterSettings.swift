// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct CookieCutterSettings: View {
    @Environment(\.onOpenURL) var openURL
    @EnvironmentObject var cookieCutterModel: CookieCutterModel

    @State var cookieCutterEnabled: Bool

    @ViewBuilder
    var cookieCutterFooter: some View {
        if cookieCutterModel.cookieNotices == CookieNotices.declineNonEssential {
            VStack(alignment: .leading) {
                Text(
                    "Essential cookies are used by sites to remember things like your login information and preferences. These cookies cannot be blocked by the extension."
                )

                Button {
                    openURL(NeevaConstants.cookieCutterHelpURL)
                } label: {
                    Text("Learn More").withFont(.bodyMedium)
                }
            }
        }
    }

    var body: some View {
        List {
            Section(
                footer:
                    Text(
                        "When disabled, turns off Neeva Shield on all sites. Changing this will reload your tabs."
                    )
            ) {
                Toggle("Neeva Shield", isOn: $cookieCutterEnabled)
                    .onChange(of: cookieCutterEnabled) { newValue in
                        cookieCutterModel.cookieCutterEnabled = newValue
                    }
                    .accessibilityLabel(Text("Cookie Cutter"))
                    .accessibilityIdentifier("CookieCutterGlobalToggle")
            }

            if cookieCutterEnabled {
                TrackingSettingsSectionBlock()

                Section(
                    header: Text("COOKIE POPUPS"),
                    footer: cookieCutterFooter
                ) {
                    Picker("", selection: $cookieCutterModel.cookieNotices) {
                        Text("Decline Non-essential Cookies")
                            .accessibility(identifier: "declineCookie")
                            .tag(CookieNotices.declineNonEssential)
                        Text("Accept Non-essential Cookies")
                            .accessibility(identifier: "acceptCookie")
                            .tag(CookieNotices.userSelected)
                    }.labelsHidden().pickerStyle(.inline).accessibilityLabel("Cookie Popups")
                }

                if cookieCutterModel.cookieNotices == CookieNotices.userSelected {
                    NonEssentialCookieSettings()
                        .environmentObject(cookieCutterModel)
                }
            }
        }
        .applyToggleStyle()
        .accessibilityIdentifier("cookieCutterSettingsPage")
        .listStyle(.insetGrouped)
        .navigationTitle(Text("Neeva Shield"))
    }
}

struct CookieCutterSettings_Previews: PreviewProvider {
    static var previews: some View {
        CookieCutterSettings(cookieCutterEnabled: true)
            .environmentObject(CookieCutterModel())
    }
}
