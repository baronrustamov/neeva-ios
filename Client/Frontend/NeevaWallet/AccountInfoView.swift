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
    @State var showProfilePicturePicker: Bool = false
    @State var qrCodeStr: String = ""
    @State var copyAddressText = "Copy Address"
    @Binding var viewState: ViewState

    @Environment(\.hideOverlay) var hideOverlay
    @ObservedObject var model: Web3Model
    @ObservedObject var assetStore: AssetStore = AssetStore.shared

    var body: some View {
        overflowMenu
            .padding(.top, 24)
            .modifier(WalletListSeparatorModifier())

        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button(action: {
                    UIPasteboard.general.setObjects(
                        [Defaults[.cryptoPublicKey]], localOnly: false,
                        expirationDate: Date().addingTimeInterval(30)
                    )

                    copyAddressText = "Copied!"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        copyAddressText = "Copy Address"
                    }
                }) {
                    HStack(spacing: 4) {
                        Symbol(decorative: .docOnDoc, style: .bodyMedium)
                        Text(verbatim: copyAddressText).frame(minWidth: 100)
                    }
                }.buttonStyle(DashboardButtonStyle())
                Button(action: { showQRScanner = true }) {
                    HStack(spacing: 4) {
                        Symbol(decorative: .qrcodeViewfinder, style: .bodyMedium)
                        Text(verbatim: "Scan")
                    }
                }.sheet(isPresented: $showQRScanner) {
                    ScannerView(
                        showQRScanner: $showQRScanner, returnAddress: $qrCodeStr,
                        onComplete: onScanComplete)
                }.buttonStyle(DashboardButtonStyle())
                ZStack {
                    NavigationLink(isActive: $showSendForm) {
                        VStack {
                            sheetHeader("Send")
                            SendForm(wallet: model.wallet, showSendForm: $showSendForm)
                            Spacer()
                        }
                        .navigationBarHidden(true)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    } label: {
                        EmptyView()
                    }.opacity(0)
                    Button(action: { showSendForm = true }) {
                        HStack(spacing: 4) {
                            Symbol(decorative: .paperplane, style: .bodyMedium)
                            Text(verbatim: "Send")
                        }
                    }
                    .buttonStyle(DashboardButtonStyle())
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
                            Text(verbatim: "Import Wallet Credentials")
                        }
                    }
                )
                .buttonStyle(DashboardButtonStyle())
                .padding(.bottom, 12)
            }
        }
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
            ZStack {
                WalletProfilePicture(size: CGSize(width: 34, height: 34))
                if !assetStore.assets.isEmpty && showOverflowSheet {
                    Symbol(decorative: .pencilCircleFill, weight: .regular)
                        .foregroundColor(Color.label)
                        .background(Color.DefaultBackground)
                        .clipShape(Circle())
                        .frame(width: 12, height: 12)
                        .offset(x: 12, y: -12)
                }
            }.padding(4)
            VStack(alignment: .leading, spacing: 0) {
                Text(model.walletDisplayName)
                    .withFont(.bodyMedium)
                    .gradientForeground()
                    .lineLimit(1)
                if let balance = model.balanceFor(.ether) {
                    Text(verbatim: "\(balance) ETH")
                        .withFont(.bodySmall)
                        .foregroundColor(.secondaryLabel)
                }
            }
            Spacer()
        }
        .padding(.vertical, 16)
        .onTapGesture {
            showProfilePicturePicker.toggle()
        }
    }

    @ViewBuilder
    var overflowMenu: some View {
        ZStack {
            NavigationLink(
                isActive: $showOverflowSheet
            ) {
                VStack {
                    sheetHeader("Wallets")
                    if showProfilePicturePicker, !assetStore.assets.isEmpty {
                        WalletProfilePicturePicker(assetStore: assetStore)
                    }
                    if let _ =
                        NeevaConstants.cryptoKeychain[string: NeevaConstants.cryptoSecretPhrase]
                    {
                        Button(
                            action: onExportWallet,
                            label: {
                                Text(verbatim: "View Secret Recovery Phrase")
                                    .frame(maxWidth: .infinity)
                            }
                        ).buttonStyle(.wallet(.secondary))
                    }
                    Button(
                        action: {
                            showConfirmRemoveWalletAlert = true
                        }
                    ) {
                        Text(verbatim: "Remove Wallet")
                            .frame(maxWidth: .infinity)
                    }.buttonStyle(.wallet(.secondary))
                    Spacer()
                }
                .padding(.horizontal, 16)
                .navigationBarHidden(true)
                .actionSheet(isPresented: $showConfirmRemoveWalletAlert) {
                    confirmRemoveWalletSheet
                }
            } label: {
                EmptyView()
            }.opacity(0)
            Button(
                action: { showOverflowSheet = true },
                label: {
                    VStack(spacing: 0) {
                        WalletProfilePicture(size: CGSize(width: 48, height: 48))
                            .padding(8)
                        HStack(spacing: 0) {
                            Text(model.walletDisplayName)
                                .withFont(.headingXLarge)
                                .gradientForeground()
                                .lineLimit(1)
                            Symbol(decorative: .chevronRight, style: .headingXLarge)
                                .foregroundColor(.wallet.gradientEnd)
                        }
                    }

                }
            )
        }

    }

    var confirmRemoveWalletSheet: ActionSheet {
        ActionSheet(
            title: Text(
                verbatim:
                    "Are you sure you want to remove all keys for your wallet from this device? "),
            buttons: [
                .destructive(
                    Text(verbatim: "Remove Wallet from device"),
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
                        model.walletInfo = WalletQuery.WalletInfo(ens: [])
                        model.balances.keys.forEach({
                            model.balances[$0] = "0"
                        })
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

struct WalletProfilePicturePicker: View {
    @Default(.walletProfilePictureAssetId) var assetId
    @ObservedObject var assetStore: AssetStore

    var body: some View {
        ScrollView(
            .horizontal, showsIndicators: false,
            content: {
                LazyHStack {
                    ForEach(
                        assetStore.assets, id: \.id,
                        content: { asset in
                            assetView(asset)
                        })
                }.padding(.horizontal, 2)
            }
        )
        .frame(height: 36)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func assetView(_ asset: Asset) -> some View {
        if let imageUrl = asset.imageURL {
            WebImage(
                url: imageUrl,
                context: [
                    .imageThumbnailPixelSize: CGSize(
                        width: 64,
                        height: 64)
                ]
            )
            .resizable()
            .frame(width: 32, height: 32)
            .aspectRatio(contentMode: .fill)
            .clipShape(Circle())
            .modifier(GradientSelection(id: asset.id))
            .padding(.vertical, 2)
            .onTapGesture {
                assetId = asset.id
            }
        }
    }

    struct GradientSelection: ViewModifier {
        let id: Int?
        @Default(.walletProfilePictureAssetId) var assetId

        func body(content: Content) -> some View {
            if id == assetId {
                content
                    .overlay(Circle().stroke(WalletTheme.gradient, lineWidth: 2))
            } else {
                content
            }
        }
    }

}
