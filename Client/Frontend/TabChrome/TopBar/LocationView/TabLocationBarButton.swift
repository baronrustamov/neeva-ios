// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct TabLocationBarButton<Label: View>: View {
    let label: Label
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            label
                .frame(width: TabLocationViewUX.height, height: TabLocationViewUX.height)
                .transition(.opacity)
        }.foregroundColor(.label)
    }
}

struct LocationViewTrackingButton: View {
    @Environment(\.openSettings) private var openSettings
    @EnvironmentObject private var incognitoModel: IncognitoModel
    @EnvironmentObject private var trackingStatsModel: TrackingStatsViewModel
    @EnvironmentObject private var cookieCutterModel: CookieCutterModel
    @EnvironmentObject private var chromeModel: TabChromeModel

    let currentDomain: String

    var content: some View {
        TrackingMenuView()
            .environmentObject(trackingStatsModel)
            .environmentObject(cookieCutterModel)
            .environment(\.openSettings, openSettings)
            .topBarPopoverPadding(removeBottomPadding: false)
    }

    var body: some View {
        let label =
            incognitoModel.isIncognito
            ? Image("incognito", label: Text("Tracking Protection, Incognito"))
            : Image("tracking-protection", label: Text("Tracking Protection"))

        TabLocationBarButton(label: label.renderingMode(.template)) {
            ClientLogger.shared.logCounter(
                .OpenShield, attributes: EnvironmentHelper.shared.getAttributes())
            trackingStatsModel.showTrackingStatsViewPopover = true
        }.presentAsPopover(
            isPresented: $trackingStatsModel.showTrackingStatsViewPopover,
            backgroundColor: .systemGroupedBackground,
            arrowDirections: [.up, .down]
        ) {
            if chromeModel.inlineToolbar {
                ScrollView {
                    content
                        .topBarPopoverPadding(removeHorizontalPadding: false)
                        .padding(.bottom, 4)
                }
            } else {
                content
                    .padding(.vertical, 4)
            }
        }
    }
}

struct LocationViewReloadButton: View {
    let buildMenu: () -> UIMenu?
    let state: TabChromeModel.ReloadButtonState
    let onTap: () -> Void

    var body: some View {
        // TODO: when dropping support for iOS 14, change this to a Menu view with a primaryAction
        SecondaryMenuButton(action: onTap) {
            $0.tintColor = .label
            $0.setImage(
                Symbol.uiImage(state == .reload ? .arrowClockwise : .xmark, weight: .medium),
                for: .normal)
            $0.accessibilityLabel =
                state == .reload
                ? .TabToolbarReloadAccessibilityLabel : .TabToolbarStopAccessibilityLabel
            $0.setDynamicMenu(buildMenu)
        }
        .frame(width: TabLocationViewUX.height, height: TabLocationViewUX.height)
    }
}

/// see also `TopBarShareButton`
struct LocationViewShareButton: View {
    let url: URL?
    let onTap: (UIView) -> Void

    @State private var shareTargetView: UIView!

    var body: some View {
        if url != nil {
            TabLocationBarButton(label: Symbol(.squareAndArrowUp, weight: .medium, label: "Share"))
            {
                onTap(shareTargetView)
            }
            .uiViewRef($shareTargetView)
        }
    }
}

struct TabLocationBarButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            LocationViewTrackingButton(currentDomain: "neeva.com")
            LocationViewTrackingButton(currentDomain: "neeva.com")
                .environmentObject(IncognitoModel(isIncognito: true))
        }.previewLayout(.sizeThatFits)
        HStack {
            LocationViewReloadButton(
                buildMenu: { UIMenu(children: [UIAction(title: "Hello, world!") { _ in }]) },
                state: .reload
            ) {}
            LocationViewReloadButton(buildMenu: { nil }, state: .stop) {}
        }.previewLayout(.sizeThatFits)
        HStack {
            LocationViewShareButton(url: nil, onTap: { _ in })
            LocationViewShareButton(url: "https://neeva.com/", onTap: { _ in })
        }.previewLayout(.sizeThatFits)
    }
}
