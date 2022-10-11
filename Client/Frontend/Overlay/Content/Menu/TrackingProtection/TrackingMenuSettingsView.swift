// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct TrackingAttribution: View {
    @Environment(\.onOpenURL) var openURL

    var body: some View {
        Section(
            footer:
                // this component is not used currently
                Text(
                    verbatim:
                        "Tracking rules courtesy of [The EasyList Authors](https://easylist.to/)"
                )
        ) {}
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
                    "Blocks most trackers. Minimizes disruption to ads and other functionality."
                )
                : Text(
                    "Blocks more trackers. May disrupt ads and other functionality on some sites."
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
