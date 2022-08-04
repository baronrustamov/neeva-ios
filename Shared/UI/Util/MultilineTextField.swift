// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
//  Source: https://stackoverflow.com/a/58639072/5244995
//  Modified to remove auto-first-responder behavior and to set a minimum height
//

import SwiftUI
import UIKit

/// A multi-line text field.
struct MultilineTextField: View {
    private let placeholder: LocalizedStringKey
    private let onCommit: (() -> Void)?
    private let customize: (UITextView) -> Void

    @Binding private var text: String
    private var internalText: Binding<String> {
        Binding<String>(
            get: { self.text },
            set: {
                self.text = $0
                self.showingPlaceholder = $0.isEmpty
            }
        )
    }

    let focusTextField: Bool

    @State private var dynamicHeight: CGFloat = 80
    @State private var showingPlaceholder = false
    @Environment(\.isEnabled) private var isEnabled

    /// - Parameters:
    ///   - placeholder: the placeholder to display when no text has been entered
    ///   - text: a binding to the content of the text field
    ///   - onCommit: if non-nil, the user will not be able to manually enter multiple lines (although text can still wrap)
    ///     and pressing the return key will cause `onCommit` to be called.
    init(
        _ placeholder: LocalizedStringKey = "", text: Binding<String>, focusTextField: Bool,
        onCommit: (() -> Void)? = nil,
        customize: @escaping (UITextView) -> Void = { _ in }
    ) {
        self.placeholder = placeholder
        self.focusTextField = focusTextField
        self.onCommit = onCommit
        self.customize = customize
        self._text = text
        self._showingPlaceholder = State<Bool>(initialValue: self.text.isEmpty)
    }

    var body: some View {
        UITextViewWrapper(
            text: self.internalText, calculatedHeight: $dynamicHeight, isEnabled: isEnabled,
            onDone: onCommit, customize: customize, focusTextField: focusTextField
        )
        .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
        .background(placeholderView, alignment: .topLeading)
        .accessibilityHint(placeholder)
    }

    var placeholderView: some View {
        Group {
            if showingPlaceholder {
                Text(placeholder)
                    .foregroundColor(Color(UIColor.placeholderText))
                    .padding(.leading, 4)
                    .padding(.top, 8)
                    .accessibilityHidden(true)
            }
        }
    }
}

private struct UITextViewWrapper: UIViewRepresentable {
    typealias UIViewType = UITextView

    @Binding var text: String
    @Binding var calculatedHeight: CGFloat
    let isEnabled: Bool
    let onDone: (() -> Void)?
    let customize: (UITextView) -> Void
    let focusTextField: Bool

    func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
        let textField = UITextView()
        textField.delegate = context.coordinator

        if focusTextField {
            textField.becomeFirstResponder()
        }

        textField.isEditable = true
        // TODO(jed): set font to .bodyLarge
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.isSelectable = true
        textField.isUserInteractionEnabled = true
        textField.isScrollEnabled = false
        textField.backgroundColor = UIColor.clear
        if nil != onDone {
            textField.returnKeyType = .done
        }
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        customize(textField)

        return textField
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<UITextViewWrapper>)
    {
        if uiView.text != self.text {
            uiView.text = self.text
        }
        uiView.isEditable = isEnabled
        UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight)
    }

    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(
            CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = max(80, newSize.height)  // !! must be called asynchronously
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, height: $calculatedHeight, onDone: onDone)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var calculatedHeight: Binding<CGFloat>
        var onDone: (() -> Void)?

        init(text: Binding<String>, height: Binding<CGFloat>, onDone: (() -> Void)? = nil) {
            self.text = text
            self.calculatedHeight = height
            self.onDone = onDone
        }

        func textViewDidChange(_ uiView: UITextView) {
            text.wrappedValue = uiView.text
            UITextViewWrapper.recalculateHeight(view: uiView, result: calculatedHeight)
        }

        func textView(
            _ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String
        ) -> Bool {
            if let onDone = self.onDone, text == "\n" {
                textView.resignFirstResponder()
                onDone()
                return false
            }
            return true
        }
    }

}
