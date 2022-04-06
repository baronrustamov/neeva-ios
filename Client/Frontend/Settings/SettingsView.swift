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
}

enum SettingsPage {
    case cookieCutter
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
        NavigationView {
            List {
                if NeevaConstants.currentTarget != .xyz {
                    Section(header: Text("Neeva")) {
                        NeevaSettingsSection(dismissVC: dismiss, userInfo: .shared)
                    }
                }
                Section(header: Text("General")) {
                    GeneralSettingsSection()
                }
                Section(header: Text("Privacy")) {
                    PrivacySettingsSection(openCookieCutterPage: openPage == .cookieCutter)
                }
                Section(header: Text("Support")) {
                    SupportSettingsSection()
                }
                Section(header: Text("About")) {
                    AboutSettingsSection(showDebugSettings: $showDebugSettings)
                }
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
            }
        }
        .navigationViewStyle(.stack)
        .onDisappear(perform: TourManager.shared.notifyCurrentViewClose)
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
    init(bvc: BrowserViewController, openPage: SettingsPage? = nil) {
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
                            bvc.hideZeroQuery()
                        })
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
        )
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
