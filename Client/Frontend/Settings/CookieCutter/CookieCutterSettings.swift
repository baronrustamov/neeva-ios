// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct CookieCutterSettings: View {
    @Environment(\.onOpenURL) var openURL
    @EnvironmentObject var cookieCutterModel: CookieCutterModel

    @State var showNonEssentialCookieSettings = false
    @State var cookieCutterEnabled: Bool

    var body: some View {
        List {
            Section(
                footer:
                    Text(
                        "When disabled, turns off Cookie Cutter on all sites. Changing this will reload your tabs."
                    )
            ) {
                Toggle("Cookie Cutter", isOn: $cookieCutterEnabled)
                    .onChange(of: cookieCutterEnabled) { newValue in
                        cookieCutterModel.cookieCutterEnabled = newValue
                    }
                    .accessibilityLabel(Text("Cookie Cutter"))
                    .accessibilityIdentifier("CookieCutterGlobalToggle")
            }

            if cookieCutterEnabled {
                Section(
                    header: Text("COOKIE POPUPS"),
                    footer:
                        VStack(alignment: .leading) {
                            Text(
                                "Essential cookies are used by sites to remember things like your login information and preferences. These cookies cannot be blocked by the extension."
                            )

                            Button {
                                openURL(NeevaConstants.cookieCutterHelpURL)
                            } label: {
                                Text("Learn More")
                            }
                        }
                ) {
                    Picker("", selection: $cookieCutterModel.cookieNotices) {
                        Text("Decline Non-essential Cookies")
                            .tag(CookieNotices.declineNonEssential)

                        NavigationLink(isActive: $showNonEssentialCookieSettings) {
                            NonEssentialCookieSettings()
                                .environmentObject(cookieCutterModel)
                        } label: {
                            Text("Accept Non-essential Cookies")
                        }
                        .tag(CookieNotices.userSelected)
                        .highPriorityGesture(
                            TapGesture().onEnded { _ in
                                DispatchQueue.main.async {
                                    showNonEssentialCookieSettings = true
                                }

                                cookieCutterModel.cookieNotices = .userSelected
                            }
                        )
                    }.labelsHidden().pickerStyle(.inline).accessibilityLabel("Cookie Popups")
                }

                TrackingSettingsSectionBlock()
            }
        }
        .applyToggleStyle()
        .accessibilityIdentifier("cookieCutterSettingsPage")
        .listStyle(.insetGrouped)
        .navigationTitle(Text("Cookie Cutter"))
    }
}

struct CookieCutterSettings_Previews: PreviewProvider {
    static var previews: some View {
        CookieCutterSettings(cookieCutterEnabled: true)
            .environmentObject(CookieCutterModel())
    }
}
