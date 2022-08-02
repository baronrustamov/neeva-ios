/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import SwiftUI
import UIKit

extension UIView {
    // MARK: - Screenshot
    /// Screenshot of entire UIView
    ///
    /// This method draws the entire view by rendering the layer into a CGContext
    var screenshot: UIImage? {
        let rect = self.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        self.layer.render(in: context)
        let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return capturedImage
    }

    // MARK: - Constraints
    func makeAllEdges(equalTo view: UIView?, withOffset offset: CGFloat = 0) {
        makeEdges(.all, equalTo: view, withOffset: offset)
    }

    func makeEdges(_ edges: Edge.Set, equalTo view: UIView?, withOffset offset: CGFloat = 0) {
        guard let view = view else {
            return
        }

        self.translatesAutoresizingMaskIntoConstraints = false

        if edges.contains(.top) {
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: offset)
                .isActive = true
        }

        if edges.contains(.bottom) {
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: offset)
                .isActive = true
        }

        if edges.contains(.leading) {
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: offset)
                .isActive = true
        }

        if edges.contains(.trailing) {
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: offset)
                .isActive = true
        }
    }

    func makeEdges(
        _ edges: Edge.Set, greaterThanOrequalTo view: UIView?, withOffset offset: CGFloat = 0
    ) {
        guard let view = view else {
            return
        }

        self.translatesAutoresizingMaskIntoConstraints = false

        if edges.contains(.top) {
            self.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: offset)
                .isActive = true
        }

        if edges.contains(.bottom) {
            self.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor, constant: offset)
                .isActive = true
        }

        if edges.contains(.leading) {
            self.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor, constant: offset
            )
            .isActive = true
        }

        if edges.contains(.trailing) {
            self.trailingAnchor.constraint(
                greaterThanOrEqualTo: view.trailingAnchor, constant: offset
            )
            .isActive = true
        }
    }

    func makeEdges(
        _ edges: Edge.Set, lessThanOrEqualTo view: UIView?, withOffset offset: CGFloat = 0
    ) {
        guard let view = view else {
            return
        }

        self.translatesAutoresizingMaskIntoConstraints = false

        if edges.contains(.top) {
            self.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor, constant: offset)
                .isActive = true
        }

        if edges.contains(.bottom) {
            self.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: offset)
                .isActive = true
        }

        if edges.contains(.leading) {
            self.leadingAnchor.constraint(lessThanOrEqualTo: view.leadingAnchor, constant: offset)
                .isActive = true
        }

        if edges.contains(.trailing) {
            self.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: offset)
                .isActive = true
        }
    }

    // Width
    func makeWidth(equalTo view: UIView?, withOffset offset: CGFloat = 0) {
        guard let view = view else {
            return
        }

        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalTo: view.widthAnchor, constant: offset).isActive = true
    }

    func makeWidth(equalToConstant value: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: value).isActive = true
    }

    // Height
    func makeHeight(equalToConstant value: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: value).isActive = true
    }

    // Centering
    func makeCenter(equalTo view: UIView?) {
        guard let view = view else {
            return
        }

        makeCenterX(equalTo: view)
        makeCenterY(equalTo: view)
    }

    func makeCenterX(equalTo view: UIView?) {
        guard let view = view else {
            return
        }

        self.translatesAutoresizingMaskIntoConstraints = false
        self.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    func makeCenterY(equalTo view: UIView?) {
        guard let view = view else {
            return
        }

        self.translatesAutoresizingMaskIntoConstraints = false
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

extension View {
    /// Takes a screenshot of the SwiftUI View
    ///
    /// This method lays out the view in a new UIHostingController as large as the view needs
    /// Thus, this method is expensive and does not preserve any states
    /// In addition, environment objects must be passed to the view again
    func takeScreenshot(origin: CGPoint, size: CGSize) -> UIImage? {
        let window = UIWindow(frame: CGRect(origin: origin, size: size))
        let hosting = UIHostingController(rootView: self)
        hosting.view.frame = window.frame
        window.addSubview(hosting.view)
        window.makeKeyAndVisible()
        return hosting.view.screenshot
    }
}

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}
