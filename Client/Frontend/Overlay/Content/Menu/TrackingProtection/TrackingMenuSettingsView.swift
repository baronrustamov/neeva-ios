// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct TrackingMenuSettingsView: View {
    @EnvironmentObject var viewModel: TrackingStatsViewModel

    let domain: String
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("On \(domain)").padding(.top, 21)) {
                    Toggle("Tracking Prevention", isOn: $viewModel.preventTrackersForCurrentPage)
                }
                Section(header: Text("Global Privacy Settings")) {
                    TrackingSettingsBlock()
                }
                TrackingAttribution()
            }
            .navigationTitle("Advanced Privacy Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {}
                }
            }
            .listStyle(.insetGrouped)
            .applyToggleStyle()
        }.navigationViewStyle(.stack)
    }
}

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

struct TrackingSettingsBlock: View {
    // TODO: revisit these params when we have the final UX
    // @Default(.blockThirdPartyTrackingCookies) var blockTrackingCookies: Bool
    // @Default(.blockThirdPartyTrackingRequests) var blockTrackingRequests: Bool
    // @Default(.upgradeAllToHttps) var upgradeToHTTPS: Bool

    @Default(.contentBlockingEnabled) private var contentBlockingEnabled
    @Default(.contentBlockingStrength) private var contentBlockingStrength

    var body: some View {
        // Toggle("Block tracking cookies", isOn: $blockTrackingCookies)
        // Toggle("Block tracking requests", isOn: $blockTrackingRequests)
        // Toggle("Update requests to HTTPS", isOn: $upgradeToHTTPS)
        Toggle("Enable Protection", isOn: $contentBlockingEnabled)

        Picker("Protection Mode", selection: $contentBlockingStrength) {
            ForEach(BlockingStrength.allCases) { strength in
                Text(strength.name.capitalized)
                    .tag(strength.rawValue)
            }
        }
    }
}

struct TrackingMenuSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingMenuSettingsView(domain: "cnn.com")
    }
}
