// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import SDWebImageSwiftUI
import SwiftUI
import WalletConnectSwift
import WalletCore

struct OpenSessionsView: View {
    @State var isExpanded: Bool = true
    @State var showConfirmDisconnectAlert = false
    @State var sessionToDisconnect: Session? = nil
    @Default(.sessionsPeerIDs) var savedSessions

    @ObservedObject var model: Web3Model

    var body: some View {
        Section(
            content: {
                content
            },
            header: {
                header
            }
        )
        .modifier(WalletListSeparatorModifier())
        .actionSheet(isPresented: $showConfirmDisconnectAlert) {
            confirmDisconnectSheet
        }
    }

    @ViewBuilder
    private var content: some View {
        ForEach(
            model.allSavedSessions.sorted(by: { $0.dAppInfo.peerId > $1.dAppInfo.peerId }),
            id: \.url
        ) { session in
            if isExpanded, let domain = session.dAppInfo.peerMeta.url.baseDomain,
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
    }

    @ViewBuilder
    private var header: some View {
        if !model.allSavedSessions.isEmpty {
            WalletHeader(
                title: "Connected Sites",
                isExpanded: $isExpanded
            )
        }
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

}
