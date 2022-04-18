// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import LocalAuthentication
import MobileCoreServices
import SDWebImageSwiftUI
import Shared
import SwiftUI
import WalletConnectSwift
import WalletCore
import web3swift

struct AccountInfoView: View {
    @State var showSendForm: Bool = false
    @State var showQRScanner: Bool = false
    @State var showOverflowSheet: Bool = false
    @State var showConfirmRemoveWalletAlert = false
    @State var qrCodeStr: String = ""
    @State var copyAddressText = "Copy Address"
    @Binding var viewState: ViewState

    @Environment(\.hideOverlay) var hideOverlay
    let model: Web3Model

    var body: some View {
        VStack(spacing: 0) {
            Circle()
                .fill(WalletTheme.gradient)
                .frame(width: 48, height: 48)
                .padding(8)
            HStack(spacing: 0) {
                Text(model.walletDisplayName)
                    .withFont(.headingXLarge)
                    .gradientForeground()
                    .lineLimit(1)
                overflowMenu
            }

            HStack(spacing: 12) {
                Button(action: {
                    UIPasteboard.general.setValue(
                        Defaults[.cryptoPublicKey],
                        forPasteboardType: kUTTypePlainText as String)

                    copyAddressText = "Copied!"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        copyAddressText = "Copy Address"
                    }
                }) {
                    HStack(spacing: 4) {
                        Symbol(decorative: .docOnDoc, style: .bodyMedium)
                        Text(copyAddressText).frame(minWidth: 100)
                    }
                }.buttonStyle(DashboardButtonStyle())
                Button(action: { showQRScanner = true }) {
                    HStack(spacing: 4) {
                        Symbol(decorative: .qrcodeViewfinder, style: .bodyMedium)
                        Text("Scan")
                    }
                }.sheet(isPresented: $showQRScanner) {
                    ScannerView(
                        showQRScanner: $showQRScanner, returnAddress: $qrCodeStr,
                        onComplete: onScanComplete)
                }.buttonStyle(DashboardButtonStyle())
                Button(action: { showSendForm = true }) {
                    HStack(spacing: 4) {
                        Symbol(decorative: .paperplane, style: .bodyMedium)
                        Text("Send")
                    }
                }
                .buttonStyle(DashboardButtonStyle())
                .sheet(isPresented: $showSendForm, onDismiss: {}) {
                    VStack {
                        sheetHeader("Send")
                        SendForm(wallet: model.wallet, showSendForm: $showSendForm)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            if NeevaConstants.cryptoKeychain[string: NeevaConstants.cryptoSecretPhrase] == nil {
                Button(
                    action: {
                        viewState = .importWallet
                    },
                    label: {
                        HStack(spacing: 4) {
                            Symbol(decorative: .lockShield, style: .bodyMedium)
                            Text("Import Wallet Credentials")
                        }
                    }
                )
                .buttonStyle(DashboardButtonStyle())
                .padding(.bottom, 12)
            }
        }
        .padding(.top, 24)
        .modifier(WalletListSeparatorModifier())

    }

    @ViewBuilder
    func sheetHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .withFont(.headingMedium)
                .foregroundColor(.label)
            Spacer()
            Button(
                action: {
                    showOverflowSheet = false
                    showSendForm = false
                },
                label: {
                    Symbol(decorative: .xmark, style: .headingMedium)
                        .foregroundColor(.label)
                })
        }.padding(.vertical, 8)
        HStack(spacing: 10) {
            Circle()
                .fill(WalletTheme.gradient)
                .frame(width: 34, height: 34)
                .padding(4)
            VStack(alignment: .leading, spacing: 0) {
                Text(model.walletDisplayName)
                    .withFont(.bodyMedium)
                    .gradientForeground()
                    .lineLimit(1)
                if let balance = model.balanceFor(.ether) {
                    Text("\(balance) ETH")
                        .withFont(.bodySmall)
                        .foregroundColor(.secondaryLabel)
                }
            }
            Spacer()
        }.padding(.vertical, 16)
    }

    @ViewBuilder
    var overflowMenu: some View {
        Button(
            action: { showOverflowSheet = true },
            label: {
                Symbol(decorative: .chevronDown, style: .headingXLarge)
                    .foregroundColor(.wallet.gradientEnd)
            }
        ).sheet(
            isPresented: $showOverflowSheet, onDismiss: {},
            content: {
                VStack {
                    sheetHeader("Wallets")
                    if let _ =
                        NeevaConstants.cryptoKeychain[string: NeevaConstants.cryptoSecretPhrase]
                    {
                        Button(
                            action: onExportWallet,
                            label: {
                                Text("View Secret Recovery Phrase")
                                    .frame(maxWidth: .infinity)
                            }
                        ).buttonStyle(.wallet(.secondary))
                    }
                    Button(
                        action: {
                            showConfirmRemoveWalletAlert = true
                        }
                    ) {
                        Text("Remove Wallet")
                            .frame(maxWidth: .infinity)
                    }.buttonStyle(.wallet(.secondary))
                    Spacer()
                }
                .padding(.horizontal, 16)
                .actionSheet(isPresented: $showConfirmRemoveWalletAlert) {
                    confirmRemoveWalletSheet
                }
            })
    }

    var confirmRemoveWalletSheet: ActionSheet {
        ActionSheet(
            title: Text(
                "Are you sure you want to remove all keys for your wallet from this device? "
            ),
            buttons: [
                .destructive(
                    Text("Remove Wallet from device"),
                    action: {
                        showOverflowSheet = false
                        showConfirmRemoveWalletAlert = false
                        viewState = .starter
                        hideOverlay()
                        Defaults[.cryptoPublicKey] = ""
                        try? NeevaConstants.cryptoKeychain.remove(NeevaConstants.cryptoSecretPhrase)
                        try? NeevaConstants.cryptoKeychain.remove(NeevaConstants.cryptoPrivateKey)
                        Defaults[.sessionsPeerIDs].forEach {
                            Defaults[.dAppsSession($0)] = nil
                        }
                        Defaults[.sessionsPeerIDs] = Set<String>()
                        model.wallet = WalletAccessor()
                        Defaults[.currentTheme] = "default"
                        AssetStore.shared.assets.removeAll()
                        AssetStore.shared.availableThemes.removeAll()
                        AssetStore.shared.collections.removeAll()

                    }),
                .cancel(),
            ])
    }

    func onScanComplete() {
        hideOverlay()

        let wcStr = "wc:\(qrCodeStr)"
        if let wcURL = WCURL(wcStr.removingPercentEncoding ?? "") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                model.presenter.connectWallet(to: wcURL)
                model.desktopSession = true
            }
        }
    }

    func onExportWallet() {
        let context = LAContext()
        let reason =
            "Exporting wallet secret phrase requires authentication"
        let onAuth: (Bool, Error?) -> Void = {
            success, authenticationError in
            if success {
                showOverflowSheet = false
                viewState = .showPhrases
            }
        }

        var error: NSError?
        if context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics, error: &error)
        {
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason,
                reply: onAuth)
        } else if context.canEvaluatePolicy(
            .deviceOwnerAuthentication, error: &error)
        {
            context.evaluatePolicy(
                .deviceOwnerAuthentication, localizedReason: reason,
                reply: onAuth)
        }
    }

}
