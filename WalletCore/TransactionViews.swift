// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import LocalAuthentication
import SDWebImageSwiftUI
import Shared
import SwiftUI
import WalletConnectSwift
import web3swift

public enum SequenceType: String {
    case sessionRequest
    case personalSign
    case signTypedData
    case sendTransaction
}

public struct SequenceInfo {
    public let type: SequenceType
    public let thumbnailURL: URL
    public let dAppMeta: Session.ClientMeta
    public let chain: EthNode
    public let message: String
    public let onAccept: (Int) -> Void
    public let onReject: () -> Void
    public var transaction: EthereumTransaction? = nil
    public var options: TransactionOptions? = nil

    public init(
        type: SequenceType, thumbnailURL: URL, dAppMeta: Session.ClientMeta, chain: EthNode,
        message: String, onAccept: @escaping (Int) -> Void, onReject: @escaping () -> Void,
        transaction: EthereumTransaction? = nil, options: TransactionOptions? = nil
    ) {
        self.type = type
        self.thumbnailURL = thumbnailURL
        self.dAppMeta = dAppMeta
        self.chain = chain
        self.message = message
        self.onAccept = onAccept
        self.onReject = onReject
        self.transaction = transaction
        self.options = options
    }
}

public struct DefaultHeader: View {
    let sequence: SequenceInfo
    let trusted: Bool
    @Binding var userSelectedChain: EthNode?

    public init(sequence: SequenceInfo, trusted: Bool, userSelectedChain: Binding<EthNode?>) {
        self.sequence = sequence
        self.trusted = trusted
        self._userSelectedChain = userSelectedChain
    }

    var chainToUse: EthNode {
        userSelectedChain ?? sequence.chain
    }

    var domain: String {
        sequence.dAppMeta.url.baseDomain
            ?? sequence.dAppMeta.url.domainURL.absoluteString
    }

    public var body: some View {
        WalletSequenceSiteHeader(
            iconURL: sequence.thumbnailURL,
            domain: domain,
            trusted: trusted
        )
        switch sequence.type {
        case .personalSign, .signTypedData:
            VStack {
                Text("Message:")
                    .withFont(.bodyLarge)
                    .foregroundColor(.label)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                ScrollView(.vertical, showsIndicators: true) {
                    Text(sequence.message)
                        .withFont(.bodyLarge)
                        .foregroundColor(.label)
                        .padding()
                }.frame(height: 150)
            }
        case .sendTransaction:
            if let value = sequence.options?.value,
                let amount = Web3.Utils.formatToEthereumUnits(
                    value, toUnits: .eth, decimals: 4),
                let double = Double(amount)
            {
                Group {
                    Text("$" + chainToUse.currency.toUSD(amount))
                        .withFont(.displayMedium)
                        .foregroundColor(.label)
                    Label {
                        Text(String(double))
                            .withFont(.headingMedium)
                            .foregroundColor(.label)
                    } icon: {
                        switch chainToUse {
                        case .Polygon:
                            Currency.MATIC.logo
                        default:
                            Currency.ETH.logo
                        }
                    }
                }.frame(maxWidth: .infinity, alignment: .center)
            }
        default:
            Text(sequence.message)
                .withFont(.bodyLarge)
                .foregroundColor(.label)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

public struct WalletSequenceMainButtons: View {
    @Environment(\.hideOverlay) private var hideOverlaySheet
    let sequence: SequenceInfo
    @Binding var userSelectedChain: EthNode?

    public init(sequence: SequenceInfo, userSelectedChain: Binding<EthNode?>) {
        self.sequence = sequence
        self._userSelectedChain = userSelectedChain
    }

    var chainToUse: EthNode {
        userSelectedChain ?? sequence.chain
    }

    public var body: some View {
        HStack {
            Button(
                action: {
                    sequence.onReject()
                    hideOverlaySheet()
                },
                label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                }
            ).buttonStyle(.wallet(.secondary))
            Button(
                action: {
                    switch sequence.type {
                    case .sessionRequest:
                        sequence.onAccept(chainToUse.id)
                    default:
                        let context = LAContext()
                        let reason =
                            "Signing in and transactions require authentication"
                        let onAuth: (Bool, Error?) -> Void = {
                            success, authenticationError in
                            if success {
                                sequence.onAccept(chainToUse.id)
                            } else {
                                sequence.onReject()
                            }
                        }

                        var error: NSError?
                        if context.canEvaluatePolicy(
                            .deviceOwnerAuthenticationWithBiometrics, error: &error)
                        {
                            context.evaluatePolicy(
                                .deviceOwnerAuthenticationWithBiometrics,
                                localizedReason: reason,
                                reply: onAuth)
                        } else if context.canEvaluatePolicy(
                            .deviceOwnerAuthentication, error: &error)
                        {
                            context.evaluatePolicy(
                                .deviceOwnerAuthentication, localizedReason: reason,
                                reply: onAuth)
                        } else {
                            sequence.onReject()
                        }
                    }

                    hideOverlaySheet()
                },
                label: {
                    if case .sessionRequest = sequence.type {
                        Text("Connect")
                            .frame(maxWidth: .infinity)
                    } else {
                        Label(
                            title: {
                                Text("Confirm")
                            },
                            icon: {
                                Symbol(decorative: .faceid)
                            }
                        )
                        .frame(maxWidth: .infinity)

                    }
                }
            ).buttonStyle(.wallet(.primary))
        }
    }
}

public struct MaliciousSiteView: View {
    @Environment(\.hideOverlay) private var hideOverlaySheet
    let domain: String
    let trustSignal: TrustSignal
    let alternativeDomain: String?

    let navigateToAlternateDomain: () -> Void
    let closeTab: () -> Void

    public init(
        domain: String, trustSignal: TrustSignal, alternativeDomain: String?,
        navigateToAlternateDomain: @escaping () -> Void, closeTab: @escaping () -> Void
    ) {
        self.domain = domain
        self.trustSignal = trustSignal
        self.alternativeDomain = alternativeDomain
        self.navigateToAlternateDomain = navigateToAlternateDomain
        self.closeTab = closeTab
    }

    public var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image("malicious-warning")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .background(Color.white)
                    .clipShape(Circle())
                Text(domain)
                    .withFont(.labelLarge)
                    .foregroundColor(.label)
                if let trustedDomain = alternativeDomain {
                    (Text("This site's address is misleadingly similar to a verified site ")
                        + Text(trustedDomain).bold())
                } else if case .malicious = trustSignal {
                    Text("This site has been identified as malicious.")
                }
            }
            .withFont(unkerned: .bodyLarge)
            .foregroundColor(Color(light: .brand.variant.red, dark: .brand.red))
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color.quaternarySystemFill)
            .cornerRadius(12)
            Text("To protect your wallet, we will not connect to this site.")
                .withFont(.bodyXLarge)
                .foregroundColor(.label)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
            VStack(spacing: 16) {
                if let trustedDomain = alternativeDomain {
                    Button(
                        action: {
                            navigateToAlternateDomain()
                            DispatchQueue.main.async {
                                hideOverlaySheet()
                            }
                        },
                        label: {
                            Text("Navigate to \(trustedDomain)")
                                .frame(maxWidth: .infinity)
                        }
                    ).buttonStyle(.wallet(.primary))
                }
                Button(
                    action: {
                        closeTab()
                        hideOverlaySheet()
                    },
                    label: {
                        Text("Close Tab")
                            .frame(maxWidth: .infinity)
                    }
                ).buttonStyle(.wallet(.secondary))
            }.padding(.bottom, 16)
        }
        .padding(12)
        .padding(.bottom, 24)
    }
}

public struct ImportCredentialsView: View {
    @Environment(\.hideOverlay) private var hideOverlaySheet
    let importCredentials: () -> Void

    public init(importCredentials: @escaping () -> Void) {
        self.importCredentials = importCredentials
    }

    public var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image("wallet-wordmark")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)
                    .padding(.vertical, 8)
                Symbol(decorative: .lockShield, size: 36)
                    .gradientForeground()
                    .padding(4)
                    .background(Color.background)
                    .clipShape(Circle())
                Text("Securely import your wallet credentials")
                    .withFont(.headingLarge)
                    .foregroundColor(.label)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)

                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Symbol(decorative: .signature, style: .bodyLarge)
                            .frame(minWidth: 32)
                        Text("Sign into dApps")
                            .withFont(unkerned: .bodyLarge)
                            .foregroundColor(.secondaryLabel)
                    }.frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 4) {
                        Symbol(decorative: .creditcardFill, style: .bodyLarge)
                            .frame(minWidth: 32)
                        Text("Purchase NFTs")
                            .withFont(unkerned: .bodyLarge)
                            .foregroundColor(.secondaryLabel)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    HStack(spacing: 4) {
                        Symbol(decorative: .lockOpenFill, style: .bodyLarge)
                            .frame(minWidth: 32)
                        Text("Unlock customized experiences")
                            .withFont(unkerned: .bodyLarge)
                            .foregroundColor(.secondaryLabel)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(WalletTheme.gradient.opacity(0.08))
            .cornerRadius(12)

            Text(
                "You should only enter your these credentials while importing a wallet, never on any other screen"
            )
            .withFont(.bodyMedium)
            .foregroundColor(.secondaryLabel)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            VStack(spacing: 16) {
                Button(
                    action: {
                        hideOverlaySheet()
                        DispatchQueue.main.async {
                            importCredentials()
                        }
                    },
                    label: {
                        Text("Import Wallet Credentials")
                            .frame(maxWidth: .infinity)
                    }
                ).buttonStyle(.wallet(.primary))
                Button(
                    action: {
                        hideOverlaySheet()
                    },
                    label: {
                        Text("Ask Again Later")
                            .frame(maxWidth: .infinity)
                    }
                ).buttonStyle(.wallet(.secondary))
            }.padding(.bottom, 16)
        }
        .padding(12)
        .padding(.bottom, 24)
    }
}

public struct WalletSequenceBottomInfoPanel: View {
    let sequence: SequenceInfo
    let wallet: WalletAccessor
    let balance: String?
    let walletDisplayName: String

    @Binding var userSelectedChain: EthNode?

    public init(
        sequence: SequenceInfo, wallet: WalletAccessor, balance: String?, walletDisplayName: String,
        userSelectedChain: Binding<EthNode?>
    ) {
        self.sequence = sequence
        self.wallet = wallet
        self.balance = balance
        self.walletDisplayName = walletDisplayName
        self._userSelectedChain = userSelectedChain
    }

    var chainToUse: EthNode {
        userSelectedChain ?? sequence.chain
    }

    var bottomLeftHeader: String {
        switch sequence.type {
        case .sendTransaction:
            return "Transaction Fee"
        default:
            return "Wallet"
        }
    }

    @ViewBuilder var bottomRightInfo: some View {
        switch sequence.type {
        case .sessionRequest:
            Menu(
                content: {
                    ForEach(EthNode.allCases) { node in
                        Button(
                            action: {
                                userSelectedChain = node
                            },
                            label: {
                                Text(node.rawValue)
                                    .withFont(.labelMedium)
                                    .lineLimit(1)
                                    .foregroundColor(.label)
                                    .frame(maxWidth: 150, alignment: .trailing)
                            })
                    }
                },
                label: {
                    HStack(spacing: 6) {
                        switch chainToUse {
                        case .Polygon:
                            TokenType.matic.polygonLogo
                        default:
                            TokenType.matic.ethLogo
                        }
                        Text(chainToUse.rawValue)
                            .withFont(.labelLarge)
                            .lineLimit(1)
                            .foregroundColor(.label)
                        Symbol(decorative: .chevronDown)
                            .foregroundColor(.label)
                    }.frame(maxWidth: 150, alignment: .trailing)

                })

        default:
            Text(
                "\(balance ?? " ") \(chainToUse.currency.currency.rawValue)"
            )
            .withFont(.labelLarge)
            .lineLimit(1)
            .foregroundColor(.label)
            .frame(maxWidth: 150, alignment: .trailing)
        }
    }

    @ViewBuilder var bottomLeftInfo: some View {
        switch sequence.type {
        case .sendTransaction:
            TransactionFeeView(
                wallet: wallet,
                chain: sequence.chain,
                transaction: sequence.transaction!,
                options: sequence.options!
            )
        default:
            HStack(spacing: 8) {
                WalletProfilePicture(size: CGSize(width: 22, height: 22))
                Text(walletDisplayName)
                    .withFont(.labelLarge)
                    .lineLimit(1)
                    .gradientForeground()
                    .frame(maxWidth: 150, alignment: .leading)
            }
        }
    }

    var bottomRightHeader: String {
        switch sequence.type {
        case .sessionRequest:
            return "Network"
        default:
            return "Balance"
        }
    }

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(bottomLeftHeader)
                    .withFont(.headingSmall)
                    .foregroundColor(.secondaryLabel)
                bottomLeftInfo
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                Text(bottomRightHeader)
                    .withFont(.headingSmall)
                    .foregroundColor(.secondaryLabel)
                bottomRightInfo
            }
        }
    }
}

public struct WalletSequenceMessage: View {
    let type: SequenceType
    let dAppName: String

    public init(type: SequenceType, dAppName: String) {
        self.type = type
        self.dAppName = dAppName
    }

    var message: Text {
        switch type {
        case .sessionRequest:
            return Text(dAppName).bold() + Text(" wants to connect to your wallet")
        case .personalSign:
            return Text(dAppName).bold() + Text(" wants to confirm your ownership of this wallet.")
        case .signTypedData:
            return Text(dAppName).bold()
                + Text(" wants to facilitate a transaction on your behalf.")
        case .sendTransaction:
            return Text("Confirm this transaction with ") + Text(dAppName).bold() + Text("?")
        }
    }

    var warning: String {
        switch type {
        case .personalSign:
            return
                " Signing this message does not give control over your assets."
        case .signTypedData:
            return " You will be granting this site control over your assets. Proceed with caution."
        default:
            return ""
        }
    }

    public var body: some View {
        (message
            + Text(warning).foregroundColor(
                type == .personalSign ? .label : Color(light: .brand.red, dark: .brand.variant.red)))
            .withFont(.headingLarge)
            .foregroundColor(.label)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}
