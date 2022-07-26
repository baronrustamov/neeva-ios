// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI
import web3swift

public struct SendForm: View {
    @State var sendToAccountAddress = ""
    @State var amount: String = ""
    @Binding var showSendForm: Bool
    let wallet: WalletAccessor?
    @State var showQRScanner: Bool = false

    public init(wallet: WalletAccessor?, showSendForm: Binding<Bool>) {
        self.wallet = wallet
        self._showSendForm = showSendForm
    }

    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField(String("Recipient Address"), text: $sendToAccountAddress)
                Spacer()
                Button(action: { showQRScanner = true }) {
                    Symbol(decorative: .qrcodeViewfinder, style: .labelMedium)
                        .foregroundColor(.secondaryLabel)
                }.buttonStyle(.plain)
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 12.0)
                    .stroke(Color(UIColor.systemGray5), lineWidth: 1)
            )
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .fixedSize(horizontal: false, vertical: true)
            .background(Color.DefaultBackground)
            .cornerRadius(12)

            HStack {
                TextField(String("Amount (ETH)"), text: $amount)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .keyboardType(.numbersAndPunctuation)
                    .keyboardType(.decimalPad)
                Spacer()
                Text(verbatim: "\(TokenType.ether.toUSD(amount.isEmpty ? "0" : amount)) USD")
                    .withFont(.bodyLarge)
                    .foregroundColor(.secondaryLabel)
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 12.0)
                    .stroke(Color(UIColor.systemGray5), lineWidth: 1.0)
            )
            .fixedSize(horizontal: false, vertical: true)
            .background(Color.DefaultBackground)
            .cornerRadius(12)

            VStack(spacing: 16) {
                NeevaWalletLongPressButton(action: sendEth) {
                    Text(verbatim: "Press and hold to send")
                        .frame(maxWidth: .infinity)
                }
                .disabled(amount.isEmpty && sendToAccountAddress.isEmpty)
                Button(action: { showSendForm = false }) {
                    Text(verbatim: "Cancel")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.wallet(.secondary))
            }.padding(.top, 8)
        }
        .sheet(isPresented: $showQRScanner) {
            ScannerView(showQRScanner: $showQRScanner, returnAddress: $sendToAccountAddress)
        }
    }

    func sendEth() {
        CryptoConfig.shared.sendEth(
            with: wallet, amount: amount, sendToAccountAddress: sendToAccountAddress
        ) {
            showSendForm = false
        }
    }
}
