// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Made With Flow.

import Foundation
import Shared
import UIKit

@IBDesignable
public class NeevaScopeKeyFrameView: UIView {
    public struct Defaults {
        public static let size = CGSize(width: 82.09, height: 74.74)
    }

    public var scope: UIView!
    public var handle: UIView!
    public var lens: FlowShapeView!
    public var glare: FlowShapeView!
    public var body: FlowShapeView!
    public var band: FlowShapeView!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        fillView()
    }

    private func setup() {
        backgroundColor = .clear
        clipsToBounds = false
        createViews()
        addSubviews()
        layer.name = "neevaScopeSceneLayer"
        //scale(to: frame.size)
    }

    private func fillView() {
        // scale subview
        let x = bounds.size.width / Defaults.size.width
        let y = bounds.size.height / Defaults.size.height
        scope.transform = CGAffineTransform(scaleX: x, y: y)
    }

    /// Scales `self` and its subviews to `size`.
    ///
    /// - Parameter size: The size `self` is scaled to.
    ///
    /// UIKit specifies: "In iOS 8.0 and later, the transform property does not affect Auto Layout. Auto layout
    /// calculates a view's alignment rectangle based on its untransformed frame."
    ///
    /// see: https://developer.apple.com/documentation/uikit/uiview/1622459-transform
    ///
    /// If there are any constraints in IB affecting the frame of `self`, this method will have consequences on
    /// layout / rendering. To properly scale an animation, you will have to position the view manually.
    public func scale(to size: CGSize) {
        let x = size.width / Defaults.size.width
        let y = size.height / Defaults.size.height
        transform = CGAffineTransform(scaleX: x, y: y)
    }

    private func createViews() {
        CATransaction.suppressAnimations {
            createScope()
            createHandle()
            createLens()
            createGlare()
            createBody()
            createBand()
        }
    }

    private func createScope() {
        scope = UIView(frame: CGRect(x: 2.87, y: 0, width: 79.22, height: 72.56))
        scope.backgroundColor = UIColor.clear
        scope.layer.anchorPoint = CGPoint(x: 0, y: 0)
        scope.layer.shadowOffset = CGSize(width: 0, height: 0)
        scope.layer.borderWidth = 1
        scope.layer.borderColor = UIColor.clear.cgColor
        scope.layer.name = "scope"
        scope.layer.shadowColor = UIColor.clear.cgColor
        scope.layer.shadowOpacity = 1
        scope.layer.position = CGPoint(x: 2.87, y: 0)
        scope.layer.bounds = CGRect(x: 0, y: 0, width: 79.22, height: 72.56)
        scope.layer.masksToBounds = false

    }

    private func createHandle() {
        handle = UIView(frame: CGRect(x: 0, y: 14.5, width: 60.24, height: 58.06))
        handle.backgroundColor = UIColor.clear
        handle.layer.anchorPoint = CGPoint(x: 0, y: 0)
        handle.layer.shadowOffset = CGSize(width: 0, height: 0)
        handle.layer.borderWidth = 1
        handle.layer.borderColor = UIColor.clear.cgColor
        handle.layer.name = "handle"
        handle.layer.shadowColor = UIColor.clear.cgColor
        handle.layer.shadowOpacity = 1
        handle.layer.position = CGPoint(x: 0, y: 14.5)
        handle.layer.bounds = CGRect(x: 0, y: 0, width: 60.24, height: 58.06)
        handle.layer.masksToBounds = false

    }

    private func createLens() {
        lens = FlowShapeView(frame: CGRect(x: 55.14, y: 0, width: 39.12, height: 34.38))
        lens.backgroundColor = UIColor.clear
        lens.layer.anchorPoint = CGPoint(x: 0, y: 0)
        lens.transform = CGAffineTransform(rotationAngle: 0.288889 * CGFloat.pi)
        lens.layer.shadowOffset = CGSize(width: 0, height: 0)
        lens.layer.borderColor = UIColor.clear.cgColor
        lens.layer.name = "lens"
        lens.layer.shadowColor = UIColor.clear.cgColor
        lens.layer.shadowOpacity = 1
        lens.layer.position = CGPoint(x: 55.14, y: 0)
        lens.layer.bounds = CGRect(x: 0, y: 0, width: 39.12, height: 34.38)
        lens.layer.masksToBounds = false
        lens.shapeLayer.name = "lens.shapeLayer"
        lens.shapeLayer.fillRule = CAShapeLayerFillRule.evenOdd
        lens.shapeLayer.fillColor = UIColor(red: 0.255, green: 0.353, blue: 1, alpha: 1).cgColor
        lens.shapeLayer.miterLimit = 4
        lens.shapeLayer.lineDashPattern = []
        lens.shapeLayer.lineDashPhase = 0
        lens.shapeLayer.lineWidth = 0
        if let path = CGPathCreateWithSVGString(
            "M3.414,7.489c6.096,-7.837,18.267,-9.846,27.184,-4.489 8.916,5.358,11.202,16.053,5.108,23.89 -6.096,7.837,-18.267,9.846,-27.185,4.489 -8.917,-5.358,-11.204,-16.053,-5.108,-23.89l0,0zM7.351,9.802c-4.584,5.895,-2.865,13.94,3.842,17.97l0,-0.008c3.222,1.939,7.19,2.673,11.028,2.039 3.838,-0.634,7.232,-2.582,9.434,-5.417 4.579,-5.898,2.853,-13.941,-3.857,-17.968 -6.71,-4.027,-15.863,-2.512,-20.447,3.383l0,0zM7.351,9.802"
        ) {
            lens.shapeLayer.path = path
        }

    }

    private func createGlare() {
        glare = FlowShapeView(frame: CGRect(x: 54.84, y: 9.47, width: 18.96, height: 7.59))
        glare.backgroundColor = UIColor.clear
        glare.layer.anchorPoint = CGPoint(x: 0, y: 0)
        glare.transform = CGAffineTransform(rotationAngle: 0.288889 * CGFloat.pi)
        glare.layer.shadowOffset = CGSize(width: 0, height: 0)
        glare.layer.borderColor = UIColor.clear.cgColor
        glare.layer.name = "glare"
        glare.layer.shadowColor = UIColor.clear.cgColor
        glare.layer.shadowOpacity = 1
        glare.layer.position = CGPoint(x: 54.84, y: 9.47)
        glare.layer.bounds = CGRect(x: 0, y: 0, width: 18.96, height: 7.59)
        glare.layer.masksToBounds = false
        glare.shapeLayer.name = "glare.shapeLayer"
        glare.shapeLayer.fillRule = CAShapeLayerFillRule.evenOdd
        glare.shapeLayer.fillColor = UIColor(red: 0.451, green: 0.659, blue: 1, alpha: 1).cgColor
        glare.shapeLayer.miterLimit = 4
        glare.shapeLayer.lineDashPattern = []
        glare.shapeLayer.lineDashPhase = 0
        glare.shapeLayer.lineWidth = 0.63
        if let path = CGPathCreateWithSVGString(
            "M0.779,7.319c-0.814,-0.509,-1.023,-1.51,-0.469,-2.249 4.053,-5.303,12.117,-6.664,18.037,-3.045 0.686,0.544,0.813,1.462,0.296,2.141 -0.516,0.679,-1.515,0.906,-2.328,0.529 -2.052,-1.264,-4.58,-1.744,-7.026,-1.333 -2.446,0.411,-4.61,1.678,-6.015,3.523 -0.561,0.731,-1.67,0.924,-2.495,0.435l0,0 0,0zM0.779,7.319"
        ) {
            glare.shapeLayer.path = path
        }

    }

    private func createBody() {
        body = FlowShapeView(frame: CGRect(x: 38.14, y: 0, width: 36.5, height: 47.93))
        body.backgroundColor = UIColor.clear
        body.layer.anchorPoint = CGPoint(x: 0, y: 0)
        body.transform = CGAffineTransform(rotationAngle: 0.293 * CGFloat.pi)
        body.layer.shadowOffset = CGSize(width: 0, height: 0)
        body.layer.borderColor = UIColor.clear.cgColor
        body.layer.name = "body"
        body.layer.shadowColor = UIColor.clear.cgColor
        body.layer.shadowOpacity = 1
        body.layer.position = CGPoint(x: 38.14, y: 0)
        body.layer.bounds = CGRect(x: 0, y: 0, width: 36.5, height: 47.93)
        body.layer.masksToBounds = false
        body.shapeLayer.name = "body.shapeLayer"
        body.shapeLayer.fillRule = CAShapeLayerFillRule.evenOdd
        body.shapeLayer.fillColor = UIColor(red: 0.255, green: 0.353, blue: 1, alpha: 1).cgColor
        body.shapeLayer.miterLimit = 4
        body.shapeLayer.lineDashPattern = []
        body.shapeLayer.lineDashPhase = 0
        body.shapeLayer.lineWidth = 0
        if let path = CGPathCreateWithSVGString(
            "M17.035,9.818l19.465,-9.067 -14.415,45.008c-0.424,1.439,-2.017,2.171,-3.247,2.171 -1.23,0,-2.878,-0.848,-3.413,-2.57l-15.425,-45.36 17.035,9.818 0,0zM17.035,9.818"
        ) {
            body.shapeLayer.path = path
        }

    }

    private func createBand() {
        band = FlowShapeView(frame: CGRect(x: 31.64, y: 0, width: 28, height: 32.57))
        band.backgroundColor = UIColor.clear
        band.layer.anchorPoint = CGPoint(x: 0, y: 0)
        band.layer.shadowOffset = CGSize(width: 0, height: 0)
        band.layer.borderColor = UIColor.clear.cgColor
        band.layer.name = "band"
        band.layer.shadowColor = UIColor.clear.cgColor
        band.layer.shadowOpacity = 1
        band.layer.position = CGPoint(x: 31.64, y: 0)
        band.layer.bounds = CGRect(x: 0, y: 0, width: 28, height: 32.57)
        band.layer.masksToBounds = false
        band.shapeLayer.name = "band.shapeLayer"
        band.shapeLayer.fillRule = CAShapeLayerFillRule.evenOdd
        band.shapeLayer.fillColor = UIColor(red: 0.451, green: 0.659, blue: 1, alpha: 1).cgColor
        band.shapeLayer.miterLimit = 4
        band.shapeLayer.lineDashPattern = []
        band.shapeLayer.lineDashPhase = 0
        band.shapeLayer.lineWidth = 0
        if let path = CGPathCreateWithSVGString(
            "M19.267,32.57c-3.348,-0.434,-6.648,-1.643,-9.626,-3.679 -6.607,-4.516,-9.996,-11.98,-9.611,-19.426l6.471,-9.464 0.239,1.863c-4.538,7.935,-2.287,18.155,5.389,23.405l0,-0.011c3.848,2.635,8.578,3.645,13.164,2.815l2.708,1.425 -8.733,3.072 0,0zM19.267,32.57"
        ) {
            band.shapeLayer.path = path
        }

    }

    private func addSubviews() {
        handle.addSubview(body)
        handle.addSubview(band)
        scope.addSubview(handle)
        scope.addSubview(lens)
        scope.addSubview(glare)
        addSubview(scope)
    }
}
