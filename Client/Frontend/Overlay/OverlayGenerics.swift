// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

extension EnvironmentValues {
    private struct OverlayMinHeightToFillScrollViewKey: EnvironmentKey {
        static let defaultValue: CGFloat = .zero
    }

    public var overlayMinHeightToFillScrollView: CGFloat {
        get { self[OverlayMinHeightToFillScrollViewKey.self] }
        set { self[OverlayMinHeightToFillScrollViewKey.self] = newValue }
    }
}

struct PopoverRootView: View {
    let overlayModel = OverlaySheetModel()

    var style: OverlayStyle
    var content: () -> AnyView
    var onDismiss: (PopoverRootView) -> Void
    var onOpenURL: (URL, PopoverRootView) -> Void
    let headerButton: OverlayHeaderButton?

    var body: some View {
        PopoverView(style: style, headerButton: headerButton) {
            content()
                .environment(
                    \.onOpenURL,
                    { url in
                        self.onOpenURL(url, self)
                    }
                )
                // While it may not be used in popovers,
                // some views require the OverlayModel as an EnvironmentObject.
                .environmentObject(overlayModel)
                .environment(\.hideOverlay, { self.onDismiss(self) })
        } onDismiss: {
            onDismiss(self)
        }
    }
}

struct OverlaySheetRootView: View {
    static let defaultOverlayPosition: OverlaySheetPosition = .middle

    let overlayModel = OverlaySheetModel()
    var overlayPosition: OverlaySheetPosition

    let style: OverlayStyle
    let content: () -> AnyView
    let onDismiss: (OverlaySheetRootView) -> Void
    let onOpenURL: (URL, OverlaySheetRootView) -> Void
    let headerButton: OverlayHeaderButton?
    let headerContent: () -> AnyView

    init(
        overlayPosition: OverlaySheetPosition = Self.defaultOverlayPosition,
        style: OverlayStyle,
        content: @escaping () -> AnyView,
        onDismiss: @escaping (OverlaySheetRootView) -> Void,
        onOpenURL: @escaping (URL, OverlaySheetRootView) -> Void,
        headerButton: OverlayHeaderButton?,
        headerContent: @escaping () -> AnyView = { AnyView(erasing: EmptyView()) }
    ) {
        self.overlayPosition = overlayPosition
        self.style = style
        self.content = content
        self.onDismiss = onDismiss
        self.onOpenURL = onOpenURL
        self.headerButton = headerButton
        self.headerContent = headerContent
    }

    @ViewBuilder
    var overlay: some View {
        OverlaySheetView(
            model: overlayModel,
            style: style,
            onDismiss: {
                onDismiss(self)
                overlayModel.hide()
            },
            headerButton: headerButton,
            headerContent: headerContent
        ) {
            content()
                .environment(
                    \.onOpenURL,
                    { url in
                        self.onOpenURL(url, self)
                    }
                )
                .environment(\.hideOverlay, { self.onDismiss(self) })
                .environmentObject(overlayModel)
        }
    }

    var body: some View {
        overlay
            .onAppear {
                // It seems to be necessary to delay starting the animation until this point to
                // avoid a visual artifact.
                DispatchQueue.main.async {
                    self.overlayModel.show(defaultPosition: overlayPosition)
                }
            }
    }
}
