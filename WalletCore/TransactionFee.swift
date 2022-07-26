// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import BigInt
import Shared
import SwiftUI
import web3swift

class TransactionFeeModel: ObservableObject {
    @Published var gasPrice: BigUInt? = nil
    @Published var gasEstimate: BigUInt? = nil
    @Published var updatingGas = false
    @Published var updatedOnce = false
    @Published var timer: Timer? = nil
}

struct TransactionFeeView: View {
    @StateObject var model = TransactionFeeModel()

    let wallet: WalletAccessor?
    let chain: EthNode
    let transaction: EthereumTransaction
    let options: TransactionOptions

    var transactionFee: String {
        guard let gasPrice = model.gasPrice, let gasEstimate = model.gasEstimate else {
            return ""
        }
        let amount =
            Web3.Utils.formatToEthereumUnits(gasPrice * gasEstimate, toUnits: .eth) ?? "0"

        return chain.currency.toUSD(amount)
    }

    var body: some View {
        HStack(spacing: 6) {
            Text(verbatim: "$\(transactionFee)")
                .withFont(.labelLarge)
                .foregroundColor(.label)
                .opacity(model.updatingGas ? 0 : 1)
                .animation(model.updatingGas ? .easeInOut(duration: 1).repeatCount(6) : nil)
        }.onAppear {
            wallet?.estimateGasForTransaction(
                on: chain,
                options: options,
                transaction: transaction
            ) { price, estimate in
                model.gasPrice = price
                model.gasEstimate = estimate
            }
            model.timer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { _ in
                model.updatingGas = true
                model.updatedOnce = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                    wallet?.gasPrice(on: chain) { price in
                        model.gasPrice = price
                    }
                    model.updatingGas = false
                }
            }
        }.onDisappear {
            model.timer?.invalidate()
            model.timer = nil
        }
    }
}
