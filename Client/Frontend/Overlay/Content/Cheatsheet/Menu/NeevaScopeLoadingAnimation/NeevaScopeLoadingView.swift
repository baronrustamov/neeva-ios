// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Made With Flow.

import Foundation
import Shared
import SwiftUI
import UIKit

public class NeevaScopeLoadingViewController: UIViewController {
    var neevaScopeView: NeevaScopeKeyFrameView!
    var timeline: FlowTimeline!

    public override func loadView() {
        view = UIView()

        neevaScopeView = NeevaScopeKeyFrameView()
        neevaScopeView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(neevaScopeView)

        let constraints = [
            neevaScopeView.topAnchor.constraint(equalTo: view.topAnchor),
            neevaScopeView.leftAnchor.constraint(equalTo: view.leftAnchor),
            neevaScopeView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            neevaScopeView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Make this a real indefinite loop and auto reverse
        timeline = NeevaScopeLoadingTimeline(view: neevaScopeView, duration: 0.8, repeatCount: 100)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        timeline.reset { timeline in
            timeline.play()
        }
    }
}

final public class NeevaScopeLoadingController: UIViewControllerRepresentable {
    public func makeUIViewController(context: Context) -> NeevaScopeLoadingViewController {
        let vc = NeevaScopeLoadingViewController()
        return vc
    }

    public func updateUIViewController(
        _ uiViewController: NeevaScopeLoadingViewController, context: Context
    ) {
    }
}

public struct NeevaScopeLoadingView: View {
    public var body: some View {
        NeevaScopeLoadingController()
    }
}
