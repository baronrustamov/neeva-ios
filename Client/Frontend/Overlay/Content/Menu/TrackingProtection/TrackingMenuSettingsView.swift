// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct TrackingAttribution: View {
    @Environment(\.onOpenURL) var openURL

    var body: some View {
        if #available(iOS 15.0, *) {
            Section(
                footer:
                    Text("Tracking rules courtesy of [The EasyList Authors](https://easylist.to/)")
            ) {}
        } else {
            Section(
                footer:
                    Button(
                        action: {
                            openURL(URL(string: "https://easylist.to/pages/about.html")!)
                        },
                        label: {
                            Text("Tracking rules courtesy of The EasyList Authors")
                        }
                    )
                    .font(.footnote)
                    .accentColor(.secondaryLabel)
                    .textCase(nil)
            ) {}
        }
    }
}

struct TrackingSettingsSectionBlock: View {
    @Default(.contentBlockingEnabled) private var contentBlockingEnabled {
        didSet {
            for tabManager in SceneDelegate.getAllTabManagers() {
                tabManager.flagAllTabsToReload()
            }
        }
    }
    @Default(.contentBlockingStrength) private var contentBlockingStrength

    var body: some View {
        Section(
            header: Text("TRACKERS")
        ) {
            Toggle("Enable Protection", isOn: $contentBlockingEnabled)
        }

        Section(
            footer: Text(
                "If a site doesn't work as expected, you can deactivate Cookie Cutter for the site at any time."
            )
        ) {
            Picker("Protection Mode", selection: $contentBlockingStrength) {
                ForEach(BlockingStrength.allCases) { strength in
                    // TODO: enable ad blocker at a later release
                    if strength != .easyListAdBlock {
                        VStack(alignment: .leading) {
                            Text(strength.name.capitalized)
                        }
                        .tag(strength.rawValue)
                    }
                }
            }
            .labelsHidden()
            .pickerStyle(.inline)
            .disabled(!contentBlockingEnabled)
        }
    }
}
