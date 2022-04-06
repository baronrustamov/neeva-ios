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

struct WalletHeader: View {
    let title: String
    @Binding var isExpanded: Bool

    var body: some View {
        HStack {
            Text(title)
                .withFont(.headingMedium)
                .foregroundColor(.label)
            Spacer()
            Button(action: {
                isExpanded.toggle()
            }) {
                Symbol(
                    decorative: isExpanded ? .chevronUp : .chevronDown,
                    style: .headingMedium
                )
                .foregroundColor(.label)
            }
        }
        .padding(.bottom, 4)
    }
}

struct WalletDashboard: View {
    @Default(.sessionsPeerIDs) var savedSessions
    @Default(.currentTheme) var currentTheme
    @Environment(\.hideOverlay) var hideOverlay
    @EnvironmentObject var model: Web3Model

    @Binding var viewState: ViewState

    @State var showBalances: Bool = true
    @State var showSessions: Bool = true
    @State var showNFTs: Bool = true
    @State var showThemes: Bool = true
    @State var showSendForm: Bool = false
    @State var showOverflowSheet: Bool = false
    @State var showConfirmDisconnectAlert = false
    @State var showConfirmRemoveWalletAlert = false
    @State var sessionToDisconnect: Session? = nil
    @State var showQRScanner: Bool = false
    @State var qrCodeStr: String = ""
    @State var copyAddressText = "Copy Address"

    @ObservedObject var assetStore: AssetStore

    var addressText: String {
        "\(String(Defaults[.cryptoPublicKey].prefix(3)))...\(String(Defaults[.cryptoPublicKey].suffix(3)))"
    }

    @ViewBuilder func sheetHeader(_ title: String) -> some View {
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
                Text(addressText)
                    .withFont(.bodyMedium)
                    .foregroundColor(.label)
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

    @ViewBuilder var overflowMenu: some View {
        Button(
            action: { showOverflowSheet = true },
            label: {
                Symbol(decorative: .chevronDown, style: .headingXLarge)
                    .foregroundColor(.label)
            }
        ).sheet(
            isPresented: $showOverflowSheet, onDismiss: {},
            content: {
                VStack {
                    sheetHeader("Wallets")
                    Button(
                        action: onExportWallet,
                        label: {
                            Text("View Secret Recovery Phrase")
                                .frame(maxWidth: .infinity)
                        }
                    ).buttonStyle(.wallet(.secondary))
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

    var accountInfo: some View {
        VStack(spacing: 0) {
            Circle()
                .fill(WalletTheme.gradient)
                .frame(width: 48, height: 48)
                .padding(8)
            HStack(spacing: 0) {
                Text(addressText)
                    .withFont(.headingXLarge)
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
            if !FeatureFlag[.showNFTsInWallet] {
                Button(
                    action: {
                        model.openURLForSpace(
                            NeevaConstants.appHomeURL, model.wallet?.publicAddress ?? "")
                    },
                    label: {
                        HStack(spacing: 4) {
                            WebImage(url: SearchEngine.nft.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .padding(4)
                                .background(Color.quaternarySystemFill)
                                .cornerRadius(4)
                            Text("Your NFTs")
                        }
                    }
                )
                .padding(.horizontal, 16)
                .buttonStyle(DashboardButtonStyle())
            }
        }
        .padding(.top, 24)
        .modifier(WalletListSeparatorModifier())
    }

    var balancesSection: some View {
        Section(
            content: {
                if showBalances {
                    ForEach(
                        TokenType.allCases.filter {
                            $0 == .ether || Double(model.balanceFor($0) ?? "0") != 0
                        }, id: \.rawValue
                    ) {
                        token in
                        HStack {
                            token.thumbnail
                            VStack(alignment: .leading, spacing: 0) {
                                Text(token.currency.name)
                                    .withFont(.bodyMedium)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(.label)
                                Text(token.network.rawValue)
                                    .withFont(.bodySmall)
                                    .foregroundColor(.secondaryLabel)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 0) {
                                Text(
                                    "$\(token.toUSD(model.balanceFor(token) ?? "0"))"
                                )
                                .foregroundColor(.label)
                                .withFont(.bodyMedium)
                                .frame(alignment: .center)
                                Text("\(model.balanceFor(token) ?? "") \(token.currency.rawValue)")
                                    .withFont(.bodySmall)
                                    .foregroundColor(.secondaryLabel)
                            }

                        }.modifier(WalletListSeparatorModifier())
                    }
                }
            },
            header: {
                WalletHeader(
                    title: "Balances",
                    isExpanded: $showBalances
                )
            })
    }

    var openSessionsSection: some View {
        Section(
            content: {
                ForEach(
                    model.allSavedSessions.sorted(by: { $0.dAppInfo.peerId > $1.dAppInfo.peerId }),
                    id: \.url
                ) { session in
                    if showSessions, let domain = session.dAppInfo.peerMeta.url.baseDomain,
                        savedSessions.contains(session.dAppInfo.peerId)
                    {
                        HStack {
                            WebImage(url: session.dAppInfo.peerMeta.icons.first)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                            VStack(alignment: .leading, spacing: 0) {
                                Text(session.dAppInfo.peerMeta.name)
                                    .withFont(.bodyMedium)
                                    .lineLimit(1)
                                    .foregroundColor(.label)
                                Text(domain)
                                    .withFont(.bodySmall)
                                    .foregroundColor(.secondaryLabel)
                            }
                            Spacer()
                            let chain = EthNode.from(
                                chainID: session.walletInfo?.chainId)
                            switch chain {
                            case .Polygon:
                                TokenType.matic.polygonLogo
                            default:
                                TokenType.ether.ethLogo
                            }
                        }
                        .modifier(
                            SessionActionsModifier(
                                session: session,
                                showConfirmDisconnectAlert: $showConfirmDisconnectAlert,
                                sessionToDisconnect: $sessionToDisconnect)
                        )
                        .modifier(WalletListSeparatorModifier())
                    }
                }
            },
            header: {
                if !model.allSavedSessions.isEmpty {
                    WalletHeader(
                        title: "Connected Sites",
                        isExpanded: $showSessions
                    )
                }
            })
    }

    var nftSection: some View {
        Section(
            content: {
                if showNFTs {
                    ScrollView(
                        .horizontal, showsIndicators: false,
                        content: {
                            HStack {
                                ForEach(
                                    assetStore.assets, id: \.id,
                                    content: { asset in
                                        AssetView(asset: asset)
                                    })
                            }
                        })
                }
            },
            header: {
                if !assetStore.assets.isEmpty {
                    WalletHeader(
                        title: "Your NFTs",
                        isExpanded: $showNFTs
                    )
                }
            }
        )
        .modifier(WalletListSeparatorModifier())
    }

    var unlockedThemesSection: some View {
        Section(
            content: {
                ForEach(
                    model.unlockedThemes.sorted(by: { $0.rawValue > $1.rawValue }),
                    id: \.rawValue
                ) { theme in
                    if showThemes {
                        Button(
                            action: {
                                if let slug = theme.asset?.collection?.openSeaSlug {
                                    Defaults[.currentTheme] = slug == currentTheme ? "" : slug
                                    if !currentTheme.isEmpty {
                                        ClientLogger.shared.logCounter(
                                            .ThemeSet,
                                            attributes: [
                                                ClientLogCounterAttribute(
                                                    key: LogConfig.Web3Attribute.partnerCollection,
                                                    value: slug),
                                                ClientLogCounterAttribute(
                                                    key: LogConfig.Web3Attribute.walletAddress,
                                                    value: Defaults[.cryptoPublicKey]),
                                            ])
                                    }
                                }
                            },
                            label: {
                                HStack {
                                    WebImage(url: theme.asset?.collection?.imageURL)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 32, height: 32)
                                        .clipShape(Circle())
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(theme.asset?.collection?.name ?? "")
                                            .withFont(.bodyMedium)
                                            .lineLimit(1)
                                            .foregroundColor(.label)
                                        Text(theme.asset?.collection?.externalURL?.baseDomain ?? "")
                                            .withFont(.bodySmall)
                                            .foregroundColor(.secondaryLabel)
                                    }
                                    Spacer()
                                    Symbol(
                                        decorative: currentTheme
                                            == theme.asset?.collection?.openSeaSlug
                                            ? .checkmarkCircleFill : .circle,
                                        size: 24
                                    )
                                    .foregroundColor(.label)
                                }
                            }
                        )
                        .modifier(WalletListSeparatorModifier())
                    }
                }
            },
            header: {
                if !model.unlockedThemes.isEmpty {
                    WalletHeader(
                        title: "Unlocked Themes",
                        isExpanded: $showThemes
                    )
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

    var confirmDisconnectSheet: ActionSheet {
        ActionSheet(
            title: Text(
                "Are you sure you want to disconnect from \(sessionToDisconnect?.dAppInfo.peerMeta.url.baseDomain ?? "")?"
            ),
            buttons: [
                .destructive(
                    Text("Disconnect"),
                    action: {
                        let session = sessionToDisconnect!
                        DispatchQueue.global(qos: .userInitiated).async {
                            try? model.serverManager?.server.disconnect(from: session)
                        }
                        Defaults[.sessionsPeerIDs].remove(session.dAppInfo.peerId)
                        sessionToDisconnect = nil
                    }),
                .cancel(),
            ])
    }

    var body: some View {
        NavigationView {
            List {
                accountInfo
                balancesSection
                openSessionsSection
                if FeatureFlag[.showNFTsInWallet] {
                    nftSection
                }
                unlockedThemesSection
                    .actionSheet(isPresented: $showConfirmDisconnectAlert) {
                        confirmDisconnectSheet
                    }
            }
            .modifier(WalletListStyleModifier())
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.automatic)
    }

    func onScanComplete() {
        hideOverlay()

        let wcStr = "wc:\(qrCodeStr)"
        if let wcURL = WCURL(wcStr.removingPercentEncoding ?? "") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                model.presenter.connectWallet(to: wcURL)
            }
        }
    }
}

struct WalletListStyleModifier: ViewModifier {
    @EnvironmentObject var model: Web3Model

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .listStyle(.plain)
                .refreshable {
                    model.updateBalances()
                }
        }
    }
}

struct WalletListSeparatorModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .listSectionSeparator(Visibility.hidden)
                .listRowSeparator(Visibility.hidden)
                .listSectionSeparatorTint(Color.clear)
                .listRowBackground(Color.clear)
        } else {
            content
        }
    }
}

struct SessionActionsModifier: ViewModifier {
    @EnvironmentObject var model: Web3Model

    let session: Session

    @Binding var showConfirmDisconnectAlert: Bool
    @Binding var sessionToDisconnect: Session?

    var switchToNode: EthNode {
        let node = EthNode.from(chainID: session.walletInfo?.chainId)
        return node == .Ethereum ? .Polygon : .Ethereum
    }

    func switchChain() {
        model.toggle(session: session, to: switchToNode)
    }

    func delete() {
        sessionToDisconnect = session
        showConfirmDisconnectAlert = true
    }

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        delete()
                    } label: {
                        Label("Disconnect", systemImage: "")
                    }

                    Button {
                        switchChain()
                    } label: {
                        Label("Switch Chain", systemImage: "")
                            .foregroundColor(.white)
                    }.tint(.blue)
                }
        } else {
            content
                .contextMenu(
                    ContextMenu(menuItems: {
                        Button(
                            action: {
                                switchChain()
                            },
                            label: {
                                Label(
                                    title: { Text("Switch") },
                                    icon: {
                                        switch switchToNode {
                                        case .Polygon:
                                            TokenType.ether.polygonLogo
                                        default:
                                            TokenType.ether.ethLogo
                                        }
                                    })
                            })
                    })
                )
        }
    }
}
