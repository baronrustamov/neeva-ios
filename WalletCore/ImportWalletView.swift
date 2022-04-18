// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI
import web3swift

public struct ImportWalletView: View {
    let model = OnboardingModel()
    let dismiss: () -> Void
    @State var inputPhrase: String = ""
    @Binding var viewState: ViewState
    @State var isImporting: Bool = false
    @State var isFocused: Bool = false
    @State var clipboardHasPhrase = false
    let completion: () -> Void

    public init(
        dismiss: @escaping () -> Void, viewState: Binding<ViewState>,
        completion: @escaping () -> Void
    ) {
        self._viewState = viewState
        self.dismiss = dismiss
        self.completion = completion
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("Import Wallet")
                .withFont(.headingXLarge)
                .foregroundColor(.label)
                .padding(.top, 60)

            ZStack(alignment: .top) {
                if #available(iOS 15.0, *) {
                    FocusableTextEditor(inputPhrase: $inputPhrase, isFocusedCopy: $isFocused)
                } else {
                    TextEditor(text: $inputPhrase)
                        .colorMultiply(Color.DefaultBackground)
                        .withFont(unkerned: .bodyLarge)
                        .foregroundColor(.label)
                        .autocapitalization(.none)
                        .frame(maxWidth: .infinity)
                }
                Text("Type or paste your Secret Phrase, public address, or ENS domain")
                    .withFont(.bodyLarge)
                    .foregroundColor(.secondary)
                    .allowsHitTesting(false)
                    .animation(nil)
                    .opacity(inputPhrase.isEmpty && !isFocused ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2))
            }
            .padding(12)
            .roundedOuterBorder(
                cornerRadius: 12,
                color: isFocused ? .ui.adaptive.blue : .tertiarySystemFill,
                lineWidth: 1
            )
            .frame(maxHeight: 120)

            if isFocused, clipboardHasPhrase {
                Button(
                    action: {
                        inputPhrase = UIPasteboard.general.string!
                        onImport()
                    },
                    label: {
                        HStack(spacing: 4) {
                            Symbol(decorative: .docOnClipboardFill, style: .bodyMedium)
                            Text("Paste & Import")
                        }
                    }
                )
                .buttonStyle(DashboardButtonStyle())
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else if !isFocused {
                Text(
                    "**Not ready to import your wallet?** Start by inputting a public address or ENS domain. You can always import your wallet at another time."
                )
                .withFont(.bodyMedium)
                .foregroundColor(.secondaryLabel)
                .multilineTextAlignment(.center)
            }
            Button(action: onImport) {
                HStack {
                    Text(isImporting ? "Importing  " : "Import")
                    if isImporting {
                        ProgressView()
                    }
                }.frame(maxWidth: .infinity)
            }
            .buttonStyle(.wallet(.primary))
            .disabled(inputPhrase.isEmpty)
            Button(action: { viewState = .starter }) {
                Text("Back")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.wallet(.secondary))
        }
        .padding(.horizontal, 16)
        .ignoresSafeArea(.keyboard)
        .onChange(of: isFocused) { _ in
            clipboardHasPhrase = UIPasteboard.general.string?.split(separator: " ").count == 12
        }
    }

    func onImport() {
        guard !isImporting else { return }
        isImporting = true
        model.importWallet(inputPhrase: inputPhrase.trim()) { success in
            isImporting = false

            if success {
                dismiss()
                completion()
            } else {
                inputPhrase = ""
            }
        }
    }
}

@available(iOS 15.0, *)
struct FocusableTextEditor: View {
    @Binding var inputPhrase: String
    @Binding var isFocusedCopy: Bool
    @FocusState private var isFocused: Bool

    var body: some View {
        TextEditor(text: $inputPhrase)
            .focused($isFocused)
            .withFont(unkerned: .bodyLarge)
            .foregroundColor(.label)
            .textInputAutocapitalization(.never)
            .frame(maxWidth: .infinity)
            .onChange(of: isFocused) { val in
                isFocusedCopy = isFocused
            }
    }
}
