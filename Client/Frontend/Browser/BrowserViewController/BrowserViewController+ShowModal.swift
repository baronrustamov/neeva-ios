// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

extension BrowserViewController {
    // MARK: Show
    /// Present Content as sheet if on iPhone and in Portrait; otherwise, present as popover
    ///  - Tag: showModal
    func showModal<Content: View>(
        style: OverlayStyle,
        headerButton: OverlayHeaderButton? = nil,
        toPosition: OverlaySheetPosition = .middle,
        @ViewBuilder content: @escaping () -> Content,
        onDismiss: (() -> Void)? = nil
    ) {
        showModal(
            style: style,
            headerButton: headerButton,
            toPosition: toPosition,
            headerContent: { EmptyView() },
            content: content,
            onDismiss: onDismiss
        )
    }

    func showModal<Content: View, HeaderContent: View>(
        style: OverlayStyle,
        headerButton: OverlayHeaderButton? = nil,
        toPosition: OverlaySheetPosition = .middle,
        @ViewBuilder headerContent: @escaping () -> HeaderContent,
        @ViewBuilder content: @escaping () -> Content,
        onDismiss: (() -> Void)? = nil
    ) {
        if !chromeModel.inlineToolbar {
            showAsModalOverlaySheet(
                style: style,
                toPosition: toPosition,
                content: content,
                onDismiss: onDismiss,
                headerButton: headerButton,
                headerContent: headerContent
            )
        } else {
            showAsModalOverlayPopover(
                style: style, content: content, onDismiss: onDismiss, headerButton: headerButton)
        }
    }

    func showAsModalOverlaySheet<Content: View>(
        style: OverlayStyle,
        toPosition: OverlaySheetPosition = .middle,
        @ViewBuilder content: @escaping () -> Content,
        onDismiss: (() -> Void)? = nil,
        headerButton: OverlayHeaderButton? = nil
    ) {
        showAsModalOverlaySheet(
            style: style,
            toPosition: toPosition,
            content: content,
            onDismiss: onDismiss,
            headerButton: nil,
            headerContent: { EmptyView() }
        )
    }

    func showAsModalOverlaySheet<Content: View, HeaderContent: View>(
        style: OverlayStyle,
        toPosition: OverlaySheetPosition = .middle,
        @ViewBuilder content: @escaping () -> Content,
        onDismiss: (() -> Void)? = nil,
        headerButton: OverlayHeaderButton? = nil,
        @ViewBuilder headerContent: @escaping () -> HeaderContent
    ) {
        let overlayView = OverlaySheetRootView(
            overlayPosition: toPosition,
            style: style,
            content: { AnyView(erasing: content()) },
            onDismiss: { rootView in
                onDismiss?()
                self.overlayManager.hide(overlay: .sheet(rootView))
            },
            onOpenURL: { url, rootView in
                self.overlayManager.hide(overlay: .sheet(rootView))
                self.openURLInNewTabPreservingIncognitoState(url)
            },
            headerButton: headerButton,
            headerContent: { AnyView(erasing: headerContent()) }
        )

        overlayManager.show(overlay: .sheet(overlayView))
    }

    func showAsModalOverlayPopover<Content: View>(
        style: OverlayStyle,
        @ViewBuilder content: @escaping () -> Content,
        onDismiss: (() -> Void)? = nil,
        headerButton: OverlayHeaderButton? = nil
    ) {
        let popoverView = PopoverRootView(
            style: style, content: { AnyView(erasing: content()) },
            onDismiss: { rootView in
                onDismiss?()
                self.overlayManager.hide(overlay: .popover(rootView))
            },
            onOpenURL: { url, rootView in
                self.overlayManager.hide(overlay: .popover(rootView))
                self.openURLInNewTabPreservingIncognitoState(url)
            }, headerButton: headerButton)

        overlayManager.show(overlay: .popover(popoverView))
    }

    func presentFullScreenModal(content: AnyView, completion: (() -> Void)? = nil) {
        overlayManager.presentFullScreenModal(content: content, completion: completion)
    }

    // MARK: - Dismiss
    func hideOverlaySheetViewController() {
        if case .sheet = overlayManager.currentOverlay {
            overlayManager.hideCurrentOverlay()
        }
    }

    func hideOverlayPopoverViewController() {
        if case .popover = overlayManager.currentOverlay {
            overlayManager.hideCurrentOverlay()
        }
    }

    func dismissCurrentOverlay() {
        overlayManager.hideCurrentOverlay()
    }
}
