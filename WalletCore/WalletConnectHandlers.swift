// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import BigInt
import CryptoSwift
import Defaults
import Foundation
import SDWebImageSwiftUI
import Shared
import SwiftUI
import WalletConnectSwift
import web3swift

public protocol ToastDelegate: AnyObject {
    func shouldShowToast(for message: LocalizedStringKey)
}

public protocol WalletServerManagerDelegate: ResponseRelay, ToastDelegate {
    func updateCurrentSession()
    func updateCurrentSequence(_ sequence: SequenceInfo)
    var wallet: WalletAccessor? { get set }
}

public protocol ResponseRelay {
    var publicAddress: String { get }
    func send(_ response: Response)
    func askToSign(
        request: Request, message: String, typedData: Bool, sign: @escaping (EthNode) -> String)
    func askToTransact(
        request: Request,
        options: TransactionOptions,
        transaction: EthereumTransaction,
        transact: @escaping (EthNode) -> String
    )
    func send(
        on chain: EthNode,
        transactionData: TransactionData
    ) throws -> String
    func sign(on chain: EthNode, message: String) throws -> String
    func sign(on chain: EthNode, message: Data) throws -> String
}

extension Response {
    public static func signature(_ signature: String, for request: Request) -> Response {
        return try! Response(url: request.url, value: signature, id: request.id!)
    }

    public static func transaction(_ transaction: String, for request: Request) -> Response {
        return try! Response(url: request.url, value: transaction, id: request.id!)
    }
}

public class PersonalSignHandler: RequestHandler {
    let relay: WalletServerManagerDelegate

    public init(relay: WalletServerManagerDelegate) {
        self.relay = relay
    }

    public func canHandle(request: Request) -> Bool {
        guard request.method == "personal_sign" else { return false }

        if let _ = NeevaConstants.cryptoKeychain[string: NeevaConstants.cryptoSecretPhrase] {
            return true
        } else {
            relay.shouldShowToast(for: "You need to import your wallet credentials")
            return false
        }
    }

    public func handle(request: Request) {
        do {
            let messageBytes = try request.parameter(of: String.self, at: 0)
            let address = try request.parameter(of: String.self, at: 1)

            // Match only the address not the checksum (OpenSea sends them always lowercased :( )
            guard address.lowercased() == relay.publicAddress.lowercased() else {
                relay.send(.reject(request))
                return
            }

            let message = String(data: Data.fromHex(messageBytes) ?? Data(), encoding: .utf8) ?? ""

            relay.askToSign(request: request, message: message, typedData: false) { ethNode in
                return
                    (try? self.relay.sign(
                        on: ethNode, message: messageBytes))
                    ?? ""
            }
        } catch {
            relay.send(.invalid(request))
            return
        }
    }
}

public class SendTransactionHandler: RequestHandler {
    let relay: WalletServerManagerDelegate

    public init(relay: WalletServerManagerDelegate) {
        self.relay = relay
    }

    public func canHandle(request: Request) -> Bool {
        guard request.method == "eth_sendTransaction" else { return false }

        if let _ = NeevaConstants.cryptoKeychain[string: NeevaConstants.cryptoSecretPhrase] {
            return true
        } else {
            relay.shouldShowToast(for: "You need to import your wallet credentials")
            return false
        }
    }

    public func handle(request: Request) {
        guard let requestData = request.jsonString.data(using: .utf8),
            let transactionRequest = try? JSONDecoder().decode(
                TransactionRequest.self, from: requestData),
            let transactionData = transactionRequest.params.first,
            let transaction = transactionData.ethereumTransaction,
            let _ = EthereumAddress(transactionData.from)
        else {
            relay.send(.invalid(request))
            return
        }

        relay.askToTransact(
            request: request,
            options: transactionData.transactionOptions,
            transaction: transaction
        ) { ethNode in
            return
                (try? self.relay.send(
                    on: ethNode,
                    transactionData: transactionData
                )) ?? ""
        }
    }
}

public class SignTypedDataHandler: RequestHandler {
    let relay: WalletServerManagerDelegate

    public init(relay: WalletServerManagerDelegate) {
        self.relay = relay
    }

    public func canHandle(request: Request) -> Bool {
        guard request.method == "eth_signTypedData" else { return false }

        if let _ = NeevaConstants.cryptoKeychain[string: NeevaConstants.cryptoSecretPhrase] {
            return true
        } else {
            relay.shouldShowToast(for: "You need to import your wallet credentials")
            return false
        }
    }

    public func handle(request: Request) {
        guard let eip712 = request.toEIP712(),
            let typedData = eip712.hashedData
        else {
            relay.send(.invalid(request))
            return
        }

        relay.askToSign(request: request, message: (eip712.message.description), typedData: true) {
            chain in
            (try? self.relay.sign(on: chain, message: typedData)) ?? ""
        }
    }
}
