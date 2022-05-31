// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct SpacesIntroOverlayContent: View {
    @EnvironmentObject private var tabModel: TabCardModel
    @Environment(\.hideOverlay) private var hideOverlaySheet
    let learnMoreURL = URL(
        string: "https://help.neeva.com/hc/en-us/articles/1500005917202-What-are-Spaces")!
    @Environment(\.onOpenURL) private var onOpenURL
    var body: some View {
        SpacesIntroView(
            dismiss: {},
            imageName: "spaces-intro",
            imageAccessibilityLabel:
                "Stay organized by adding images, websites, documents to a Space today",
            headlineText: "Kill the clutter",
            detailText:
                "Save and share instantly. Stay organized by adding images, websites, documents to a Space today",
            firstButtonText: "Sign Up To Get Started",
            secondButtonText: "Learn More About Spaces",
            firstButtonPressed: {
                let bvc = SceneDelegate.getBVC(with: tabModel.manager.scene)
                bvc.presentIntroViewController(true)
            },
            secondButtonPressed: {
                onOpenURL(learnMoreURL)
            },
            isCloseButtonVisible: false,
            imageSize: CGSize(width: 107, height: 100),
            isSecondButtonVisible: false
        )
        .overlayIsFixedHeight(isFixedHeight: true)
    }
}

struct SpacesShareIntroOverlayContent: View {
    let onDismiss: () -> Void
    let onShare: () -> Void

    var body: some View {
        SpacesIntroView(
            dismiss: onDismiss,
            imageName: "spaces-share-intro",
            imageAccessibilityLabel:
                "Stay organized by adding images, websites, documents to a Space today",
            headlineText: "Share Space to the web",
            detailText:
                "Your Space will be public as anyone with the link can view your Space. Ready to share?",
            firstButtonText: "Yes! Share my Space publicly",
            secondButtonText: "Not now",
            firstButtonPressed: {
                onShare()
            },
            secondButtonPressed: onDismiss
        )
        .overlayIsFixedHeight(isFixedHeight: true)
    }
}

struct SpacesIntroView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var landscapeMode: Bool {
        verticalSizeClass == .compact || horizontalSizeClass == .regular
    }

    let dismiss: () -> Void
    let imageName: String
    let imageAccessibilityLabel: LocalizedStringKey
    let headlineText: LocalizedStringKey
    let detailText: LocalizedStringKey
    let firstButtonText: LocalizedStringKey
    let secondButtonText: LocalizedStringKey
    let firstButtonPressed: () -> Void
    let secondButtonPressed: () -> Void
    var isCloseButtonVisible = true
    var imageSize = CGSize(width: 214, height: 200)
    var isSecondButtonVisible = true

    var body: some View {
        VStack(spacing: 0) {
            if isCloseButtonVisible {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Symbol(.xmark, style: .headingMedium, label: "Close")
                            .foregroundColor(.tertiaryLabel)
                            .tapTargetFrame()
                            .padding(.trailing, 4.5)
                    }
                }
            }

            OrientationDependentStack(
                orientation: landscapeMode
                    ? UIDeviceOrientation.landscapeLeft : UIDeviceOrientation.portrait
            ) {
                Image(imageName, bundle: .main)
                    .resizable()
                    .frame(
                        width: imageSize.width * (landscapeMode ? 0.9 : 1),
                        height: imageSize.height * (landscapeMode ? 0.9 : 1)
                    )
                    .padding(.horizontal, landscapeMode ? 16 : 32)
                    .padding(.vertical, landscapeMode ? 0 : 32)
                    .accessibilityLabel(imageAccessibilityLabel)
                VStack {
                    Text(headlineText).withFont(.headingXLarge)
                        .padding(landscapeMode ? 4 : 8)
                    Text(detailText)
                        .withFont(.bodyLarge)
                        .lineLimit(3)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .fixedSize(horizontal: false, vertical: true)
                    Button(
                        action: firstButtonPressed,
                        label: {
                            Text(firstButtonText)
                                .withFont(.labelLarge)
                                .foregroundColor(.brand.white)
                                .padding(12)
                                .frame(maxWidth: .infinity)
                        }
                    )
                    .buttonStyle(.neeva(.primary))
                    .padding(.top, landscapeMode ? 4 : 36)
                    .padding(.horizontal, 16)
                    if isSecondButtonVisible {
                        Button(
                            action: secondButtonPressed,
                            label: {
                                Text(secondButtonText)
                                    .withFont(.labelLarge)
                                    .foregroundColor(.ui.adaptive.blue)
                                    .padding(landscapeMode ? 10 : 12)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 16)
                            }
                        ).padding(.top, landscapeMode ? 0 : 10)
                    }
                }
            }
        }.padding(.bottom, 20)
    }
}

struct EmptySpaceView: View {
    let learnMoreURL = URL(
        string: "https://help.neeva.com/hc/en-us/articles/1500005917202-What-are-Spaces")!
    @Environment(\.onOpenURL) private var onOpenURL
    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var spacesModel: SpaceCardModel
    @EnvironmentObject var toolbarModel: SwitcherToolbarModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Image("empty-space", bundle: .main)
                .resizable()
                .frame(width: 214, height: 200)
                .padding(28)
                .accessibilityLabel(
                    "Use bookmark icon on a search result or website to add to your Space")
            (Text(
                "Tap") + Text(" \u{10025E} ").font(Font.custom("nicons-400", size: 20))
                + Text(
                    "on a search result or website to add to your Space"
                ))
                .withFont(.bodyLarge)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .fixedSize(horizontal: false, vertical: true)
            Button(
                action: {
                    spacesModel.detailedSpace = nil
                    toolbarModel.openLazyTab()
                },
                label: {
                    Text("Start Searching")
                        .withFont(.labelLarge)
                        .frame(maxWidth: .infinity)
                        .clipShape(Capsule())
                }
            )
            .buttonStyle(.neeva(.primary))
            .padding(.top, 36)
            .padding(.horizontal, 16)
            Button(
                action: {
                    spacesModel.detailedSpace = nil
                    browserModel.hideGridWithNoAnimation()
                    onOpenURL(learnMoreURL)
                },
                label: {
                    Text("Learn More About Spaces")
                        .withFont(.labelLarge)
                        .foregroundColor(.ui.adaptive.blue)
                        .padding(13)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                }
            ).padding(.top, 10)
            Spacer()
        }
        .background(Color.background)
        .ignoresSafeArea()
    }
}

struct SpacesIntroView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SpacesIntroOverlayContent().preferredColorScheme(.dark).environment(\.hideOverlay, {})
            SpacesIntroOverlayContent().environment(\.hideOverlay, {})
        }
        SpacesShareIntroOverlayContent(onDismiss: {}, onShare: {}).environment(\.hideOverlay, {})
        EmptySpaceView()
    }
}
