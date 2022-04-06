// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

// known issue: removing an entry from this enum will cause the user’s settings to be cleared
enum ClearableDataType: String, Identifiable, Codable, CaseIterable {
    case history = "Browsing History"
    case cache = "Cache"
    case cookies = "Cookies"
    case trackingProtection = "Tracking Protection"
    case dapps = "Connected dApps"
    case cookieCutterExclusions = "Cookie Cutter Exclusions"

    var id: String { rawValue }

    // duplication is currently unavoidable :(
    var label: LocalizedStringKey {
        switch self {
        case .history: return "Browsing History"
        case .cache: return "Cache"
        case .cookies: return "Cookies"
        case .trackingProtection: return "Tracking Protection"
        case .dapps: return "Connected dApps"
        case .cookieCutterExclusions: return "Cookie Cutter Exclusions"
        }
    }

    var description: LocalizedStringKey? {
        switch self {
        case .cookies:
            return "Clearing it will sign you out of most sites."
        case .cookieCutterExclusions:
            return "List of sites you configured to not use Cookie Cutter"
        default:
            return nil
        }
    }

    func clearable(profile: Profile, tabManager: TabManager) -> Clearable {
        switch self {
        case .history:
            return HistoryClearable(profile: profile)
        case .cache:
            return CacheClearable()
        case .cookies:
            return CookiesClearable()
        case .trackingProtection:
            return TrackingProtectionClearable()
        case .dapps:
            return ConnectedDAppsClearable()
        case .cookieCutterExclusions:
            return CookieCutterExclusionsClearable()
        }
    }
}

extension Defaults.Keys {
    fileprivate static let clearDataTypes = Defaults.Key<Set<ClearableDataType>>(
        "profile.dataManagement.clearTypes",
        default: Set(ClearableDataType.allCases))
}

struct DataManagementView: View {
    @State private var clearDataTypes = Defaults[.clearDataTypes]
    @State private var isDeleting = false
    @State var showingSuccess = false
    @Environment(\.openInNewTab) var openURL

    func onClear() {
        let bvc = SceneDelegate.getBVC(for: nil)
        clearDataTypes
            .map { $0.clearable(profile: bvc.profile, tabManager: bvc.tabManager).clear() }
            .allSucceed()
            .uponQueue(.main) { result in
                assert(result.isSuccess, "Private data was not cleared successfully")
                Defaults[.clearDataTypes] = clearDataTypes
                showingSuccess = true
            }
    }

    var body: some View {
        List {
            NavigationLink("Website Data", destination: WebsiteDataView())

            Section(header: Text("Data on This Device")) {
                ForEach(
                    ClearableDataType.allCases.filter {
                        switch $0 {
                        case .trackingProtection:
                            return !FeatureFlag[.cookieCutter]
                        case .dapps:
                            return NeevaConstants.currentTarget == .xyz
                        case .cookieCutterExclusions:
                            return FeatureFlag[.cookieCutter]
                        default:
                            return true
                        }
                    }
                ) { dataType in
                    Toggle(
                        isOn: Binding {
                            clearDataTypes.contains(dataType)
                        } set: { isOn in
                            if isOn {
                                clearDataTypes.insert(dataType)
                            } else {
                                clearDataTypes.remove(dataType)
                            }
                        }
                    ) {
                        if let description = dataType.description {
                            DetailedSettingsLabel(
                                title: dataType.label, description: description)
                        } else {
                            Text(dataType.label)
                        }
                    }
                }
            }.onChange(of: clearDataTypes) { _ in
                showingSuccess = false
            }

            Group {
                HStack {
                    Spacer(minLength: 0)
                    if showingSuccess {
                        Text("Selected data cleared successfully")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.green)
                            .saturation(0.5)
                    } else {
                        Button("Clear Selected Data on This Device") { isDeleting = true }
                            .disabled(clearDataTypes.isEmpty)
                            .accentColor(.red)
                    }
                    Spacer(minLength: 0)
                }.actionSheet(isPresented: $isDeleting) {
                    ActionSheet(
                        title: Text(
                            "This action will clear all of your private data. It cannot be undone."),
                        buttons: [
                            .destructive(Text("Clear Data"), action: self.onClear),
                            .cancel(),
                        ]
                    )
                }
            }

            if NeevaFeatureFlags[.neevaMemory] {
                Section(header: Text("Data in Neeva Memory")) {
                    NavigationLinkButton("Manage Neeva Memory") {
                        openURL(NeevaConstants.appMemoryModeURL, false)
                        SceneDelegate.getBVC(for: nil).dismissVC()
                    }
                }
            }
        }
        .navigationTitle("Clear Browsing Data")
        .listStyle(.insetGrouped)
        .applyToggleStyle()
    }
}

struct DataManagementView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DataManagementView()
                .navigationBarTitleDisplayMode(.inline)
        }
        NavigationView {
            DataManagementView(showingSuccess: true)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
