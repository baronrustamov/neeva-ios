// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import SwiftUI

private let ToolbarBaseAnimationDuration = 0.3

class ScrollingControlModel: NSObject, ObservableObject {
    enum ScrollDirection {
        case up
        case down
    }

    enum ToolbarState {
        case collapsed
        case visible
        case animating
    }

    @Published private(set) var headerTopOffset: CGFloat = 0
    @Published private(set) var footerBottomOffset: CGFloat = 0

    private let chromeModel: TabChromeModel
    private var tab: Tab?

    private(set) var headerHeight: CGFloat = 0
    private(set) var footerHeight: CGFloat = 0

    private var subscriptions: Set<AnyCancellable> = []
    private var tabSubscriptions: Set<AnyCancellable> = []
    private var tabIsLoading = false

    fileprivate var isZoomedOut = false
    fileprivate var lastZoomedScale: CGFloat = 0
    fileprivate var isUserZoom = false

    var controlOpacity: Double {
        let alpha = 1 - abs(headerTopOffset / topScrollHeight)
        return Double(alpha)
    }

    fileprivate lazy var panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        panGesture.allowedScrollTypesMask = .all
        return panGesture
    }()

    fileprivate var scrollView: UIScrollView?
    fileprivate var contentOffset: CGPoint { scrollView?.contentOffset ?? .zero }
    fileprivate var contentSize: CGSize { scrollView?.contentSize ?? .zero }
    fileprivate var scrollViewHeight: CGFloat { scrollView?.frame.height ?? 0 }
    fileprivate var topScrollHeight: CGFloat { return headerHeight }

    fileprivate var lastContentOffset: CGFloat = 0
    fileprivate var scrollDirection: ScrollDirection = .down
    fileprivate var toolbarState: ToolbarState = .visible

    func setupTabDelegates(newTab: Tab?) {
        self.tab = newTab
        self.tabSubscriptions = []

        if let tab = newTab {
            tab.$isLoading
                .assign(to: \.tabIsLoading, on: self)
                .store(in: &self.tabSubscriptions)
        }
    }

    func setupScrollViewDelegate(newScrollView: UIScrollView?) {
        self.scrollView?.delegate = nil
        self.scrollView?.removeGestureRecognizer(self.panGesture)
        self.scrollView = newScrollView

        if let scrollView = newScrollView {
            scrollView.addGestureRecognizer(self.panGesture)
            scrollView.delegate = self
        }
    }

    func setHeaderFooterHeight(header: CGFloat, footer: CGFloat) {
        headerHeight = header
        footerHeight = footer
    }

    func showToolbars(animated: Bool) {
        if toolbarState == .visible {
            return
        }
        toolbarState = .visible
        let durationRatio = abs(headerTopOffset / topScrollHeight)
        let actualDuration = TimeInterval(ToolbarBaseAnimationDuration * durationRatio)
        self.animateToolbarsWithOffsets(
            animated,
            duration: actualDuration,
            headerOffset: 0,
            footerOffset: 0,
            alpha: 1)
    }

    func hideToolbars(animated: Bool) {
        if toolbarState == .collapsed {
            return
        }
        toolbarState = .collapsed
        let durationRatio = abs((topScrollHeight + headerTopOffset) / topScrollHeight)
        let actualDuration = TimeInterval(ToolbarBaseAnimationDuration * durationRatio)
        self.animateToolbarsWithOffsets(
            animated,
            duration: actualDuration,
            headerOffset: -topScrollHeight,
            footerOffset: footerHeight,  // makes sure toolbar is hidden all the way
            alpha: 0)
    }

    func contentSizeDidChange() {
        if !checkScrollHeightIsLargeEnoughForScrolling() && headerTopOffset != 0 {
            showToolbars(animated: true)
        }
    }

    func updateMinimumZoom() {
        guard let scrollView = scrollView else {
            return
        }
        self.isZoomedOut = roundNum(scrollView.zoomScale) == roundNum(scrollView.minimumZoomScale)
        self.lastZoomedScale = self.isZoomedOut ? 0 : scrollView.zoomScale
    }

    func setMinimumZoom() {
        guard let scrollView = scrollView else {
            return
        }
        if self.isZoomedOut
            && roundNum(scrollView.zoomScale) != roundNum(scrollView.minimumZoomScale)
        {
            scrollView.zoomScale = scrollView.minimumZoomScale
        }
    }

    func resetZoomState() {
        self.isZoomedOut = false
        self.lastZoomedScale = 0
    }

    fileprivate func roundNum(_ num: CGFloat) -> CGFloat {
        return round(100 * num) / 100
    }

    // MARK: - init
    init(tabManager: TabManager, chromeModel: TabChromeModel) {
        self.scrollView = tabManager.selectedTab?.webView!.scrollView
        self.chromeModel = chromeModel
        super.init()

        setupTabDelegates(newTab: tabManager.selectedTab)
        setupScrollViewDelegate(newScrollView: tabManager.selectedTab?.webView?.scrollView)

        tabManager.selectedTabPublisher
            .sink { [weak self] newTab in
                guard let self = self else { return }
                self.setupTabDelegates(newTab: newTab)
            }
            .store(in: &subscriptions)

        tabManager.selectedTabWebViewPublisher
            .sink { [weak self] newWebView in
                guard let self = self else { return }
                self.setupScrollViewDelegate(newScrollView: newWebView?.scrollView)
            }
            .store(in: &subscriptions)
    }
}

extension ScrollingControlModel {
    fileprivate var isBouncingAtBottom: Bool {
        guard let scrollView = scrollView else { return false }
        return scrollView.contentOffset.y
            > (scrollView.contentSize.height - scrollView.frame.size.height)
            && scrollView.contentSize.height > scrollView.frame.size.height
    }

    @objc fileprivate func handlePan(_ gesture: UIPanGestureRecognizer) {
        if tabIsLoading {
            return
        }

        if let containerView = scrollView?.superview {
            let translation = gesture.translation(in: containerView)
            let delta = lastContentOffset - translation.y

            if delta > 0 {
                scrollDirection = .down
            } else if delta < 0 {
                scrollDirection = .up
            }

            lastContentOffset = translation.y
            if checkRubberbandingForDelta(delta) && checkScrollHeightIsLargeEnoughForScrolling() {
                let bottomIsNotRubberbanding =
                    contentOffset.y + scrollViewHeight < contentSize.height
                let topIsRubberbanding = contentOffset.y <= 0
                if (toolbarState != .collapsed || topIsRubberbanding) && bottomIsNotRubberbanding {
                    scrollWithDelta(delta)
                }

                if headerTopOffset == -topScrollHeight && footerBottomOffset == footerHeight {
                    toolbarState = .collapsed
                } else if headerTopOffset == 0 && footerBottomOffset == 0 {
                    toolbarState = .visible
                } else {
                    toolbarState = .animating
                }
            }

            if gesture.state == .ended || gesture.state == .cancelled {
                lastContentOffset = 0
            }
        }
    }

    fileprivate func checkRubberbandingForDelta(_ delta: CGFloat) -> Bool {
        return
            !((delta < 0 && contentOffset.y + scrollViewHeight > contentSize.height
            && scrollViewHeight < contentSize.height) || contentOffset.y < delta)
    }

    fileprivate func scrollWithDelta(_ delta: CGFloat) {
        if scrollViewHeight >= contentSize.height {
            return
        }

        var updatedOffset = headerTopOffset - delta
        headerTopOffset = clamp(updatedOffset, min: -topScrollHeight, max: 0)
        if isHeaderDisplayedForGivenOffset(updatedOffset) {
            scrollView?.contentOffset = CGPoint(x: contentOffset.x, y: contentOffset.y - delta)
        }

        updatedOffset = footerBottomOffset + delta
        footerBottomOffset = clamp(updatedOffset, min: 0, max: footerHeight)
    }

    fileprivate func isHeaderDisplayedForGivenOffset(_ offset: CGFloat) -> Bool {
        return offset > -topScrollHeight && offset < 0
    }

    fileprivate func clamp(_ y: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        if y >= max {
            return max
        } else if y <= min {
            return min
        }
        return y
    }

    fileprivate func animateToolbarsWithOffsets(
        _ animated: Bool, duration: TimeInterval, headerOffset: CGFloat, footerOffset: CGFloat,
        alpha: CGFloat
    ) {
        let initialContentOffset = scrollView?.contentOffset ?? CGPoint.zero

        // If this function is used to fully animate the toolbar from hidden to shown, keep the page from scrolling by adjusting contentOffset,
        // Otherwise when the toolbar is hidden and a link navigated, showing the toolbar will scroll the page and
        // produce a ~50px page jumping effect in response to tap navigations.
        let isShownFromHidden = headerTopOffset == -topScrollHeight && headerOffset == 0

        let animation = {
            if isShownFromHidden, let scrollView = self.scrollView {
                scrollView.contentOffset = CGPoint(
                    x: initialContentOffset.x, y: initialContentOffset.y + self.topScrollHeight)
            }
        }

        DispatchQueue.main.async { [self] in
            self.headerTopOffset = headerOffset
            self.footerBottomOffset = footerOffset
            if animated {
                UIView.animate(
                    withDuration: duration, delay: 0, options: .allowUserInteraction,
                    animations: animation, completion: { _ in })
            } else {
                animation()
            }
        }
    }

    fileprivate func checkScrollHeightIsLargeEnoughForScrolling() -> Bool {
        return (UIScreen.main.bounds.size.height + 2 * UIConstants.ToolbarHeight)
            < scrollView?.contentSize.height ?? 0
    }
}

extension ScrollingControlModel: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}

extension ScrollingControlModel: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let helper = chromeModel.topBarDelegate?.tabManager.selectedTab?.getContentScript(
            name: ContextMenuHelper.name())
            as? ContextMenuHelper
        {
            helper.scrollDragStarted()
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let helper = chromeModel.topBarDelegate?.tabManager.selectedTab?.getContentScript(
            name: ContextMenuHelper.name())
            as? ContextMenuHelper
        {
            helper.scrollDragEnded()
        }

        if tabIsLoading || isBouncingAtBottom {
            return
        }

        if (decelerate || (toolbarState == .animating && !decelerate))
            && checkScrollHeightIsLargeEnoughForScrolling()
        {
            if scrollDirection == .up {
                showToolbars(animated: true)
            } else if scrollDirection == .down {
                hideToolbars(animated: true)
            }
        }
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // Only mess with the zoom level if the user did not initate the zoom via a zoom gesture
        if self.isUserZoom {
            return
        }

        // scrollViewDidZoom will be called multiple times when a rotation happens.
        // In that case ALWAYS reset to the minimum zoom level if the previous state was zoomed out (isZoomedOut=true)
        if isZoomedOut {
            scrollView.zoomScale = scrollView.minimumZoomScale
        } else if roundNum(scrollView.zoomScale) > roundNum(self.lastZoomedScale)
            && self.lastZoomedScale != 0
        {
            // When we have manually zoomed in we want to preserve that scale.
            // But sometimes when we rotate a larger zoomScale is appled. In that case apply the lastZoomedScale
            scrollView.zoomScale = self.lastZoomedScale
        }
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        self.isUserZoom = true
        scrollView.refreshControl = nil
    }

    func scrollViewDidEndZooming(
        _ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat
    ) {
        self.isUserZoom = false
        tab?.addRefreshControl()
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        showToolbars(animated: true)
        return true
    }
}
