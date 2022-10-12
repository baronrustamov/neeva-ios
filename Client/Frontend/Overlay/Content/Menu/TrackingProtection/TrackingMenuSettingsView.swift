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
            header: Text("TRACKER AND AD BLOCKING")
        ) {
            Picker("Protection Mode", selection: $contentBlockingStrength) {
                ForEach(BlockingStrength.allCases) { strength in
                    DetailedSettingsLabel(
                        title: LocalizedStringKey(strength.name.capitalized),
                        description: strength.description
                    )
                    .tag(strength.rawValue)
                }
            }
            .onChange(of: contentBlockingStrength) { tag in
                if tag == BlockingStrength.easyPrivacy.rawValue {
                    adBlockEnabled = false
                }
            }
            .labelsHidden()
            .pickerStyle(.inline)
        }

        Section {
            Toggle(isOn: $adBlockEnabled) {
                DetailedSettingsLabel(
                    title: "Ad Blocking",
                    description: "Only available in Strict mode")
            }
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
