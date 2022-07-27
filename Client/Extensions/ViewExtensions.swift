// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct ThrobbingHighlightBorder: ViewModifier {
    // animation effect
    @State var isAtMaxScale = false
    @Environment(\.colorScheme) private var colorScheme

    private let animation = Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)
    var highlight: Color = Color.blue
    var staticColorMode: Bool

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(highlight, lineWidth: 4)
                    .padding([.horizontal, .vertical], -8)
                    .opacity(Double(2 - (isAtMaxScale ? 1.5 : 1.0)))
                    .scaleEffect(isAtMaxScale ? 1.05 : 1.0)
                    .colorScheme(staticColorMode ? .light : colorScheme)
                    .onAppear {
                        withAnimation(
                            self.animation,
                            {
                                self.isAtMaxScale.toggle()
                            })
                    }
            )
    }
}

extension View {
    public func throbbingHighlightBorderStyle(highlight: Color, staticColorMode: Bool? = false)
        -> some View
    {
        self.modifier(
            ThrobbingHighlightBorder(highlight: highlight, staticColorMode: staticColorMode!))
    }
}

extension View {
    /// Inspired by React’s `useEffect` hook, this modifier calls `perform(deps)` both `onAppear` and whenever `deps` changes.
    func useEffect<T: Equatable>(deps: T, perform updater: @escaping (T) -> Void) -> some View {
        self.onChange(of: deps, perform: updater)
            .onAppear { updater(deps) }
    }
    /// Inspired by React’s `useEffect` hook, this modifier calls `perform(deps)` both `onAppear` and whenever `deps` changes.
    func useEffect<T0: Equatable, T1: Equatable>(
        deps zero: T0, _ one: T1, perform updater: @escaping (T0, T1) -> Void
    ) -> some View {
        self.onChange(of: Pair(zero: zero, one: one)) { updater($0.zero, $0.one) }
            .onAppear { updater(zero, one) }
    }

    func useEffect<T0: Equatable, T1: Equatable, T2: Equatable>(
        deps zero: T0, _ one: T1, _ two: T2, perform updater: @escaping (T0, T1, T2) -> Void
    ) -> some View {
        self.onChange(of: Tuple(zero: zero, one: one, two: two)) {
            updater($0.zero, $0.one, $0.two)
        }
        .onAppear { updater(zero, one, two) }
    }
}

private struct Pair<T0: Equatable, T1: Equatable>: Equatable {
    let zero: T0, one: T1
}

private struct Tuple<T0: Equatable, T1: Equatable, T2: Equatable>: Equatable {
    let zero: T0, one: T1, two: T2
}

extension View {
    func onHeightOfViewChanged(perform updater: @escaping (CGFloat) -> Void) -> some View {
        self
            .background(
                GeometryReader { geom in
                    Color.clear
                        .useEffect(deps: geom.size.height) { height in
                            updater(height)
                        }
                }
            )
    }

    func onSizeOfViewChanged(perform updater: @escaping (CGSize) -> Void) -> some View {
        self
            .background(
                GeometryReader { geom in
                    Color.clear
                        .useEffect(deps: geom.size) { size in
                            updater(size)
                        }
                }
            )
    }

    func safeAreaChanged(perform updater: @escaping (EdgeInsets) -> Void) -> some View {
        self
            .background(
                GeometryReader { geom in
                    Color.clear
                        .useEffect(deps: geom.safeAreaInsets) { insets in
                            updater(insets)
                        }
                }
            )
    }
}

extension View {
    func textFieldAlert(
        isPresented: Binding<Bool>, title: String?, message: String? = nil, required: Bool = true,
        saveAction: String = "Save", onCommit: @escaping (String) -> Void,
        configureTextField: @escaping (UITextField) -> Void
    ) -> some View {
        modifier(
            TextFieldAlert(
                isPresented: isPresented, title: title, message: message, required: required,
                saveAction: saveAction, onCommit: onCommit, configureTextField: configureTextField))
    }
}

private struct TextFieldAlert: ViewModifier {
    @Binding var isPresented: Bool
    let title: String?
    let message: String?
    let required: Bool
    let saveAction: String
    let onCommit: (String) -> Void
    let configureTextField: (UITextField) -> Void

    @State private var viewRef: UIView?

    func body(content: Content) -> some View {
        content
            .uiViewRef($viewRef)
            .onChange(of: isPresented) { newValue in
                if newValue {
                    let alert = UIAlertController(
                        title: title, message: message, preferredStyle: .alert)

                    let saveAction = UIAlertAction(title: saveAction, style: .default) { _ in
                        onCommit(alert.textFields!.first!.text!)
                        isPresented = false
                    }
                    alert.addAction(saveAction)

                    alert.addAction(
                        UIAlertAction(
                            title: "Cancel", style: .cancel, handler: { _ in isPresented = false }))

                    alert.addTextField { tf in
                        tf.returnKeyType = .done
                        tf.addAction(
                            UIAction { _ in
                                saveAction.accessibilityActivate()
                            }, for: .primaryActionTriggered)

                        if required {
                            tf.addAction(
                                UIAction { _ in
                                    saveAction.isEnabled = tf.hasText
                                }, for: .editingChanged)
                        }

                        configureTextField(tf)
                    }

                    viewRef!.window!.windowScene!.frontViewController!
                        .present(alert, animated: true, completion: nil)
                }
            }
    }
}

extension View {
    func visibleStateChanged(onChange: @escaping (Bool) -> Void) -> some View {
        self.onAppear { onChange(true) }
            .onDisappear { onChange(false) }
    }
}
