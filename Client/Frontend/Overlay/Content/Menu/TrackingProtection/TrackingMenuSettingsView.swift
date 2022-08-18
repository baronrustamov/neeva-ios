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
                    // this component is not used currently
                    Text(
                        verbatim:
                            "Tracking rules courtesy of [The EasyList Authors](https://easylist.to/)"
                    )
            ) {}
        } else {
            Section(
                footer:
                    Button(
                        action: {
                            openURL(URL(string: "https://easylist.to/pages/about.html")!)
                        },
                        label: {
                            // this component is not used currently
                            Text(verbatim: "Tracking rules courtesy of The EasyList Authors")
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
    @Default(.adBlockEnabled) private var adBlockEnabled
    @Default(.contentBlockingStrength) private var contentBlockingStrength

    var body: some View {
        Section(
            header: Text("TRACKERS"),
            footer: contentBlockingStrength == BlockingStrength.easyPrivacy.rawValue
                ? Text(
                    "Blocks many ads and trackers. Minimizes disruption to ads and other functionality."
                )
                : Text(
                    "Blocks more ads and trackers. May break ads and other functionality on some sites."
                )
        ) {
            Picker("Protection Mode", selection: $contentBlockingStrength) {
                ForEach(BlockingStrength.allCases) { strength in
                    VStack(alignment: .leading) {
                        Text(strength.name.capitalized)
                    }
                    .tag(strength.rawValue)
                }
            }
            .onChange(of: contentBlockingStrength) { tag in
                if tag == BlockingStrength.easyPrivacy.rawValue {
                    adBlockEnabled = false
                }
            }
            .labelsHidden()
            .pickerStyle(.segmented)
            .listRowBackground(Color.clear)
            .padding(.horizontal, -10)
        }

        // Only enable ad blocking on iOS 15+
        if #available(iOS 15.0, *) {
            Section {
                Toggle("Ad Blocking", isOn: $adBlockEnabled)
                    .onChange(of: adBlockEnabled) { _ in
                        if adBlockEnabled {
                            ClientLogger.shared.logCounter(.AdBlockEnabled)
                        }
                    }
                    .disabled(
                        contentBlockingStrength != BlockingStrength.easyPrivacyStrict.rawValue)
            }
        }
    }
}
