// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct DetailedSettingsLabel: View {
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
            Text(description)
                .foregroundColor(.secondaryLabel)
                .font(.caption)
        }
    }
}

struct GeneralSettingsSection: View {
    @State var showArchivedTabsSettings = false
    @Default(.showSearchSuggestions) var showSearchSuggestions
    @Default(.blockPopups) var blockPopups
    @Default(.contextMenuShowLinkPreviews) var showLinkPreviews
    @Default(.confirmCloseAllTabs) var confirmCloseAllTabs
    @EnvironmentObject var browserModel: BrowserModel

    var body: some View {
        NavigationLink(
            "Default Browser",
            destination:
                DefaultBrowserInterstitialOnboardingView()
                .environmentObject(
                    InterstitialViewModel(
                        trigger: .defaultBrowserSettings,
                        showCloseButton: false,
                        onboardingState: .openedSettingsState
                    )
                )
                .onAppear {
                    ClientLogger.shared.logCounter(
                        .SettingDefaultBrowser, attributes: EnvironmentHelper.shared.getAttributes()
                    )
                }
        )
        if FeatureFlag[.customSearchEngine] {
            makeNavigationLink(title: "Search Engine") {
                SearchEngineSettings()
            }
        }
        Toggle("Show Search Suggestions", isOn: $showSearchSuggestions)
        Toggle("Block Pop-up Windows", isOn: $blockPopups)
        Toggle(isOn: $showLinkPreviews) {
            DetailedSettingsLabel(
                title: "Show Link Previews",
                description: "When Long-pressing Links"
            )
        }
        Toggle(isOn: $confirmCloseAllTabs) {
            DetailedSettingsLabel(
                title: "Require Confirmation",
                description: "When Closing All Tabs"
            )
        }

        NavigationLink(isActive: $showArchivedTabsSettings) {
            ArchivedTabSettings()
        } label: {
            Text("Keep Tabs")
        }
    }
}

struct GeneralSettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        SettingPreviewWrapper {
            Section(header: Text("General")) {
                GeneralSettingsSection()
            }
        }
    }
}
