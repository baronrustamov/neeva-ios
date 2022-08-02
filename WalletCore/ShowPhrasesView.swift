// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import MobileCoreServices
import Shared
import SwiftUI

public struct ShowPhrasesView: View {
    let dismiss: () -> Void
    @State var copyButtonText = "Copy to Clipboard"
    @State var showPhrases = false
    @Binding public var viewState: ViewState
    var secretPhrases: String {
        NeevaConstants.cryptoKeychain[string: NeevaConstants.cryptoSecretPhrase] ?? ""
    }

    public init(dismiss: @escaping () -> Void, viewState: Binding<ViewState>) {
        self._viewState = viewState
        self.dismiss = dismiss
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text(verbatim: "Secret Recovery Phrase")
                .withFont(.headingXLarge)
                .foregroundColor(.label)
                .padding(.top, 60)
            Text(
                verbatim:
                    "Write down or save your Secret Recovery Phrase somewhere safe. You need it to ensure you can access your wallet forever."
            )
            .withFont(.bodyLarge)
            .foregroundColor(.secondaryLabel)
            .multilineTextAlignment(.center)
            .padding(.bottom, 24)
            ZStack {
                let labelColor = Color(light: Color.white, dark: Color.black)
                HStack {
                    VStack(alignment: .leading) {
                        ForEach(0...5, id: \.self) { index in
                            let phrase = secretPhrases.split(separator: " ").map { String($0) }[
                                index]
                            Text(verbatim: "\(index + 1). \(phrase)")
                                .withFont(.bodyLarge)
                                .foregroundColor(.label)
                        }
                    }.frame(maxWidth: .infinity)
                    VStack(alignment: .leading) {
                        ForEach(6...11, id: \.self) { index in
                            let phrase = secretPhrases.split(separator: " ").map { String($0) }[
                                index]
                            Text(verbatim: "\(index + 1). \(phrase)")
                                .withFont(.bodyLarge)
                                .foregroundColor(.label)
                        }
                    }.frame(maxWidth: .infinity)
                }.padding(24)
                    .opacity(showPhrases ? 1 : 0)
                    .animation(.easeInOut)
                VStack(spacing: 16) {
                    Text(
                        verbatim:
                            "Anyone with this private key can fully control your wallet, including transferring away your funds. DO NOT let it get compromised!"
                    )
                    .withFont(.bodyLarge)
                    .foregroundColor(labelColor)
                    .multilineTextAlignment(.center)
                    Button(
                        action: { showPhrases = true },
                        label: {
                            Text(verbatim: "View")
                                .withFont(.bodyLarge)
                                .foregroundColor(labelColor)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 40)
                                .roundedOuterBorder(
                                    cornerRadius: 24, color: labelColor, lineWidth: 1)
                        })
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 28)
                .opacity(showPhrases ? 0 : 1)
                .animation(.easeInOut)
            }
            .roundedOuterBorder(cornerRadius: 12, color: .quaternarySystemFill, lineWidth: 1)
            .background(showPhrases ? Color.clear : Color.label.opacity(0.6))
            .background(
                showPhrases
                    ? Color.clear
                    : Color(
                        light: Color(UIColor.tertiarySystemFill.swappedForStyle),
                        dark: Color(UIColor.quaternarySystemFill.swappedForStyle))
            )
            .cornerRadius(12)
            .padding(.top, 48)

            Button(action: {
                copyButtonText = "Copied!"
                UIPasteboard.general.setValue(
                    secretPhrases,
                    forPasteboardType: kUTTypePlainText as String)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    copyButtonText = "Copy to Clipboard"
                }
            }) {
                Text(copyButtonText)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.wallet(.secondary))
            Button(action: {
                dismiss()
            }) {
                Text(verbatim: "Done")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.wallet(.primary))
            .padding(.top, 50)
        }
        .padding(.horizontal, 16)
    }
}
