// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

extension EnvironmentValues {
    private struct PresentIntroKey: EnvironmentKey {
        static var defaultValue = { () -> Void in
            fatalError("Specify an environment value for \\.settingsPresentIntroViewController")
        }
    }
    public var settingsPresentIntroViewController: () -> Void {
        get { self[PresentIntroKey.self] }
        set { self[PresentIntroKey.self] = newValue }
    }

    private struct PresentSignInOrUpFlowKey: EnvironmentKey {
        static var defaultValue = { () -> Void in
            fatalError("Specify an environment value for \\.settingsPresentSignInOrUpFlow")
        }
    }
    public var settingsPresentSignInOrUpFlow: () -> Void {
        get { self[PresentSignInOrUpFlowKey.self] }
        set { self[PresentSignInOrUpFlowKey.self] = newValue }
    }

}

public enum SettingsPage: String {
    case archivedTabs = "general"
    case cookieCutter = "privacy"

    func settingId() -> String {
        switch self {
        case .archivedTabs:
            return "archived-tabs-setting"
        case .cookieCutter:
            return "cookie-cutter-setting"
        }
    }
}

struct SettingsView: View {
    let dismiss: () -> Void
    let openPage: SettingsPage?

    #if DEBUG
        @State var showDebugSettings = true
    #else
        @State var showDebugSettings = false
    #endif

    let scrollViewAppearance = UINavigationBar.appearance().scrollEdgeAppearance

    var body: some View {
        ZStack {
            NavigationView {
                ScrollViewReader { reader in
                    List {
                        Section(header: Text("Neeva")) {
                            NeevaSettingsSection(dismissVC: dismiss, userInfo: .shared)
                        }.id("neeva-section")

                        Section(header: Text("General")) {
                            GeneralSettingsSection(
                                showArchivedTabsSettings: openPage == .archivedTabs)
                        }.id("general-section")

                        Section(header: Text("Appearance")) {
                            AppearanceSettingsSection()
                        }.id("appearance-section")

                        Section(header: Text("Privacy")) {
                            PrivacySettingsSection(openCookieCutterPage: openPage == .cookieCutter)
                        }.id("privacy-section")

                        Section(header: Text("Support")) {
                            SupportSettingsSection()
                        }.id("support-section")

                        Section(header: Text("About")) {
                            AboutSettingsSection(showDebugSettings: $showDebugSettings)
                        }.id("about-section")

                        if showDebugSettings {
                            DebugSettingsSection()
                        }
                    }
                    .listStyle(.insetGrouped)
                    .applyToggleStyle()
                    .navigationTitle("Settings")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done", action: dismiss)
                        }
                    }.onAppear {
                        if let openPage = openPage {
                            reader.scrollTo("\(openPage.settingId())")
                        }
                    }.onDisappear(perform: TourManager.shared.notifyCurrentViewClose)
                }
            }.navigationViewStyle(.stack)

            OverlayView(limitToOverlayType: [.toast(nil)], isFromBaseView: false)
        }
    }
}

struct SettingPreviewWrapper<Content: View>: View {
    let content: () -> Content
    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
        NavigationView {
            List {
                content()
            }
            .listStyle(.insetGrouped)
            .applyToggleStyle()
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }.navigationViewStyle(.stack)
    }
}

class SettingsViewController: UIHostingController<AnyView> {
    private let onDisappear: () -> Void

    init(
        bvc: BrowserViewController, openPage: SettingsPage? = nil, onDisappear: @escaping () -> Void
    ) {
        self.onDisappear = onDisappear
        super.init(rootView: AnyView(EmptyView()))

        self.rootView = AnyView(
            SettingsView(
                dismiss: { self.dismiss(animated: true, completion: nil) }, openPage: openPage
            )
            .environment(\.openInNewTab) { url, isIncognito in
                self.dismiss(animated: true, completion: nil)
                bvc.openURLInNewTab(url, isIncognito: isIncognito)
            }
            .environment(\.onOpenURL) { url in
                self.dismiss(animated: true, completion: nil)
                bvc.openURLInNewTabPreservingIncognitoState(url)
            }
            .environment(\.settingsPresentIntroViewController) {
                self.dismiss(animated: true) {
                    bvc.presentIntroViewController(
                        true,
                        completion: {
                            bvc.dismissEditingAndHideZeroQuery()
                        })
                }
            }
            .environment(\.settingsPresentSignInOrUpFlow) {
                self.dismiss(animated: true) {
                    bvc.presentSignInOrUpFlow(startScreen: nil)
                }
            }
            .environment(\.dismissScreen) {
                self.dismiss(animated: true, completion: nil)
            }
            .environment(\.showNotificationPrompt) {
                bvc.showAsModalOverlaySheet(
                    style: OverlayStyle(
                        showTitle: false,
                        backgroundColor: .systemBackground)
                ) {
                    NotificationPromptViewOverlayContent()
                } onDismiss: {
                }
            }
            .environmentObject(bvc.browserModel)
            .environmentObject(bvc.browserModel.cookieCutterModel)
            .environmentObject(bvc.browserModel.scrollingControlModel)
            .environmentObject(bvc.chromeModel)
            .environmentObject(bvc.overlayManager)
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        onDisappear()
    }

    @objc required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(dismiss: {}, openPage: nil)
    }
}
