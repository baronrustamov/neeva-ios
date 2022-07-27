// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import SDWebImageSwiftUI
import Shared
import SwiftUI
import WalletConnectSwift
import WalletCore

struct SessionInfoView: View {
    @Environment(\.hideOverlay) private var hideOverlaySheet
    @EnvironmentObject var web3Model: Web3Model

    let session: Session

    var sequence: SequenceInfo {
        SequenceInfo(
            type: .sessionRequest,
            thumbnailURL: session.dAppInfo.peerMeta.icons.first ?? .aboutBlank,
            dAppMeta: session.dAppInfo.peerMeta,
            chain: EthNode.from(chainID: session.walletInfo?.chainId),
            message: session.dAppInfo.peerMeta.description ?? "",
            onAccept: { _ in },
            onReject: {}
        )
    }

    var chain: EthNode {
        EthNode.from(chainID: session.walletInfo?.chainId)
    }

    var body: some View {
        VStack(spacing: 36) {
            if let matchingCollection = web3Model.matchingCollection {
                CollectionView(collection: matchingCollection)
                    .background(WalletTheme.gradient.opacity(0.08))
                    .cornerRadius(16)
            } else {
                VStack(spacing: 8) {
                    DefaultHeader(
                        sequence: sequence,
                        trusted: web3Model.trustSignal == .trusted,
                        userSelectedChain: .constant(chain)
                    )
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(WalletTheme.gradient.opacity(0.08))
                .cornerRadius(16)
            }
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Button(action: {
                        DispatchQueue.global(qos: .userInitiated).async {
                            try? web3Model.server?.disconnect(from: session)
                        }
                        Defaults[.dAppsSession(session.dAppInfo.peerId)] = nil
                        Defaults[.sessionsPeerIDs].remove(session.dAppInfo.peerId)
                        hideOverlaySheet()
                        web3Model.currentSession = nil
                        ClientLogger.shared.logCounter(
                            .DisconnectedSite,
                            attributes: [
                                ClientLogCounterAttribute(
                                    key: LogConfig.Web3Attribute.walletAddress,
                                    value: Defaults[.cryptoPublicKey]),
                                ClientLogCounterAttribute(
                                    key: LogConfig.Web3Attribute.connectedSite,
                                    value: session.dAppInfo.peerMeta.url.absoluteString),
                            ])
                    }) {
                        HStack(spacing: 4) {
                            Symbol(decorative: .wifiSlash, style: .bodyMedium)
                            Text("Disconnect")
                        }
                    }.buttonStyle(DashboardButtonStyle())
                    let nodeToSwitchTo =
                        chain == .Ethereum ? EthNode.Polygon : EthNode.Ethereum
                    Button(action: {
                        web3Model.toggle(session: session, to: nodeToSwitchTo)
                        hideOverlaySheet()
                    }) {
                        HStack(spacing: 4) {
                            switch nodeToSwitchTo {
                            case .Ethereum:
                                TokenType.ether.ethLogo
                            default:
                                TokenType.matic.polygonLogo
                            }
                            Text("Switch Chain")
                        }
                    }.buttonStyle(DashboardButtonStyle())
                }
                Button(action: {
                    web3Model.showWalletPanel()
                    hideOverlaySheet()
                }) {
                    HStack(spacing: 2) {
                        Symbol(decorative: .arrowUpRight, style: .bodyMedium)
                        Text(verbatim: "Open Neeva Wallet")
                    }
                }.buttonStyle(DashboardButtonStyle())
            }
            Spacer()
        }
    }
}

struct SessionInfoButton: View {
    @EnvironmentObject var web3Model: Web3Model

    let dAppSession: Session
    @State var showdAppSessionControls: Bool = false
    @State var rotationAngle: Double = 0

    @ViewBuilder var logo: some View {
        switch EthNode.from(chainID: dAppSession.walletInfo?.chainId) {
        case .Polygon:
            Image("polygon-badge")
                .resizable()
        default:
            Image("ethLogo")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.label)
        }
    }

    var body: some View {
        Button(
            action: {
                web3Model.presenter.showModal(
                    style: .spaces, headerButton: nil,
                    toPosition: .middle,
                    content: {
                        SessionInfoView(session: dAppSession)
                            .padding(.top, -12)
                            .overlayIsFixedHeight(isFixedHeight: true)
                            .environmentObject(web3Model)
                    }, onDismiss: {})
            },
            label: {
                logo
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .padding(2)
                    .background(Circle().fill(Color.secondaryBackground))
                    .padding(2)
                    .animation(nil)
                    .background(
                        Circle()
                            .fill(WalletTheme.gradient)
                            .rotationEffect(.degrees(rotationAngle))
                            .animation(nil)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 3).repeatForever()) {
                                    rotationAngle = 360
                                }
                            }
                    )
            }
        )
    }
}
