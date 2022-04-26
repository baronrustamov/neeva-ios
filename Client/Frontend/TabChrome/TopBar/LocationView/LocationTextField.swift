/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

// This code is loosely based on https://github.com/Antol/APAutocompleteTextField

import Combine
import Shared
import SwiftUI

private let log = Logger.browser

/// The text field used to edit the location.
struct LocationTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var editing: Bool
    let onSubmit: (String) -> Void

    @EnvironmentObject private var suggestionModel: SuggestionModel

    func makeUIView(context: Context) -> AutocompleteTextField {
        let tf = AutocompleteTextField(onSubmit: onSubmit, suggestionModel: suggestionModel)

        tf.font = UIFont.systemFont(ofSize: 16)
        tf.backgroundColor = .clear
        tf.adjustsFontForContentSizeCategory = true
        tf.clipsToBounds = true
        tf.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tf.keyboardType = .webSearch
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.returnKeyType = .go
        tf.clearButtonMode = .whileEditing
        tf.textAlignment = .left
        tf.accessibilityIdentifier = "address"
        tf.accessibilityLabel = .URLBarLocationAccessibilityLabel
        tf.enablesReturnKeyAutomatically = true
        tf.attributedPlaceholder =
            NSAttributedString(
                string: .TabLocationURLPlaceholder,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel])

        tf.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        DispatchQueue.main.async {
            tf.becomeFirstResponder()
        }
        tf.text = text

        return tf
    }

    func updateUIView(_ tf: AutocompleteTextField, context: Context) {
        DispatchQueue.main.async {
            tf.onSubmit = onSubmit

            if tf.text != text {
                tf.text = text
            }

            if !editing {
                tf.resignFirstResponder()
            }
        }
    }
}

class AutocompleteTextField: UITextField, UITextFieldDelegate {
    var onSubmit: (String) -> Void

    private var suggestionModel: SuggestionModel

    private let copyShortcutKey = "c"
    fileprivate var defaultTint = UIColor.ui.adaptive.blue
    private var subscription: AnyCancellable?

    override var accessibilityValue: String? {
        get {
            return (self.text ?? "") + (suggestionModel.completion ?? "")
        }
        set(value) {
            super.accessibilityValue = value
        }
    }

    override var accessibilityHint: String? {
        get {
            if suggestionModel.completion != nil {
                let deleteLabel = "Press delete to remove autocomplete suggestion"
                if let hint = super.accessibilityHint {
                    return "\(hint), \(deleteLabel)"
                } else {
                    return deleteLabel
                }
            }
            return super.accessibilityHint
        }
        set { super.accessibilityHint = newValue }
    }

    init(onSubmit: @escaping (String) -> Void, suggestionModel: SuggestionModel) {
        self.onSubmit = onSubmit
        self.suggestionModel = suggestionModel
        super.init(frame: .zero)
        super.delegate = self

        self.addAction(
            UIAction { [weak self] _ in
                guard let self = self, let text = self.text else { return }
                self.suggestionModel.queryModel.value = text
            }, for: .editingChanged)

        subscription = suggestionModel.$completion
            .removeDuplicates()
            .sink { [weak self] completion in
                guard let self = self else { return }

                if completion != nil, self.isEditing, self.markedTextRange == nil {
                    self.tintColor = self.defaultTint.withAlphaComponent(0)
                } else {
                    self.tintColor = self.defaultTint
                }
            }
        tintColor =
            suggestionModel.queryModel.value.isEmpty
            ? defaultTint : defaultTint.withAlphaComponent(0)
        self.text = suggestionModel.queryModel.value
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTextRange = textRange(from: beginningOfDocument, to: endOfDocument)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var keyCommands: [UIKeyCommand]? {
        let arrowCommands = [
            UIKeyCommand(
                input: UIKeyCommand.inputLeftArrow, modifierFlags: [],
                action: #selector(self.handleKeyCommand(sender:))),
            UIKeyCommand(
                input: UIKeyCommand.inputRightArrow, modifierFlags: [],
                action: #selector(self.handleKeyCommand(sender:))),
        ]

        if #available(iOS 15.0, *) {
            for command in arrowCommands {
                command.wantsPriorityOverSystemBehavior = true
            }
        }

        return [
            UIKeyCommand(
                input: UIKeyCommand.inputEscape, modifierFlags: [],
                action: #selector(self.handleKeyCommand(sender:))),
            UIKeyCommand(
                input: copyShortcutKey, modifierFlags: .command,
                action: #selector(self.handleKeyCommand(sender:))),
        ]
    }

    @objc func handleKeyCommand(sender: UIKeyCommand) {
        guard let input = sender.input else {
            return
        }
        switch input {
        case UIKeyCommand.inputLeftArrow:
            if suggestionModel.completion != nil {
                applyCompletion()

                // Set the current position to the beginning of the text.
                selectedTextRange = textRange(from: beginningOfDocument, to: beginningOfDocument)
            } else if let range = selectedTextRange {
                if range.start == beginningOfDocument {
                    break
                }

                guard let cursorPosition = position(from: range.start, offset: -1) else {
                    break
                }

                selectedTextRange = textRange(from: cursorPosition, to: cursorPosition)
            }
        case UIKeyCommand.inputRightArrow:
            if suggestionModel.completion != nil {
                applyCompletion()

                // Set the current position to the end of the text.
                selectedTextRange = textRange(from: endOfDocument, to: endOfDocument)
            } else if let range = selectedTextRange {
                if range.end == endOfDocument {
                    break
                }

                guard let cursorPosition = position(from: range.end, offset: 1) else {
                    break
                }

                selectedTextRange = textRange(from: cursorPosition, to: cursorPosition)
            }
        case UIKeyCommand.inputEscape:
            suggestionModel.bvc.closeLazyTab()
        case copyShortcutKey:
            if let text = text, let completion = suggestionModel.completion {
                UIPasteboard.general.string = text + completion
            } else if let selectedTextRange = self.selectedTextRange {
                UIPasteboard.general.string = self.text(in: selectedTextRange)
            }
        default:
            break
        }
    }

    /// Commits the completion by setting the text and removing the highlight.
    @discardableResult fileprivate func applyCompletion() -> Bool {
        tintColor = defaultTint
        // Clear the current completion, then set the text.
        guard let completion = suggestionModel.completion else { return false }
        suggestionModel.queryModel.value += completion

        log.info(
            "Applying URL bar text: \(suggestionModel.queryModel.value) with autocomplete completion: \(completion)"
        )

        // Move the cursor to the end of the completion.
        selectedTextRange = textRange(from: endOfDocument, to: endOfDocument)
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        applyCompletion()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let isNoSuggestionQuery = URLFixup.getURL(textField.text ?? "") == nil
        let interaction: LogConfig.Interaction =
            suggestionModel.completion == nil
            ? (isNoSuggestionQuery
                ? .NoSuggestionQuery
                : .NoSuggestionURL)
            : .AutocompleteSuggestion

        let additionalClientAttribute =
            [
                ClientLogCounterAttribute(
                    key: LogConfig.SuggestionAttribute.urlBarNumOfCharsTyped,
                    value: String(textField.text?.count ?? 0)
                )
            ]

        var queryAttributes = [ClientLogCounterAttribute]()
        if isNoSuggestionQuery {
            queryAttributes = suggestionModel.buildQueryAttributes(
                typedQuery: textField.text ?? "",
                suggestedQuery: nil,
                index: nil,
                suggestedUrl: nil,
                isFromSearchHistory: false
            )
        }

        log.info(
            "No Autocomplete suggestion taken, query: \(String(describing: textField.text))"
        )

        ClientLogger.shared.logCounter(
            interaction,
            attributes: EnvironmentHelper.shared.getAttributes()
                + additionalClientAttribute
                + suggestionModel.suggestionSnapshotAttributes()
                + queryAttributes)
        if let text = accessibilityValue {
            if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                onSubmit(text)
                return true
            } else {
                return false
            }
        }
        return true
    }

    override func setMarkedText(_ markedText: String?, selectedRange: NSRange) {
        // Clear the autocompletion if any provisionally inserted text has been
        // entered (e.g., a partial composition from a Japanese keyboard).
        suggestionModel.clearCompletion()
        super.setMarkedText(markedText, selectedRange: selectedRange)
    }

    override func deleteBackward() {
        if !suggestionModel.clearCompletion() {
            if selectedTextRange != textRange(from: beginningOfDocument, to: beginningOfDocument) {
                suggestionModel.skipNextAutocomplete()
            }
            super.deleteBackward()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        applyCompletion()
        super.touchesBegan(touches, with: event)
    }
}

extension AutocompleteTextField: MenuHelperInterface {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == MenuHelper.SelectorPasteAndGo {
            return UIPasteboard.general.hasStrings
        }

        return super.canPerformAction(action, withSender: sender)
    }

    @objc func menuHelperPasteAndGo() {
        UIPasteboard.general.asyncString().uponQueue(.main) {
            if let input = $0.successValue as? String {
                self.onSubmit(input)
            }
        }
    }
}
