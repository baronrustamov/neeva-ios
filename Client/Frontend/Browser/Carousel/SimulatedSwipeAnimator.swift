// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import SwiftUI
import UIKit

struct SimulateForwardAnimationParameters {
    let totalRotationInDegrees: Double
    let deleteThreshold: CGFloat
    let totalScale: CGFloat
    let totalAlpha: CGFloat
    let minExitVelocity: CGFloat
    let recenterAnimationDuration: TimeInterval
    let cancelAnimationDuration: TimeInterval
}

private let DefaultParameters =
    SimulateForwardAnimationParameters(
        totalRotationInDegrees: 10,
        deleteThreshold: 80,
        totalScale: 0.9,
        totalAlpha: 0,
        minExitVelocity: 800,
        recenterAnimationDuration: 0.3,
        cancelAnimationDuration: 0.3)

protocol SimulateForwardAnimatorDelegate: AnyObject {
    func simulateForwardAnimatorStartedSwipe()
    func simulateForwardAnimatorCancelledSwipe()
    func simulateForwardAnimatorFinishedSwipe()
}

class SimulatedSwipeAnimator: NSObject {
    weak var delegate: SimulateForwardAnimatorDelegate?
    weak var simulatedSwipeControllerView: UIView?
    weak var model: SimulatedSwipeModel?

    fileprivate var prevOffset: CGPoint?
    fileprivate let params: SimulateForwardAnimationParameters

    fileprivate var panGestureRecogniser: UIPanGestureRecognizer!

    var containerCenter: CGPoint {
        guard let animatingView = self.animatingView else {
            return .zero
        }
        return CGPoint(x: animatingView.frame.width / 2, y: animatingView.frame.height / 2)
    }

    var contentView: UIView? {
        model?.tabManager.selectedTab?.webView
    }

    var animatingView: UIView? {
        return simulatedSwipeControllerView
    }

    init(
        model: SimulatedSwipeModel, simulatedSwipeControllerView: UIView,
        params: SimulateForwardAnimationParameters = DefaultParameters
    ) {
        self.model = model
        self.params = params
        self.simulatedSwipeControllerView = simulatedSwipeControllerView

        super.init()

        self.panGestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        simulatedSwipeControllerView.addGestureRecognizer(self.panGestureRecogniser)
    }
}

//MARK: Private Helpers
extension SimulatedSwipeAnimator {
    fileprivate func animateBackToCenter(canceledSwipe: Bool) {
        if canceledSwipe {
            self.model?.overlayOffset = 0

            UIView.animate(
                withDuration: params.cancelAnimationDuration,
                animations: {
                    self.contentView?.transform = .identity
                    self.animatingView?.transform = .identity
                },
                completion: { _ in
                    self.delegate?.simulateForwardAnimatorCancelledSwipe()
                })
        } else {
            self.delegate?.simulateForwardAnimatorFinishedSwipe()
            self.contentView?.transform = .identity
            UIView.animate(
                withDuration: params.recenterAnimationDuration,
                animations: {
                    self.animatingView?.alpha = 0
                },
                completion: { finished in
                    if finished {
                        self.animatingView?.transform = .identity
                        self.animatingView?.alpha = 1
                        self.model?.overlayOffset = 0
                    }
                })
        }
    }

    fileprivate func animateAwayWithVelocity(speed: CGFloat) {
        guard let animatingView = self.animatingView else {
            return
        }

        // Calculate the edge to calculate distance from
        let translation =
            (-animatingView.frame.width + SwipeUX.EdgeWidth)
            * (model?.swipeDirection == .back ? -1 : 1)
        let timeStep = TimeInterval(abs(translation) / speed)

        withAnimation(.easeOut(duration: timeStep)) {
            self.model?.overlayOffset = contentView?.frame.width ?? -20
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + timeStep) {
            self.model?.contentOffset = 0

            withAnimation(.easeOut(duration: timeStep)) {
                self.animateBackToCenter(canceledSwipe: false)
            }
        }
    }
}

//MARK: Selectors
extension SimulatedSwipeAnimator {
    @objc func didPan(_ recognizer: UIPanGestureRecognizer!) {
        let translation = recognizer.translation(in: animatingView)

        switch recognizer.state {
        case .began:
            prevOffset = containerCenter
            self.delegate?.simulateForwardAnimatorStartedSwipe()
        case .changed:
            withAnimation {
                model?.overlayOffset = translation.x
            }

            prevOffset = CGPoint(x: translation.x, y: 0)
        case .cancelled:
            animateBackToCenter(canceledSwipe: true)
        case .ended:
            let velocity = recognizer.velocity(in: animatingView).x

            // Bounce back if the velocity is too low or if we have not reached the threshold yet,
            // or if the user swipe backwards.
            let speed = max(abs(velocity), params.minExitVelocity)
            if velocity < 0 || speed < params.minExitVelocity
                || abs(prevOffset?.x ?? 0) < params.deleteThreshold
            {
                animateBackToCenter(canceledSwipe: true)
            } else {
                animateAwayWithVelocity(speed: speed)
            }
        default:
            break
        }
    }
}
