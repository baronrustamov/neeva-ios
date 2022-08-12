// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI
import WalletCore

struct BalancesView: View {
    @State var isExpanded: Bool = true
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
    }

    @ViewBuilder
    private var content: some View {
        if isExpanded {
            ForEach(
                TokenType.allCases.filter {
                    $0 == .ether || Double(model.balanceFor($0) ?? "0") != 0
                }, id: \.rawValue
            ) {
                token in
                HStack {
                    token.thumbnail
                    VStack(alignment: .leading, spacing: 0) {
                        Text(verbatim: token.currency.name)
                            .withFont(.bodyMedium)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.label)
                        Text(verbatim: token.network.rawValue)
                            .withFont(.bodySmall)
                            .foregroundColor(.secondaryLabel)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(
                            verbatim: "$\(token.toUSD(model.balanceFor(token) ?? "0"))"
                        )
                        .foregroundColor(.label)
                        .withFont(.bodyMedium)
                        .frame(alignment: .center)
                        Text(
                            verbatim: "\(model.balanceFor(token) ?? "") \(token.currency.rawValue)"
                        )
                        .withFont(.bodySmall)
                        .foregroundColor(.secondaryLabel)
                    }

                }.modifier(WalletListSeparatorModifier())
            }
        }
    }

    @ViewBuilder
    private var header: some View {
        WalletHeader(
            title: "Balances",
            isExpanded: $isExpanded
        )
    }

}
