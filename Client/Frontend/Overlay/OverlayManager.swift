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
    case fullScreenModal(AnyView)
    case notification(NotificationRow?)
    case popover(PopoverRootView?)
    case sheet(OverlaySheetRootView?)
    case toast(ToastView?)
    case cheatsheet(CheatsheetOverlayHostView?)

    func isPriority(_ priority: OverlayPriority) -> Bool {
        switch self {
        case .backForwardList, .find, .fullScreenModal:
            return priority == .modal
        case .popover, .sheet, .cheatsheet:
            return priority == .modal || priority == .sheet
        case .notification, .toast:
            return priority == .transient
        }
    }

    func isPriority(_ priorities: [OverlayPriority]) -> Bool {
        switch self {
        case .backForwardList, .find, .fullScreenModal:
            return priorities.contains(.modal)
        case .popover, .sheet, .cheatsheet:
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
        case (.fullScreenModal, .fullScreenModal):
            return true
        case (.notification, .notification):
            return true
        case (.popover, .popover):
            return true
        case (.sheet, .sheet):
            return true
        case (.toast, .toast):
            return true
        case (.cheatsheet, .cheatsheet):
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
    @Published var animationCompleted: (() -> Void)? = nil
    @Published var offsetForBottomBar = false
    @Published var hideBottomBar = false
    @Published var isPresentedViewControllerVisible = false

    /// Used to control full screen/popover sheets
    @Published var showFullScreenPopoverSheet = false

    private let animation = Animation.easeInOut(duration: 0.2)
    /// (Overlay, Animate, Completion])
    var queuedOverlays = [(OverlayType, Bool, (() -> Void)?)]()

    public func presentFullScreenModal(
        content: AnyView, animate: Bool = true, completion: (() -> Void)? = nil
    ) {
        let content = AnyView(
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        )

        show(overlay: .fullScreenModal(content), animate: animate, completion: completion)
    }

    public func show(overlay: OverlayType, animate: Bool = true, completion: (() -> Void)? = nil) {
        guard animationCompleted == nil else {
            queuedOverlays.append((overlay, animate, completion))
            return
        }

        if overlay.isPriority(.transient) {
            guard currentOverlay == nil else {
                queuedOverlays.append((overlay, animate, completion))
                return
            }

            presentOverlay(overlay: overlay, animate: animate)
            completion?()
        } else {
            hideCurrentOverlay { [self] in
                presentOverlay(overlay: overlay, animate: animate)
                completion?()
            }
        }
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
            case .fullScreenModal, .popover:
                withAnimation(animation) {
                    showFullScreenPopoverSheet = true
                    displaying = true
                }
            case .notification:
                slideAndFadeIn(offset: -ToastViewUX.height)
            case .sheet, .cheatsheet:
                slideAndFadeIn(offset: OverlaySheetUX.animationOffset)
            case .toast:
                slideAndFadeIn(offset: ToastViewUX.height)
            default:
                withAnimation(animation) {
                    displaying = true
                }
            }
        } else {
            if case .fullScreenModal = overlay {
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
    public func hide(
        overlay: OverlayType,
        animate: Bool = true, showNext: Bool = true, completion: (() -> Void)? = nil
    ) {
        guard let currentOverlay = currentOverlay, currentOverlay == overlay else {
            return
        }

        hideCurrentOverlay(
            ofPriorities: nil, animate: animate, showNext: showNext, completion: completion)
    }

    /// Hides a the current Overlay.
    /// - Parameters:
    ///     - ofPriority: Only hide the current Overlay if it matches this priority.
    public func hideCurrentOverlay(
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
    public func hideCurrentOverlay(
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
            case .sheet, .cheatsheet:
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
}
