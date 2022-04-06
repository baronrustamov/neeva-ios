// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct CookieCutterSettings: View {
    @Environment(\.onOpenURL) var openURL
    @EnvironmentObject var cookieCutterModel: CookieCutterModel

    @Default(.contentBlockingEnabled) private var contentBlockingEnabled
    @State var showNonEssentialCookieSettings = false

    var body: some View {
        List {
            Section(
                header: Text("COOKIE NOTICES"),
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
                }.labelsHidden()
            }

            Section {
                Toggle("Tracking Protection", isOn: $contentBlockingEnabled)
                    .onChange(of: contentBlockingEnabled) { enabled in
                        ClientLogger.shared.logCounter(
                            enabled ? .TurnOnGlobalBlockTracking : .TurnOffGlobalBlockTracking,
                            attributes: EnvironmentHelper.shared.getAttributes()
                        )
                    }
            }
        }
        .listStyle(.insetGrouped)
        .pickerStyle(.inline)
        .applyToggleStyle()
        .navigationTitle(Text("Cookie Cutter"))
    }
}

struct CookieCutterSettings_Previews: PreviewProvider {
    static var previews: some View {
        CookieCutterSettings()
            .environmentObject(CookieCutterModel())
    }
}
