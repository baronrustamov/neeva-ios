// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Shared
import SwiftUI
import UIKit

enum SwipeDirection {
    case forward, back
}

public enum SwipeUX {
    static let EdgeWidth: CGFloat = 30
}

class SimulatedSwipeController:
    UIViewController, TabEventHandler, SimulateForwardAnimatorDelegate
{
    var model: SimulatedSwipeModel
    var animator: SimulatedSwipeAnimator!
    var superview: UIView!
    var blankView: UIView!
    var progressView: UIHostingController<CarouselProgressView>!

    init(model: SimulatedSwipeModel, superview: UIView!) {
        self.model = model
        self.superview = superview
        super.init(nibName: nil, bundle: nil)

        self.animator = SimulatedSwipeAnimator(
            model: model,
            simulatedSwipeControllerView: self.view
        )
        self.animator.delegate = self

        if model.swipeDirection == .forward {
            self.progressView = UIHostingController(
                rootView: CarouselProgressView(model: model.progressModel)
            )
            self.progressView.view.backgroundColor = .clear
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        blankView = UIView()
        blankView.backgroundColor = .white
        self.view.addSubview(blankView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        blankView.makeEdges([.top, .bottom], equalTo: superview)
        blankView.makeWidth(equalTo: superview, withOffset: -SwipeUX.EdgeWidth)

        switch model.swipeDirection {
        case .forward:
            blankView.makeEdges(.trailing, equalTo: self.view)
        case .back:
            blankView.makeEdges(.leading, equalTo: self.view)
        }
    }

    func simulateForwardAnimatorStartedSwipe(_ animator: SimulatedSwipeAnimator) {
        if model.swipeDirection == .forward {
            model.goForward()
        }
    }

    func simulateForwardAnimatorFinishedSwipe(_ animator: SimulatedSwipeAnimator) {
        if model.swipeDirection == .back {
            model.goBack()
        }
    }
}
