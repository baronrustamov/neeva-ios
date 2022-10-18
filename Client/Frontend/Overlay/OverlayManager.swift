// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

/// Vague categories of Overlay types.
/// For specific views, use `OverlayType`.
enum OverlayPriority {
    case fullScreen
    case modal
    case sheet
    case transient
}

/// Specific Overlay view type.
enum OverlayType: Equatable {
    case backForwardList(BackForwardListView?)
    case find(FindView?)
    /// Only uses `.fullScreenCover`.
    case fullScreenCover(AnyView)
    /// Uses `.fullScreenCover` on regular views and `.sheet` on large displays.
    case fullScreenModal(AnyView)
    /// Only uses `.sheet`.
    case fullScreenSheet(AnyView)
    case notification(NotificationRow?)
    case popover(PopoverRootView?)
    case sheet(OverlaySheetRootView?)
    case toast(ToastView?)

    func isPriority(_ priority: OverlayPriority) -> Bool {
        switch self {
        case .backForwardList, .find:
            return priority == .modal
        case .fullScreenCover, .fullScreenModal, .fullScreenSheet:
            return priority == .fullScreen || priority == .modal
        case .popover, .sheet:
            return priority == .modal || priority == .sheet
        case .notification, .toast:
            return priority == .transient
        }
    }

    func isPriority(_ priorities: [OverlayPriority]) -> Bool {
        switch self {
        case .backForwardList, .find:
            return priorities.contains(.modal)
        case .fullScreenCover, .fullScreenModal, .fullScreenSheet:
            return priorities.contains(.fullScreen)
        case .popover, .sheet:
            return priorities.contains(.modal) || priorities.contains(.sheet)
        case .notification, .toast:
            return priorities.contains(.transient)
        }
    }

    static func == (lhs: OverlayType, rhs: OverlayType) -> Bool {
        switch (lhs, rhs) {
        case (.backForwardList, .backForwardList):
            return true
        case (.find, .find):
            return true
        case (.fullScreenCover, .fullScreenCover):
            return true
        case (.fullScreenModal, .fullScreenModal):
            return true
        case (.fullScreenSheet, .fullScreenSheet):
            return true
        case (.notification, .notification):
            return true
        case (.popover, .popover):
            return true
        case (.sheet, .sheet):
            return true
        case (.toast, .toast):
            return true
        default:
            return false
        }
    }
}

class OverlayManager: ObservableObject {
    @Published private(set) var currentOverlay: OverlayType?
    @Published private(set) var displaying = false
    @Published var offset: CGFloat = 0
    @Published var opacity: CGFloat = 1
    @Published var animationCompleted: (() -> Void)?
    @Published var offsetForBottomBar = false
    @Published var hideBottomBar = false
    @Published var isPresentedViewControllerVisible = false
    @Published var backgroundOpacityLevel = 5
    /// Used to control full screen/popover sheets
    @Published var showFullScreenPopoverSheet = false

    private let chromeModel: TabChromeModel
    private let openURLInNewTabPreservingIncognitoState: (URL) -> Void

    private let animation = Animation.easeInOut(duration: 0.2)
    /// [(Overlay, Animate, Completion)]
    private var queuedOverlays = [(OverlayType, Bool, (() -> Void)?)]()

    // MARK: - Show
    @discardableResult func show(
        overlay: OverlayType, animate: Bool = true, completion: (() -> Void)? = nil
    ) -> OverlayType {
        guard animationCompleted == nil else {
            queuedOverlays.append((overlay, animate, completion))
            return overlay
        }

        if overlay.isPriority(.transient) {
            guard currentOverlay == nil else {
                queuedOverlays.append((overlay, animate, completion))
                return overlay
            }

            presentOverlay(overlay: overlay, animate: animate)
            completion?()
        } else {
            hideCurrentOverlay { [self] in
                presentOverlay(overlay: overlay, animate: animate)
                completion?()
            }
        }

        return overlay
    }

    private func showNextOverlayIfNeeded() {
        guard queuedOverlays.count > 0 else {
            return
        }

        let (overlay, animate, completion) = queuedOverlays[0]
        presentOverlay(overlay: overlay, animate: animate)
        queuedOverlays.remove(at: 0)
        completion?()
    }

    private func presentOverlay(overlay: OverlayType, animate: Bool = true) {
        switch overlay {
        case .backForwardList, .toast:
            offsetForBottomBar = true
        default:
            offsetForBottomBar = false
        }

        switch overlay {
        case .find:
            hideBottomBar = true
        default:
            hideBottomBar = false
        }

        currentOverlay = overlay

        if animate {
            // Used to make sure animation completes succesfully.
            animationCompleted = {
                self.animationCompleted = nil
            }

            switch overlay {
            case .backForwardList:
                slideAndFadeIn(offset: 100)
            case .fullScreenCover, .fullScreenModal, .fullScreenSheet, .popover:
                withAnimation(animation) {
                    showFullScreenPopoverSheet = true
                    displaying = true
                }
            case .notification:
                slideAndFadeIn(offset: -ToastViewUX.height)
            case .sheet:
                slideAndFadeIn(offset: OverlaySheetUX.animationOffset)
            case .toast:
                slideAndFadeIn(offset: ToastViewUX.height)
            default:
                withAnimation(animation) {
                    displaying = true
                }
            }
        } else {
            if overlay.isPriority(.fullScreen) {
                showFullScreenPopoverSheet = true
            }

            displaying = true
        }

        func slideAndFadeIn(offset: CGFloat) {
            self.offset = offset
            self.opacity = 0

            withAnimation(animation) {
                resetUIModifiers()
                displaying = true
            }
        }
    }

    /// Hides a specific Overlay.
    func hide(
        overlay: OverlayType,
        animate: Bool = true, showNext: Bool = true, completion: (() -> Void)? = nil
    ) {
        guard let currentOverlay = currentOverlay, currentOverlay == overlay else {
            return
        }

        hideCurrentOverlay(
            ofPriorities: nil, animate: animate, showNext: showNext, completion: completion)
    }

    // MARK: - Hide
    /// Hides a the current Overlay.
    /// - Parameters:
    ///     - ofPriority: Only hide the current Overlay if it matches this priority.
    func hideCurrentOverlay(
        ofPriority: OverlayPriority?,
        animate: Bool = true, showNext: Bool = true, completion: (() -> Void)? = nil
    ) {
        if let ofPriority = ofPriority {
            hideCurrentOverlay(
                ofPriorities: [ofPriority], animate: animate, showNext: showNext,
                completion: completion)
        } else {
            hideCurrentOverlay(
                ofPriorities: nil, animate: animate, showNext: showNext, completion: completion)
        }
    }

    /// Hides a the current Overlay.
    /// - Parameters:
    ///     - ofPriorities: Only hide the current Overlay if it matches one of passed priorities.
    func hideCurrentOverlay(
        ofPriorities: [OverlayPriority]? = nil,
        animate: Bool = true, showNext: Bool = true, completion: (() -> Void)? = nil
    ) {
        guard let overlay = currentOverlay else {
            completion?()
            return
        }

        if let ofPriorities = ofPriorities, !overlay.isPriority(ofPriorities) {
            completion?()
            return
        }

        let completion = {
            completion?()

            if showNext {
                self.showNextOverlayIfNeeded()
            }
        }

        if animate {
            animationCompleted = { [self] in
                currentOverlay = nil
                resetUIModifiers()
                animationCompleted = nil

                switch overlay {
                case .notification(let notification):
                    notification?.viewDelegate?.dismiss()
                case .toast(let toast):
                    toast?.viewDelegate?.dismiss()
                default:
                    break
                }

                DispatchQueue.main.async {
                    completion()
                }
            }

            switch overlay {
            case .backForwardList:
                slideAndFadeOut(offset: 0)
            case .fullScreenModal, .popover:
                if case .popover = overlay {
                    withAnimation(animation) {
                        opacity = 0
                    }
                }

                showFullScreenPopoverSheet = false

                // How long it takes for the system sheet to dismiss
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(self.animation) {
                        self.displaying = false
                    }
                }
            case .notification:
                slideAndFadeOut(offset: -ToastViewUX.height)
            case .sheet:
                slideAndFadeOut(offset: OverlaySheetUX.animationOffset)
            case .toast:
                slideAndFadeOut(offset: ToastViewUX.height)
            default:
                withAnimation(animation) {
                    displaying = false
                    offsetForBottomBar = false
                    hideBottomBar = false
                }
            }
        } else {
            currentOverlay = nil
            offsetForBottomBar = false
            hideBottomBar = false
            showFullScreenPopoverSheet = false
            displaying = false
            resetUIModifiers()
            completion()
        }

        func slideAndFadeOut(offset: CGFloat) {
            withAnimation(animation) {
                self.offset = offset
                opacity = 0
                displaying = false
                offsetForBottomBar = false
                hideBottomBar = false
            }
        }
    }

    private func resetUIModifiers() {
        offset = 0
        opacity = 1
    }

    // MARK: - init
    init(
        chromeModel: TabChromeModel,
        openURLInNewTabPreservingIncognitoState: @escaping (URL) -> Void
    ) {
        self.chromeModel = chromeModel
        self.openURLInNewTabPreservingIncognitoState = openURLInNewTabPreservingIncognitoState
    }
}

// MARK: - Full Screen Views
extension OverlayManager {
    /// Presents a full screen sheet on iPhone that cannot be dismissed by tapping outside.
    /// Presents as a large modal with padding on iPad that can be dismissed by tapping in the margins.
    func presentFullScreenModal(
        content: AnyView, animate: Bool = true, ignoreSafeArea: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        let content = AnyView(
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .if(ignoreSafeArea) { view in
                    view.ignoresSafeArea()
                }
        )

        show(overlay: .fullScreenModal(content), animate: animate, completion: completion)
    }

    /// Presents a full screen sheet for both iPhone and iPad.
    /// Cannot be dismissed by tapping outside the view.
    func presentFullScreenCover(
        content: AnyView, animate: Bool = true,
        ignoreSafeArea: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        let content = AnyView(
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .if(ignoreSafeArea) { view in
                    view.ignoresSafeArea()
                }
        )

        show(overlay: .fullScreenCover(content), animate: animate, completion: completion)
    }
}

// MARK: - Sheet & Popovers
extension OverlayManager {
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
        onDismiss: (() -> Void)? = nil
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
                self.hide(overlay: .sheet(rootView))
            },
            onOpenURL: { url, rootView in
                self.hide(overlay: .sheet(rootView))
                self.openURLInNewTabPreservingIncognitoState(url)
            },
            headerButton: headerButton,
            headerContent: { AnyView(erasing: headerContent()) }
        )

        show(overlay: .sheet(overlayView))
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
                self.hide(overlay: .popover(rootView))
            },
            onOpenURL: { url, rootView in
                self.hide(overlay: .popover(rootView))
                self.openURLInNewTabPreservingIncognitoState(url)
            }, headerButton: headerButton)

        self.show(overlay: .popover(popoverView))
    }
}
