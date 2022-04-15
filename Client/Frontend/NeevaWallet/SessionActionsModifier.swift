// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI
import WalletConnectSwift
import WalletCore
import web3swift

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
