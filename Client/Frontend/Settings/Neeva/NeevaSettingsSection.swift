// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI
import WebKit

struct NeevaSettingsSection: View {
    let dismissVC: () -> Void

    @ObservedObject var userInfo: NeevaUserInfo
    @Environment(\.openInNewTab) var openURL
    @Environment(\.settingsPresentSignInOrUpFlow) var presentSignInOrUpFlowView
    @State var showingAccountDetails = false

    // Used by FeatureFlag[.inlineAccountSettings] to render inline settings
    static var webView: WKWebView = {
        let config = TabManager.makeWebViewConfig(isIncognito: false)
        config.preferences.javaScriptCanOpenWindowsAutomatically = false

        let webView = WKWebView(
            frame: CGRect(width: 1, height: 1),
            configuration: config
        )
        webView.allowsLinkPreview = false
        webView.customUserAgent = UserAgent.neevaAppUserAgent()
        webView.load(URLRequest(url: NeevaConstants.appSettingsURL))

        return webView
    }()

    @State var loaderOpacity = 0.0

    var body: some View {
        if userInfo.isLoading {
            HStack(spacing: 10) {
                ProgressView()
                Text("Loading account info…").foregroundColor(.secondaryLabel)
            }
            .frame(height: 60 - 12)
            .opacity(loaderOpacity)
            .animation(.default)
            .onAppear {
                loaderOpacity = 1
            }.onDisappear {
                loaderOpacity = 0
            }
        } else if userInfo.isUserLoggedIn && Defaults[.signedInOnce] && userInfo.email != nil
            && !userInfo.email!.isEmpty
        {
            NavigationLink(
                destination: NeevaAccountInfoView(
                    isPresented: $showingAccountDetails, userInfo: userInfo),
                isActive: $showingAccountDetails
            ) {
                NeevaAccountRow(userInfo: userInfo)
            }

            if FeatureFlag[.inlineAccountSettings] {
                // TODO: fix adding connectors on this screen
                makeNavigationLink(title: "Account Settings") {
                    AccountSettingsView(webView: Self.webView)
                        .ignoresSafeArea(.all, edges: [.bottom, .horizontal])
                        .onAppear {
                            ClientLogger.shared.logCounter(
                                .SettingAccountSettings,
                                attributes: EnvironmentHelper.shared.getAttributes())
                        }
                }
            } else {
                NavigationLinkButton("Account Settings") {
                    ClientLogger.shared.logCounter(
                        .SettingAccountSettings,
                        attributes: EnvironmentHelper.shared.getAttributes())
                    openURL(NeevaConstants.appSettingsURL, false)
                    dismissVC()
                }
            }

            NavigationLinkButton("Connected Apps") {
                // if user is in a tour, trigger navigation on webui side to
                // prevent page refresh, which will cause lost of states
                if TourManager.shared.userReachedStep(
                    step: .promptSettingsInNeevaMenu, tapTarget: .connectedApps) != .stopAction
                {
                    openURL(NeevaConstants.appConnectionsURL, false)
                } else {
                    dismissVC()
                }
            }.if(TourManager.shared.isCurrentStep(with: .promptSettingsInNeevaMenu)) { view in
                view.throbbingHighlightBorderStyle(
                    highlight: Color.Tour.Background, staticColorMode: true)
            }
            NavigationLinkButton("Invite your friends!") {
                openURL(NeevaConstants.appReferralsURL, false)
                // log click referral promo from settings page
                var attributes = EnvironmentHelper.shared.getAttributes()
                attributes.append(ClientLogCounterAttribute(key: "source", value: "settings"))
                ClientLogger.shared.logCounter(
                    .OpenReferralPromo, attributes: attributes)
                dismissVC()
            }
        } else {
            Button("Sign in or Join Neeva") {
                ClientLogger.shared.logCounter(
                    .SettingSignin, attributes: EnvironmentHelper.shared.getFirstRunAttributes())
                presentSignInOrUpFlowView()
            }
            .frame(height: 60 - 12)
            .onAppear {
                /*
                 NOTE: Prime the `PremiumStore` products request.
                 Swift constructs the object lazily, so any access
                 will trigger initialization.
                 */
                _ = PremiumStore.shared.products.count
            }
        }
    }
}

struct AccountSettingsView: UIViewRepresentable {
    let webView: WKWebView
    func makeUIView(context: Context) -> some UIView { webView }
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct NeevaSettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        SettingPreviewWrapper {
            Section(header: Text("Neeva — Logged in")) {
                NeevaSettingsSection(
                    dismissVC: {},
                    userInfo: NeevaUserInfo(
                        previewDisplayName: "First Last", email: "name@example.com",
                        pictureUrl:
                            "https://pbs.twimg.com/profile_images/1273823608297500672/MBtG7NMI_400x400.jpg",
                        authProvider: .apple))
            }
            Section(header: Text("Neeva — Logged out")) {
                NeevaSettingsSection(dismissVC: {}, userInfo: .previewLoggedOut)
            }
            Section(header: Text("Neeva — Fetching status")) {
                NeevaSettingsSection(dismissVC: {}, userInfo: .previewLoading)
            }
        }
    }
}
