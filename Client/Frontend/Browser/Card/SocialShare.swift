// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Social
import SwiftUI

private enum Social: String {
    case twitter = "com.apple.social.twitter"
    case linkedin = "com.apple.social.linkedin"
    case facebook = "com.apple.social.facebook"

    var serviceType: String {
        rawValue
    }

    var isAvailable: Bool {
        switch self {
        case .twitter:
            return UIApplication.shared.canOpenURL(URL(string: "twitter://")!)
        case .linkedin:
            return UIApplication.shared.canOpenURL(URL(string: "linkedin://")!)
        case .facebook:
            return UIApplication.shared.canOpenURL(URL(string: "fb://")!)
        }
    }
}

struct ShareToSocialView: View {
    @Environment(\.shareURL) var shareURL
    @Environment(\.onOpenURL) var openURL

    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var toastViewManager: ToastViewManager

    let url: URL
    let noteText: String
    let shareTargetView: UIView
    let ensurePublicACL: (@escaping () -> Void) -> Void

    init(
        url: URL, noteText: String, shareTarget: UIView,
        ensurePublicACL: @escaping (@escaping () -> Void) -> Void
    ) {
        self.url = url
        self.noteText = noteText
        self.shareTargetView = shareTarget
        self.ensurePublicACL = ensurePublicACL
    }

    var body: some View {
        HStack(spacing: 0) {
            SocialShareButton(
                imageName: "twitter-share", isSystemImage: false,
                label: "Twitter",
                onClick: {
                    ensurePublicACL({
                        let url = URL(
                            string:
                                "http://twitter.com/share?text=\(noteText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&url=\(url.absoluteString)"
                        )!
                        ClientLogger.shared.logCounter(
                            .SocialShare,
                            attributes: [
                                ClientLogCounterAttribute(
                                    key: LogConfig.SpacesAttribute.socialShareApp, value: "Twitter")
                            ])
                        if Social.twitter.isAvailable {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            openURL(url)
                        }
                    })
                })
            Spacer()
            SocialShareButton(
                imageName: "linkedin-share", isSystemImage: false,
                label: "Linkedin",
                onClick: {
                    ensurePublicACL({
                        ClientLogger.shared.logCounter(
                            .SocialShare,
                            attributes: [
                                ClientLogCounterAttribute(
                                    key: LogConfig.SpacesAttribute.socialShareApp, value: "LinkedIn"
                                )
                            ])
                        if Social.linkedin.isAvailable {
                            UIApplication.shared.open(
                                URL(
                                    string:
                                        "linkedin://shareArticle?mini=true&url=\(url.absoluteString)"
                                )!, options: [:], completionHandler: nil)
                        } else {
                            openURL(
                                URL(
                                    string:
                                        "https://linkedin.com/shareArticle?mini=true&url=\(url.absoluteString)"
                                )!)
                        }
                    })
                })
            Spacer()
            if Social.facebook.isAvailable {
                SocialShareButton(
                    imageName: "facebook-share", isSystemImage: false,
                    label: "Facebook",
                    onClick: {
                        ensurePublicACL({
                            guard
                                let vc = SLComposeViewController(
                                    forServiceType: Social.facebook.serviceType)
                            else {
                                return
                            }
                            ClientLogger.shared.logCounter(
                                .SocialShare,
                                attributes: [
                                    ClientLogCounterAttribute(
                                        key: LogConfig.SpacesAttribute.socialShareApp,
                                        value: "Facebook")
                                ])
                            vc.setInitialText(noteText)
                            vc.add(url)
                            SceneDelegate.getBVC(with: tabModel.manager.scene).present(
                                vc, animated: true)
                        })
                    })
                Spacer()
            }
            SocialShareButton(
                imageName: "link", isSystemImage: true,
                label: "Copy link",
                onClick: {
                    ensurePublicACL({
                        UIPasteboard.general.url = url

                        toastViewManager.makeToast(text: "URL copied to clipboard")
                            .enqueue(manager: toastViewManager)
                    })
                })
            Spacer()
            SocialShareButton(
                imageName: "square.and.arrow.up", isSystemImage: true,
                label: "More",
                onClick: {
                    ensurePublicACL({
                        ClientLogger.shared.logCounter(
                            .SocialShare,
                            attributes: [
                                ClientLogCounterAttribute(
                                    key: LogConfig.SpacesAttribute.socialShareApp, value: "Other")
                            ])
                        shareURL(url, shareTargetView)
                    })
                })
        }.padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
    }
}

struct SocialShareButton: View {
    let imageName: String
    let isSystemImage: Bool
    let label: LocalizedStringKey
    let onClick: () -> Void
    @State var isPressed: Bool = false

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Button(
                action: onClick,
                label: {
                    Group {
                        if isSystemImage {
                            Image(systemName: imageName)
                                .foregroundColor(.secondaryLabel)
                        } else {
                            Image(imageName, bundle: .main)
                                .resizable().scaledToFit()
                        }
                    }
                    .frame(width: 18, height: 18)
                    .tapTargetFrame()
                    .background(Color.DefaultBackground)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.tertiaryLabel, lineWidth: 1))
                }
            ).buttonStyle(.reportsPresses(to: $isPressed))
                .scaleEffect(isPressed ? 0.85 : 1)
            Text(label)
                .withFont(.bodySmall)
                .foregroundColor(.label)
                .padding(.top, 4)
        }
    }
}
