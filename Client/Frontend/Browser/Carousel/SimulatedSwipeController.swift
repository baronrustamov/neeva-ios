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

enum SwipeUX {
    static let EdgeWidth: CGFloat = 30
}

class SimulatedSwipeController:
    UIViewController, TabEventHandler, SimulateForwardAnimatorDelegate
{
    var model: SimulatedSwipeModel
    var animator: SimulatedSwipeAnimator!
    let blankView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    let targetPreviewView: UIImageView = {
        let view = UIImageView(image: nil)
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        return view
    }()
    var progressView: UIHostingController<CarouselProgressView>!

    init(model: SimulatedSwipeModel) {
        self.model = model
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

        self.view.isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        setupSubviews()
    }

    private func setupSubviews() {
        // Create and connect subviews
        blankView.addSubview(targetPreviewView)
        self.view.addSubview(blankView)

        // Set up layout constraints
        blankView.makeEdges([.top, .bottom], equalTo: self.view)
        blankView.makeWidth(equalTo: self.view, withOffset: -SwipeUX.EdgeWidth)

        targetPreviewView.makeEdges([.top, .bottom], equalTo: blankView)
        targetPreviewView.makeWidth(equalTo: self.view)

        switch model.swipeDirection {
        case .forward:
            blankView.makeEdges(.trailing, equalTo: self.view)
            targetPreviewView.makeEdges(.trailing, equalTo: self.view)
        case .back:
            blankView.makeEdges(.leading, equalTo: self.view)
            targetPreviewView.makeEdges(.leading, equalTo: self.view)
        }
    }

    func simulateForwardAnimatorStartedSwipe() {
        targetPreviewView.isHidden = false
        if model.swipeDirection == .forward {
            model.goForward()
        }
    }

    func simulateForwardAnimatorFinishedSwipe() {
        targetPreviewView.isHidden = true
        if model.swipeDirection == .back {
            model.goBack()
        }
    }

    func simulateForwardAnimatorCancelledSwipe() {
        targetPreviewView.isHidden = true
    }
}
