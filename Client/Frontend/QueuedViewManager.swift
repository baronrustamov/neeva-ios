// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI
import UIKit

public enum QueuedViewLocation {
    case first
    case last
}

open class QueuedViewManager<View: SwiftUI.View>: ObservableObject {
    /// For use with BrowserView only
    let overlayManager: OverlayManager
    var queuedViews = [View]()

    let animationTime = 0.5
    var currentView: View?
    var currentViewTimer: Timer?
    var currentViewIsDragging = false

    func enqueue(view: View, at location: QueuedViewLocation = .last) {
        switch location {
        case .first:
            queuedViews.insert(view, at: 0)
        case .last:
            queuedViews.append(view)
        }

        // if no other Views are lined up, present the one just created
        if queuedViews.count == 1 {
            present(view)
        }
    }

    /// Removes all queued View views, and immediately displays the requested View
    func clearQueueAndDisplay(_ view: View) {
        queuedViews.removeAll()

        if currentView != nil {
            dismissCurrentView(moveToNext: false, overrideDrag: true)

            DispatchQueue.main.asyncAfter(deadline: .now() + animationTime) {
                self.present(view)
            }
        } else {
            present(view)
        }
    }

    /// Sets the current view. This function should be overridden and `present` should
    /// be implemented by the inheriting class or the view won't show.
    func present(_ view: View) {
        currentView = view
    }

    func startViewDismissTimer(for view: View) {
        currentViewTimer = Timer.scheduledTimer(
            withTimeInterval: getDisplayTime(for: view), repeats: false,
            block: { _ in
                self.dismissCurrentView()
            })
    }

    func dismissCurrentView(
        moveToNext: Bool = true, overrideDrag: Bool = false, animate: Bool = true
    ) {
        guard !currentViewIsDragging || overrideDrag else {
            return
        }

        currentViewTimer?.invalidate()
        hideOverlay(animate: animate)

        self.currentView = nil
        self.currentViewTimer = nil
        self.currentViewIsDragging = false

        DispatchQueue.main.asyncAfter(deadline: .now() + animationTime) {
            if moveToNext {
                self.nextView()
            }
        }
    }

    func hideOverlay(animate: Bool) {
        overlayManager.hideCurrentOverlay(ofPriority: .transient, animate: animate)
    }

    /// Presents the next queued View if it exists
    func nextView() {
        if queuedViews.count > 0 {
            queuedViews.removeFirst()

            if let nextView = queuedViews.first {
                present(nextView)
            }
        }
    }

    func getDisplayTime(for view: View) -> Double {
        return ToastViewUX.defaultDisplayTime
    }

    init(overlayManager: OverlayManager) {
        self.overlayManager = overlayManager
    }
}

// MARK: QueuedViewManager
extension QueuedViewManager: BannerViewDelegate {
    func draggingUpdated() {
        currentViewIsDragging = true
    }

    func draggingEnded(dismissing: Bool) {
        currentViewIsDragging = false

        if dismissing || !(currentViewTimer?.isValid ?? true) {
            dismissCurrentView(animate: !dismissing)
        }
    }

    func dismiss() {
        dismissCurrentView()
    }
}
