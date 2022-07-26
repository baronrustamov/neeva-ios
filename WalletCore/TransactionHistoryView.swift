// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct TransactionHistoryView: View {
    @Binding var transactionHistory: [TransactionDetail]

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                if transactionHistory.count > 0 {
                    Text(verbatim: "Transactions")
                        .withFont(.labelMedium)
                        .padding(.top, 20)
                }
                ForEach(transactionHistory, id: \.self) { history in
                    HStack {
                        Image(
                            systemSymbol: history.transactionAction == .Send
                                ? .arrowUpRightCircle : .arrowDownCircle
                        )
                        .renderingMode(.template)
                        .foregroundColor(Color.brand.peach)
                        .font(.system(size: 32))
                        VStack(alignment: .leading) {
                            HStack {
                                Text(history.transactionAction.rawValue)
                                    .withFont(.bodyLarge)
                                Spacer()
                                Text(verbatim: "\(history.amountInEther) ETH")
                                    .withFont(.bodyMedium)
                            }
                            ScrollView(.horizontal) {
                                Text(history.oppositeAddress)
                                    .multilineTextAlignment(.leading)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, -8)
                        }
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8).stroke(Color.ui.gray91, lineWidth: 0.5)
                    )
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(8)
                }
            }
        }
    }
}
