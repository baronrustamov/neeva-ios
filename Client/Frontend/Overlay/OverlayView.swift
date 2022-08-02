// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct OverlayView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @EnvironmentObject private var browserModel: BrowserModel
    @EnvironmentObject private var chromeModel: TabChromeModel
    @EnvironmentObject private var overlayManager: OverlayManager
    @EnvironmentObject private var scrollingControlModel: ScrollingControlModel

    @State var safeArea: CGFloat = 0
    @State var keyboardHidden = true
    @State var presentSheet = false

    var limitToOverlayType: [OverlayType]?

    /// Tells the `OverlayView` that it is apart of the main view and that `presentedViewControllers` could cover the view.
    var isFromBaseView = true
    var canDisplay: Bool {
        guard !overlayManager.isPresentedViewControllerVisible || !isFromBaseView else {
            return false
        }

        if let limitToOverlayType = limitToOverlayType,
            let currentOverlay = overlayManager.currentOverlay
        {
            return limitToOverlayType.contains(currentOverlay)
        }

        return true
    }

    var isSheet: Bool {
        if let currentOverlay = overlayManager.currentOverlay,
            case OverlayType.sheet = currentOverlay
        {
            return true
        }

        return false
    }

    var addDismissableBackground: Bool {
        switch overlayManager.currentOverlay {
        case .sheet, .popover:
            return true
        default:
            return false
        }
    }

    @ViewBuilder
    var content: some View {
        if canDisplay {
            switch overlayManager.currentOverlay {
            case .backForwardList(let backForwardList):
                backForwardList
            case .find(let findView):
                VStack {
                    Spacer()
                    findView
                        .padding(.bottom, keyboardHidden ? 0 : -14)
                }.ignoresSafeArea(.container)
            case .fullScreenModal(let fullScreenModal):
                if verticalSizeClass == .regular && horizontalSizeClass == .regular {
                    Color.clear
                        .sheet(isPresented: $overlayManager.showFullScreenPopoverSheet) {
                            // OnDismiss
                            // Nothing to do here
                        } content: {
                            fullScreenModal
                        }
                } else {
                    Color.clear
                        .fullScreenCover(isPresented: $overlayManager.showFullScreenPopoverSheet) {
                            // OnDismiss
                            // Nothing to do here
                        } content: {
                            fullScreenModal
                        }
                }
            case .notification(let notification):
                VStack {
                    notification
                        .padding(.top, 12)
                    Spacer()
                }
            case .popover(let popover):
                popover
            case .sheet(let sheet):
                sheet
            case .toast(let toast):
                VStack {
                    Spacer()
                    toast
                        .padding(.bottom, 18)
                }
            default:
                EmptyView()
            }
        }
    }

    var body: some View {
        GeometryReader { geom in
            ZStack {
                if addDismissableBackground {
                    DismissBackgroundView(
                        opacity: overlayManager.opacity / overlayManager.backgroundOpacityLevel
                    ) {
                        overlayManager.hideCurrentOverlay(ofPriority: .sheet)
                    }
                }

                content
                    .offset(y: overlayManager.offset)
                    .opacity(overlayManager.opacity)
                    .onAnimationCompleted(for: overlayManager.displaying) {
                        if let animationCompleted = overlayManager.animationCompleted {
                            animationCompleted()
                        }
                    }
                    .onChange(of: geom.safeAreaInsets.bottom) { newValue in
                        safeArea = geom.safeAreaInsets.bottom
                        keyboardHidden = safeArea < 100
                    }
                    .padding(
                        .bottom,
                        overlayManager.offsetForBottomBar && !chromeModel.inlineToolbar
                            && !chromeModel.keyboardShowing
                            ? chromeModel.bottomBarHeight - scrollingControlModel.footerBottomOffset
                            : 0
                    )
            }

        }
    }
}
