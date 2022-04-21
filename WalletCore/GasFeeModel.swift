// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import BigInt
import Foundation
import Shared
import SwiftUI
import web3swift

public enum GasFeeState {
    case low, medium, high

    init(with price: Double) {
        switch price {
        case 0..<50:
            self = .low
        case 50..<100:
            self = .medium
        default:
            self = .high
        }
    }

    public var tintColor: Color {
        switch self {
        case .low:
            return Color(light: .brand.green, dark: .brand.variant.green)
        case .medium:
            return Color(light: .brand.orange, dark: .brand.variant.orange)
        case .high:
            return Color(light: .brand.red, dark: .brand.variant.red)
        }
    }
}

public class GasFeeModel: ObservableObject {
    @Published public var gasPrice: Double = 0
    @Published public var gasFeeState: GasFeeState = .low
    private var timer: Timer? = nil

    public init() {}

    deinit {
        invalidateTimer()
    }

    public func configureTimer(with wallet: WalletAccessor?, chain: EthNode = EthNode.Ethereum) {
        guard let wallet = wallet else { return }
        updateGasPrice(with: wallet, chain: chain)
        timer = Timer.scheduledTimer(withTimeInterval: 200, repeats: true) { [weak self] _ in
            self?.updateGasPrice(with: wallet, chain: chain)
        }
    }

    private func updateGasPrice(with wallet: WalletAccessor, chain: EthNode = EthNode.Ethereum) {
        wallet.gasPrice(
            on: chain,
            completion: { price in
                DispatchQueue.main.async {
                    self.gasPrice = self.format(price: price)
                    self.gasFeeState = GasFeeState(with: self.gasPrice)
                }
            })
    }

    private func format(price: BigUInt?) -> Double {
        Double(Web3.Utils.formatToEthereumUnits(price ?? 0, toUnits: .Gwei) ?? "0") ?? 0
    }

    public func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
}
