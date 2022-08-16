// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import BigInt
import Combine
import Foundation
import LocalAuthentication
import SDWebImageSwiftUI
import Shared
import SwiftUI
import WalletConnectSwift
import WalletCore
import web3swift

struct WalletSequenceContent: View {
    @Environment(\.hideOverlay) private var hideOverlaySheet
    @ObservedObject var model: Web3Model
    @State var communityTrusted: Bool = false
    @State var userSelectedChain: EthNode?

    var chainToUse: EthNode {
        userSelectedChain ?? model.currentSequence?.chain ?? .Ethereum
    }

    var showingCommunitySubmissions: Bool {
        guard let type = model.currentSequence?.type,
            case .sessionRequest = type,
            case .notTrusted = model.trustSignal,
            model.alternateTrustedDomain == nil,
            !communityTrusted
        else {
            return false
        }
        return true
    }

    var domain: String {
        model.currentSequence?.dAppMeta.url.baseDomain
            ?? model.currentSequence?.dAppMeta.url.domainURL.absoluteString ?? ""
    }

    var body: some View {
        if let sequence = model.currentSequence {
            if showingCommunitySubmissions, let url = model.selectedTab?.url {
                CommunitySubmissionView(
                    iconURL: sequence.thumbnailURL, domain: domain, url: url,
                    trust: $communityTrusted)
            } else {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        if case .sessionRequest = sequence.type,
                            let collection = model.matchingCollection,
                            collection.safelistRequestStatus >= .approved,
                            let stats = collection.stats
                        {
                            WalletSequenceSiteHeader(
                                iconURL: collection.imageURL ?? .aboutBlank,
                                domain: collection.name ?? "",
                                trusted: model.trustSignal == .trusted
                            )
                            CompactStatsView(stats: stats)
                                .frame(maxWidth: .infinity)
                        } else {
                            DefaultHeader(
                                sequence: sequence,
                                trusted: model.trustSignal == .trusted,
                                userSelectedChain: $userSelectedChain
                            ).frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding(12)
                    .background(WalletTheme.gradient.opacity(0.08))
                    .cornerRadius(12)
                    WalletSequenceMessage(type: sequence.type, dAppName: sequence.dAppMeta.name)
                    if sequence.type != .sessionRequest || model.trustSignal == .trusted
                        || communityTrusted
                    {
                        WalletSequenceMainButtons(
                            sequence: sequence,
                            userSelectedChain: $userSelectedChain
                        )
                    }
                    if let sequence = model.currentSequence,
                        let wallet = model.wallet
                    {
                        WalletSequenceBottomInfoPanel(
                            sequence: sequence,
                            wallet: wallet,
                            balance: model.balanceFor(chainToUse.currency),
                            walletDisplayName: model.walletDisplayName,
                            userSelectedChain: $userSelectedChain
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 36)
            }
        } else {
            VStack {
                Spacer(minLength: 150)
                ProgressView()
                    .scaleEffect(x: 2, y: 2, anchor: .center)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer(minLength: 150)
            }
        }
    }
}
