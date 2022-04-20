// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

private func crash() {
    let ptr = UnsafeMutablePointer<Int>(bitPattern: 1)
    ptr?.pointee = 0
}

struct DebugSettingsSection: View {
    @Environment(\.onOpenURL) var openURL
    @Default(.enableGeigerCounter) var enableGeigerCounter

    var body: some View {
        Group {
            Section(header: Text(verbatim: "Debug — Neeva")) {
                makeNavigationLink(title: String("Server Feature Flags")) {
                    NeevaFeatureFlagSettingsView()
                }
                makeNavigationLink(title: String("Server User Flags")) {
                    NeevaUserFlagSettingsView()
                }
                AppHostSetting()
                #if DEBUG
                    DebugLocaleSetting()
                #endif
                NavigationLinkButton("\(String("Neeva Admin"))") {
                    openURL(NeevaConstants.appHomeURL / "admin")
                }
            }
            Section(header: Text(verbatim: "Debug — Local")) {
                makeNavigationLink(title: String("Local Feature Flags")) {
                    FeatureFlagSettingsView()
                }
                makeNavigationLink(title: String("Internal Settings")) {
                    InternalSettingsView()
                }
                makeNavigationLink(title: String("Experiment Settings")) {
                    ExperimentSettingsView()
                }
                makeNavigationLink(title: String("Logging")) {
                    LoggingSettingsView()
                }
                makeNavigationLink(title: String("GraphQL Logging")) {
                    ServerLoggingSettingsView()
                }
                Toggle(String("Enable Geiger Counter"), isOn: $enableGeigerCounter)
                    .onChange(of: enableGeigerCounter) {
                        guard let delegate = SceneDelegate.getCurrentSceneDelegateOrNil() else {
                            return
                        }
                        if $0 {
                            delegate.startGeigerCounter()
                        } else {
                            delegate.stopGeigerCounter()
                        }
                    }
                makeNavigationLink(title: String("Notification")) {
                    NotificationSettingsView()
                }
            }

            DebugDBSettingsSection()

            Section(header: Text(verbatim: "Performance")) {
                Button(String("Make all tabs zombies (excluding selected)")) {
                    guard let tabManager = SceneDelegate.getTabManagerOrNil() else {
                        return
                    }

                    tabManager.makeTabsIntoZombies(tabsToKeepAlive: 1)
                }

                Button(String("Create 100 tabs")) {
                    guard let tabManager = SceneDelegate.getTabManagerOrNil() else {
                        return
                    }

                    var urls = [URL]()
                    for _ in 0...99 {
                        urls.append(URL(string: "https://example.com")!)
                    }

                    tabManager.addTabsForURLs(urls, zombie: true)
                }

                Button(String("Create 500 tabs")) {
                    guard let tabManager = SceneDelegate.getTabManagerOrNil() else {
                        return
                    }

                    var urls = [URL]()
                    for _ in 0...499 {
                        urls.append(URL(string: "https://example.com")!)
                    }

                    tabManager.addTabsForURLs(urls, zombie: true)
                }

                Button(String("Force Crash App")) {
                    crash()
                }
            }.accentColor(.red)
        }
        .listRowBackground(Color.red.opacity(0.2).ignoresSafeArea())
    }
}

struct DebugSettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        SettingPreviewWrapper {
            DebugSettingsSection()
        }
    }
}
