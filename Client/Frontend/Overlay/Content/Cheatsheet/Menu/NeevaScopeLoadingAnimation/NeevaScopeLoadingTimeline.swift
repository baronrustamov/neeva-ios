// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Made With Flow.

import Foundation
import Shared
import UIKit

public class NeevaScopeLoadingTimeline: FlowTimeline {
    public convenience init(
        view: NeevaScopeKeyFrameView,
        duration: TimeInterval,
        autoreverses: Bool = true,
        repeatCount: Float = 0
    ) {
        let animationsByLayer = NeevaScopeLoadingTimeline.animationsByLayer(
            view: view, duration: duration)
        self.init(
            view: view, animationsByLayer: animationsByLayer, sounds: [], duration: duration,
            autoreverses: autoreverses, repeatCount: repeatCount)
    }

    private static func animationsByLayer(
        view: NeevaScopeKeyFrameView,
        duration: TimeInterval
    ) -> [CALayer: [CAKeyframeAnimation]] {
        // Keyframe Animations for scope
        let position_x_scope: CAKeyframeAnimation = {
            let keyframeAnimation = CAKeyframeAnimation()
            keyframeAnimation.keyPath = "position.x"
            keyframeAnimation.values = [2.87, 18.66]
            keyframeAnimation.keyTimes = [0, 1]
            keyframeAnimation.timingFunctions = [.easeOut]
            keyframeAnimation.duration = duration

            return keyframeAnimation
        }()
        let position_y_scope: CAKeyframeAnimation = {
            let keyframeAnimation = CAKeyframeAnimation()
            keyframeAnimation.keyPath = "position.y"
            keyframeAnimation.values = [0, -3.74]
            keyframeAnimation.keyTimes = [0, 1]
            keyframeAnimation.timingFunctions = [.easeOut]
            keyframeAnimation.duration = duration

            return keyframeAnimation
        }()
        let transform_rotation_z_scope: CAKeyframeAnimation = {
            let keyframeAnimation = CAKeyframeAnimation()
            keyframeAnimation.keyPath = "transform.rotation.z"
            keyframeAnimation.values = [0, 0.363727]
            keyframeAnimation.keyTimes = [0, 1]
            keyframeAnimation.timingFunctions = [.easeOut]
            keyframeAnimation.duration = duration

            return keyframeAnimation
        }()
        let bounds_size_width_scope: CAKeyframeAnimation = {
            let keyframeAnimation = CAKeyframeAnimation()
            keyframeAnimation.keyPath = "bounds.size.width"
            keyframeAnimation.values = [79.22, 79.23]
            keyframeAnimation.keyTimes = [0, 1]
            keyframeAnimation.timingFunctions = [.easeOut]
            keyframeAnimation.duration = duration

            return keyframeAnimation
        }()

        // Keyframe Animations for glare
        let position_x_glare: CAKeyframeAnimation = {
            let keyframeAnimation = CAKeyframeAnimation()
            keyframeAnimation.keyPath = "position.x"
            keyframeAnimation.values = [54.84, 48.24]
            keyframeAnimation.keyTimes = [0, 1]
            keyframeAnimation.timingFunctions = [.easeOut]
            keyframeAnimation.duration = duration

            return keyframeAnimation
        }()
        let position_y_glare: CAKeyframeAnimation = {
            let keyframeAnimation = CAKeyframeAnimation()
            keyframeAnimation.keyPath = "position.y"
            keyframeAnimation.values = [9.47, 10.25]
            keyframeAnimation.keyTimes = [0, 1]
            keyframeAnimation.timingFunctions = [.easeOut]
            keyframeAnimation.duration = duration

            return keyframeAnimation
        }()
        let transform_rotation_z_glare: CAKeyframeAnimation = {
            let keyframeAnimation = CAKeyframeAnimation()
            keyframeAnimation.keyPath = "transform.rotation.z"
            keyframeAnimation.values = [0.907571, 0.43162]
            keyframeAnimation.keyTimes = [0, 1]
            keyframeAnimation.timingFunctions = [.easeOut]
            keyframeAnimation.duration = duration

            return keyframeAnimation
        }()
        let bounds_size_width_glare: CAKeyframeAnimation = {
            let keyframeAnimation = CAKeyframeAnimation()
            keyframeAnimation.keyPath = "bounds.size.width"
            keyframeAnimation.values = [18.96, 18.03]
            keyframeAnimation.keyTimes = [0, 1]
            keyframeAnimation.timingFunctions = [.easeOut]
            keyframeAnimation.duration = duration

            return keyframeAnimation
        }()
        let bounds_size_height_glare: CAKeyframeAnimation = {
            let keyframeAnimation = CAKeyframeAnimation()
            keyframeAnimation.keyPath = "bounds.size.height"
            keyframeAnimation.values = [7.59, 7.14]
            keyframeAnimation.keyTimes = [0, 1]
            keyframeAnimation.timingFunctions = [.easeOut]
            keyframeAnimation.duration = duration

            return keyframeAnimation
        }()
        let path_glare: CAKeyframeAnimation = {
            let keyframeAnimation = CAKeyframeAnimation()
            keyframeAnimation.keyPath = "path"
            if let pathAnimation1 = CGPathCreateWithSVGString(
                "M0.779,7.319c-0.814,-0.509,-1.023,-1.51,-0.469,-2.249 4.053,-5.303,12.117,-6.664,18.037,-3.045 0.686,0.544,0.813,1.462,0.296,2.141 -0.516,0.679,-1.515,0.906,-2.328,0.529 -2.052,-1.264,-4.58,-1.744,-7.026,-1.333 -2.446,0.411,-4.61,1.678,-6.015,3.523 -0.561,0.731,-1.67,0.924,-2.495,0.435l0,0 0,0zM0.779,7.319"
            ),
                let pathAnimation2 = CGPathCreateWithSVGString(
                    "M0.741,6.886c-0.774,-0.478,-0.973,-1.421,-0.446,-2.116 3.855,-4.988,11.522,-6.269,17.152,-2.865 0.652,0.512,0.773,1.376,0.282,2.014 -0.491,0.638,-1.44,0.852,-2.214,0.498 -1.951,-1.189,-4.355,-1.641,-6.681,-1.254 -2.326,0.386,-4.384,1.579,-5.72,3.314 -0.533,0.688,-1.588,0.87,-2.373,0.409l0,0 0,0zM0.741,6.886"
                )
            {
                keyframeAnimation.values = [pathAnimation1, pathAnimation2]
                keyframeAnimation.keyTimes = [0, 1]
            }
            keyframeAnimation.timingFunctions = [.easeOut]
            keyframeAnimation.duration = duration

            return keyframeAnimation
        }()

        // Organize CAKeyframeAnimations by CALayer
        var animationsByLayer = [CALayer: [CAKeyframeAnimation]]()

        let glareAnimations = [
            position_y_glare,
            bounds_size_height_glare,
            bounds_size_width_glare,
            transform_rotation_z_glare,
            position_x_glare,
            path_glare,
        ]

        let scopeAnimations = [
            position_x_scope,
            bounds_size_width_scope,
            position_y_scope,
            transform_rotation_z_scope,
        ]

        animationsByLayer[view.glare.layer] = glareAnimations.map {
            loopAnimation($0)
        }
        animationsByLayer[view.scope.layer] = scopeAnimations.map {
            loopAnimation($0)
        }

        return animationsByLayer
    }

    private static func loopAnimation(_ animation: CAKeyframeAnimation) -> CAKeyframeAnimation {
        guard let firstKeyFrame = animation.values?.first else { return animation }
        let newAnimation = animation
        newAnimation.values?.append(firstKeyFrame)
        newAnimation.keyTimes = [0, 0.5, 1.0]
        newAnimation.duration *= 2
        return newAnimation
    }
}
