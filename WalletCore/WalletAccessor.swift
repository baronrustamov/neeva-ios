// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import BigInt
import CryptoSwift
import Defaults
import Foundation
import PromiseKit
import Shared
import SwiftUI
import WalletConnectSwift
import secp256k1
import web3swift

public struct WalletAccessor {
    let keystore: EthereumKeystoreV3?
    let password: String
    let web3: web3?
    let polygonWeb3: web3?
    var walletInfo = WalletQuery.WalletInfo(ens: [])

    func web3(on chain: EthNode) -> web3? {
        switch chain {
        case .Polygon:
            return polygonWeb3
        default:
            return web3
        }
    }

    public var web3IsValid: Bool {
        web3(on: .Ethereum) != nil
    }

    public init() {
        self.web3 = try? Web3.new(EthNode.Ethereum.url ?? .aboutBlank)
        self.polygonWeb3 = try? Web3.new(EthNode.Polygon.url ?? .aboutBlank)
        self.password = CryptoConfig.shared.password

        let key = NeevaConstants.cryptoKeychain[string: NeevaConstants.cryptoPrivateKey] ?? ""
        let formattedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        let dataKey = Data.fromHex(formattedKey)!
        self.keystore = try? EthereumKeystoreV3(privateKey: dataKey, password: password)
        if let keystore = keystore {
            self.web3?.addKeystoreManager(KeystoreManager([keystore]))
            self.polygonWeb3?.addKeystoreManager(KeystoreManager([keystore]))
        }
    }

    var privateKey: [UInt8] {
        let key = NeevaConstants.cryptoKeychain[string: NeevaConstants.cryptoPrivateKey]
        let formattedKey = key?.trimmingCharacters(in: .whitespacesAndNewlines)
        return formattedKey!.bytes
    }

    public var walletMeta: Session.ClientMeta {
        return Session.ClientMeta(
            name: "Neeva Wallet",
            description: "Neeva is the world's first ad-free private search engine",
            icons: [URL(string: "https://neeva.com/apple-touch-icon-180.png")!],
            url: URL(string: "https://neeva.com")!)
    }

    public var ethereumAddress: EthereumAddress? {
        return EthereumAddress(publicAddress)
    }

    public var addressInKeystore: String {
        keystore?.addresses?.first?.address ?? ""
    }

    public var publicAddress: String {
        return Defaults[.cryptoPublicKey]
    }

    public func sign(on chain: EthNode, message: String) throws -> String {
        guard let web3 = web3(on: chain), let address = ethereumAddress else { return "" }

        return try "0x"
            + web3.wallet.signPersonalMessage(
                message, account: address, password: password
            ).toHexString()
    }

    public func sign(on chain: EthNode, message: Data) throws -> String {
        guard let web3 = web3(on: chain), let address = ethereumAddress else {
            throw WalletAccessorError.invalidState
        }

        if let signature = try?
            (web3.wallet.signPersonalMessage(
                message, account: address, password: password)),
            let unmarshalled = SECP256K1.unmarshalSignature(signatureData: signature)
        {
            return "0x" + unmarshalled.r.toHexString() + unmarshalled.s.toHexString()
                + String(Data([unmarshalled.v]).toHexString().last ?? "0")
        }
        return ""
    }

    public func ethBalance(completion: @escaping (String?) -> Void) {
        balance(on: .Ethereum, completion: completion)
    }

    public func balance(on chain: EthNode, completion: @escaping (String?) -> Void) {
        guard let web3 = web3(on: chain), let _ = EthereumAddress(publicAddress) else {
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            web3.eth.getBalancePromise(address: publicAddress).done(
                on: DispatchQueue.main
            ) {
                balance in
                completion(Web3.Utils.formatToEthereumUnits(balance, toUnits: .eth))
            }.cauterize()
        }
    }

    public func tokenBalance(token: TokenType, completion: @escaping (String?) -> Void) {
        guard let web3 = web3(on: token.network),
            let walletAddress = EthereumAddress(publicAddress), !token.contractAddress.isEmpty
        else {
            balance(on: token.network, completion: completion)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let erc20ContractAddress = EthereumAddress(token.contractAddress)!
            let contract = web3.contract(
                Web3.Utils.erc20ABI, at: erc20ContractAddress, abiVersion: 2)!
            var options = TransactionOptions.defaultOptions
            options.from = walletAddress
            options.gasPrice = .automatic
            options.gasLimit = .automatic
            let method = "balanceOf"
            let tx = contract.read(
                method,
                parameters: [walletAddress] as [AnyObject],
                extraData: Data(),
                transactionOptions: options)!
            tx.callPromise().done { tokenBalance in
                let balanceBigUInt = tokenBalance["0"] as! BigUInt
                completion(
                    Web3.Utils.formatToEthereumUnits(
                        balanceBigUInt,
                        toUnits: token.currency == .USDC || token.currency == .USDT ? .Mwei : .eth,
                        decimals: 6
                    )
                )
            }.cauterize()
        }
    }

    public func gasPrice(on chain: EthNode, completion: @escaping (BigUInt?) -> Void) {
        guard let web3 = web3(on: chain) else { return }

        DispatchQueue.global(qos: .userInitiated).async {
            web3.eth.getGasPricePromise().done(on: DispatchQueue.main) { estimate in
                completion(estimate)
            }.cauterize()
        }
    }

    public func estimateGasForTransaction(
        on chain: EthNode,
        options: TransactionOptions,
        transaction: EthereumTransaction,
        completion: @escaping (BigUInt, BigUInt?) -> Void
    ) {
        guard let web3 = web3(on: chain) else { return }

        DispatchQueue.global(qos: .userInitiated).async {
            let gasPrice: BigUInt =
                (try? web3.eth.getGasPrice()) ?? transaction.gasPrice
            var tx = transaction
            tx.gasPrice = gasPrice
            var opts = options
            opts.gasPrice = .manual(gasPrice)

            web3.eth.estimateGasPromise(tx, transactionOptions: opts)
                .done(on: DispatchQueue.main) { estimate in
                    completion(gasPrice, estimate)
                }.cauterize()
        }
    }

    public func send(on chain: EthNode, transactionData: TransactionData) throws -> String {
        guard let web3 = web3(on: chain) else { throw WalletAccessorError.invalidState }

        let contract = web3.contract(
            Web3.Utils.coldWalletABI, at: transactionData.toAddress, abiVersion: 2)!

        let tx = contract.write(
            "fallback",
            parameters: [AnyObject](),
            extraData: transactionData.convertedData,
            transactionOptions: transactionData.transactionOptions)!

        return try tx.send(password: password).transaction.txhash ?? ""
    }
}

enum WalletAccessorError: Error {
    case invalidState
}
