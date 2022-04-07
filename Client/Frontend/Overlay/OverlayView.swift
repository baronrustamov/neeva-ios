// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct OverlayView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @EnvironmentObject private var chromeModel: TabChromeModel
    @EnvironmentObject private var overlayManager: OverlayManager
    @EnvironmentObject private var scrollingControlModel: ScrollingControlModel

    @State var safeArea: CGFloat = 0
    @State var keyboardHidden = true
    @State var presentSheet = false
    @State var isVisible = false

    var limitToOverlayType: [OverlayType]?
    var canDisplay: Bool {
        if let limitToOverlayType = limitToOverlayType,
            let currentOverlay = overlayManager.currentOverlay
        {
            return limitToOverlayType.contains(currentOverlay)
        }

        return true
    }

    var isSheet: Bool {
        if let currentOverlay = overlayManager.currentOverlay,
            case OverlayType.sheet(_) = currentOverlay
        {
            return true
        }

        return false
    }

    @ViewBuilder
    var content: some View {
        switch overlayManager.currentOverlay {
        case .backForwardList(let backForwardList):
            backForwardList
        case .findInPage(let findInPage):
            VStack {
                Spacer()
                findInPage
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

    var body: some View {
        GeometryReader { geom in
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
                .onChange(of: canDisplay) { value in
                    if !value, isVisible {
                        overlayManager.hideCurrentOverlay(animate: false)
                    }
                }
                .padding(
                    .bottom,
                    overlayManager.offsetForBottomBar && !chromeModel.inlineToolbar
                        && !chromeModel.keyboardShowing
                        ? chromeModel.bottomBarHeight - scrollingControlModel.footerBottomOffset
                        : 0
                )
                .onAppear {
                    isVisible = true
                }
                .onDisappear {
                    isVisible = false
                }
        }
    }
}
