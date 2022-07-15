// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct SimulatedSwipeViewRepresentable: UIViewControllerRepresentable {
    @ObservedObject var model: SimulatedSwipeModel
    @ObservedObject var progressModel: CarouselProgressModel
    let superview: UIView!

    class Coordinator: NSObject {
        weak var vc: SimulatedSwipeController?

        func setPreviewImage(_ uiImage: UIImage?) {
            vc?.targetPreviewView.image = uiImage
        }

        func removeProgressViewFromHierarchy() {
            guard let vc = vc else {
                return
            }

            vc.progressView.view.removeFromSuperview()
            vc.progressView.removeFromParent()
        }

        func addProgressView(to bvc: BrowserViewController) {
            guard let vc = vc else {
                return
            }

            bvc.addChild(vc.progressView)
            bvc.view.addSubviews(vc.progressView.view)
            vc.progressView.didMove(toParent: bvc)
        }

        func makeProgressViewConstraints() {
            guard let vc = vc else {
                return
            }

            vc.progressView.view.makeEdges(
                [.leading, .trailing],
                equalTo: vc.view.superview
            )
            vc.progressView.view.makeEdges(
                .bottom,
                equalTo: vc.view,
                withOffset: -UIConstants.BottomToolbarHeight
            )
        }
    }

    init(model: SimulatedSwipeModel, superview: UIView!) {
        self.model = model
        self.progressModel = model.progressModel
        self.superview = superview
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> SimulatedSwipeController {
        let simulatedSwipeController = SimulatedSwipeController(model: model, superview: superview)
        model.coordinator = context.coordinator
        context.coordinator.vc = simulatedSwipeController

        return simulatedSwipeController
    }

    func updateUIViewController(
        _ uiViewController: SimulatedSwipeController,
        context: Context
    ) {
        uiViewController.view.isHidden = model.hidden
    }
}
