/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Combine
import UIKit

/// The keyboard state at the time of notification.
public struct KeyboardState {
    public let animationDuration: Double
    public let animationCurve: UIView.AnimationOptions
    private let userInfo: [AnyHashable: Any]

    fileprivate init(_ userInfo: [AnyHashable: Any]) {
        self.userInfo = userInfo
        animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        // HACK: UIViewAnimationCurve doesn't expose the keyboard animation used (curveValue = 7),
        // so UIViewAnimationCurve(rawValue: curveValue) returns nil. As a workaround, get a
        // reference to an EaseIn curve, then change the underlying pointer data with that ref.
        var curve = UIView.AnimationOptions.curveEaseIn
        if let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int {
            NSNumber(value: curveValue as Int).getValue(&curve)
        }

        self.animationCurve = curve
    }

    /// Return the height of the keyboard that overlaps with the specified view. This is more
    /// accurate than simply using the height of UIKeyboardFrameBeginUserInfoKey since for example
    /// on iPad the overlap may be partial or if an external keyboard is attached, the intersection
    /// height will be zero. (Even if the height of the *invisible* keyboard will look normal!)
    public func intersectionHeightForView(_ view: UIView) -> CGFloat {
        if let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardFrame = keyboardFrameValue.cgRectValue
            let convertedKeyboardFrame = view.convert(keyboardFrame, from: nil)
            let intersection = convertedKeyboardFrame.intersection(view.bounds)
            return intersection.size.height
        }

        return 0
    }

    public func animateAlongside(_ animations: @escaping () -> Void) {
        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve) {
            animations()
        }
    }
}

public protocol KeyboardHelperDelegate: AnyObject {
    func keyboardHelper(
        _ keyboardHelper: KeyboardHelper, keyboardWillShowWithState state: KeyboardState)
    func keyboardHelper(
        _ keyboardHelper: KeyboardHelper, keyboardDidShowWithState state: KeyboardState)
    func keyboardHelper(
        _ keyboardHelper: KeyboardHelper, keyboardWillHideWithState state: KeyboardState)
    func keyboardHelper(
        _ keyboardHelper: KeyboardHelper, keyboardDidHideWithState state: KeyboardState)
}

/// Convenience class for observing keyboard state.
open class KeyboardHelper: NSObject, ObservableObject {
    @Published public var keyboardVisible = false
    open var currentState: KeyboardState?

    fileprivate var delegates = [WeakKeyboardDelegate]()
    private var cancellables = [AnyCancellable]()

    public static let keyboardAnimationTime = 0.3

    open class var defaultHelper: KeyboardHelper {
        struct Singleton {
            static let instance = KeyboardHelper()
        }
        return Singleton.instance
    }

    /// Starts monitoring the keyboard state.
    open func startObserving() {
        func transform(_ notification: Notification) -> KeyboardState? {
            if let userInfo = notification.userInfo {
                return KeyboardState(userInfo)
            }
            return nil
        }

        // We never clear out cancellables because this function is
        // only called once.
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap(transform)
            .sink(receiveValue: keyboardWillShow(_:))
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: UIResponder.keyboardDidShowNotification)
            .compactMap(transform)
            .sink(receiveValue: keyboardDidShow(_:))
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .compactMap(transform)
            .sink(receiveValue: keyboardWillHide(_:))
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: UIResponder.keyboardDidHideNotification)
            .compactMap(transform)
            .sink(receiveValue: keyboardDidHide(_:))
            .store(in: &cancellables)
    }

    /// Adds a delegate to the helper.
    /// Delegates are weakly held.
    open func addDelegate(_ delegate: KeyboardHelperDelegate) {
        // Reuse any existing slots that have been deallocated.
        for weakDelegate in delegates where weakDelegate.delegate == nil {
            weakDelegate.delegate = delegate
            return
        }

        delegates.append(WeakKeyboardDelegate(delegate))
    }

    private func keyboardWillShow(_ currentState: KeyboardState) {
        keyboardVisible = true
        delegates.forEach {
            $0.delegate?.keyboardHelper(self, keyboardWillShowWithState: currentState)
        }
    }

    private func keyboardDidShow(_ currentState: KeyboardState) {
        delegates.forEach {
            $0.delegate?.keyboardHelper(self, keyboardDidShowWithState: currentState)
        }
    }

    private func keyboardWillHide(_ currentState: KeyboardState) {
        delegates.forEach {
            $0.delegate?.keyboardHelper(self, keyboardWillHideWithState: currentState)
        }
    }

    private func keyboardDidHide(_ currentState: KeyboardState) {
        keyboardVisible = false
        delegates.forEach {
            $0.delegate?.keyboardHelper(self, keyboardDidHideWithState: currentState)
        }
    }
}

private class WeakKeyboardDelegate {
    weak var delegate: KeyboardHelperDelegate?

    init(_ delegate: KeyboardHelperDelegate) {
        self.delegate = delegate
    }
}
