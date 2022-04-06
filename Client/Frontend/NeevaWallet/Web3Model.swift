// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import BigInt
import Combine
import Defaults
import Foundation
import Shared
import SwiftUI
import WalletConnectSwift
import WalletCore
import XCGLogger
import web3swift

class Web3Model: ObservableObject, ResponseRelay {
    let openURLForSpace: (URL, String) -> Void

    var publicAddress: String {
        wallet?.publicAddress ?? ""
    }

    func send(
        on chain: EthNode, transactionData: TransactionData
    ) throws -> String {
        try wallet?.send(
            on: chain, transactionData: transactionData) ?? ""
    }

    func sign(on chain: EthNode, message: String) throws -> String {
        try wallet?.sign(on: chain, message: message) ?? ""
    }

    func sign(on chain: EthNode, message: Data) throws -> String {
        try wallet?.sign(on: chain, message: message) ?? ""
    }

    @Published var currentSequence: SequenceInfo? = nil {
        didSet {
            guard currentSequence != nil, wallet != nil else { return }

            tryMatchCurrentPageToCollection()
            updateBalances()
        }
    }

    @Published var currentSession: Session? {
        didSet {
            guard currentSession != nil else { return }
            tryMatchCurrentPageToCollection()
        }
    }

    @Published var showingWalletDetails = false
    @Published var trustSignal: TrustSignal = .notTrusted
    @Published var alternateTrustedDomain: String? = nil
    @Published var matchingCollection: Collection?
    @Published var showingMaliciousSiteWarning = false

    #if XYZ
        var serverManager: WalletServerManager?
        weak var toastDelegate: ToastDelegate?
    #endif

    var server: Server? {
        #if XYZ
            return serverManager?.server
        #endif
        return nil
    }

    let presenter: WalletConnectPresenter
    var selectedTab: Tab?
    var wallet: WalletAccessor?
    var communityBasedTrustSignals = [String: TrustSignal]()
    let walletDetailsModel: WalletDetailsModel

    func updateTrustSignals(url: URL?) {
        trustSignal = computeTrustSignal(url: url)
        alternateTrustedDomain = computeTrustedDomain(url: url)
    }

    private func computeTrustSignal(url: URL?) -> TrustSignal {
        if let matchingCollection = matchingCollection,
            matchingCollection.safelistRequestStatus >= .approved
        {
            return .trusted
        }

        guard let baseDomain = url?.baseDomain else { return .notTrusted }

        if let signal = communityBasedTrustSignals[baseDomain] {
            return signal
        }

        return .notTrusted
    }

    private func computeTrustedDomain(url: URL?) -> String? {
        guard
            let url =
                InternalURL(url)?.isSessionRestore == true
                ? InternalURL(url)?.extractedUrlParam : url,
            let baseDomain = url.baseDomain,
            case .notTrusted = trustSignal,
            let index = baseDomain.lastIndex(of: ".")
        else {
            return nil
        }

        let alternateDomain = web3Extensions.map({ String(baseDomain.prefix(upTo: index)) + $0 })
            .filter({ communityBasedTrustSignals[$0] == .trusted }).first

        return alternateDomain != baseDomain ? alternateDomain : nil
    }

    var balances: [TokenType: String?] = [
        .ether: nil, .wrappedEther: nil, .matic: nil, .usdc: nil, .usdt: nil, .shib: nil,
        .wrappedEtherOnPolygon: nil, .maticOnPolygon: nil, .usdcOnPolygon: nil, .usdtOnPolygon: nil,
    ]

    func balanceFor(_ token: TokenType) -> String? {
        balances[token]!
    }

    private var selectedTabSubscription: AnyCancellable? = nil
    private var urlSubscription: AnyCancellable? = nil
    private var walletConnectSubscription: AnyCancellable? = nil
    private let closeTab: (Tab) -> Void

    init(presenter: WalletConnectPresenter, tabManager: TabManager) {
        self.presenter = presenter
        self.closeTab = { tab in
            tabManager.close(tab)
        }
        self.openURLForSpace = {
            tabManager.createOrSwitchToTabForSpace(for: $0, spaceID: $1)
        }

        self.walletDetailsModel = WalletDetailsModel()
        self.currentSession =
            allSavedSessions.first(where: {
                $0.dAppInfo.peerMeta.url.baseDomain
                    == tabManager.selectedTab?.url?.baseDomain
            })
        self.selectedTab = tabManager.selectedTab
        self.wallet = NeevaConstants.currentTarget == .xyz ? WalletAccessor() : nil

        self.selectedTabSubscription = tabManager.selectedTabPublisher.sink { tab in
            guard let tab = tab else { return }

            self.selectedTab = tab
            self.updateCurrentSession()
            self.urlSubscription = tab.$url.sink { url in
                self.updateCurrentSession(with: url)
            }
        }

        self.walletConnectSubscription = WalletConnectDetector.shared.$walletConnectURL.sink {
            url in
            if let baseDomain = url?.baseDomain, baseDomain == self.selectedTab?.url?.baseDomain {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.tryWalletConnect()
                }
            }
        }

        #if XYZ
            self.serverManager = WalletServerManager(delegate: self)
        #endif
    }

    var allSavedSessions: [Session] {
        let decoder = JSONDecoder()
        return Defaults[.sessionsPeerIDs].compactMap { Defaults[.dAppsSession($0)] }.map {
            try? decoder.decode(Session.self, from: $0)
        }.compactMap { $0 }
    }

    var unlockedThemes: [Web3Theme] {
        return Array(AssetStore.shared.availableThemes)
    }

    func updateBalances() {
        CurrencyStore.shared.refresh()
        balances.keys.forEach { token in
            wallet?.tokenBalance(token: token) { balance in
                self.balances[token] = balance
                self.objectWillChange.send()
            }
        }
    }

    func updateCurrentSession() {
        DispatchQueue.main.async {
            self.updateCurrentSession(with: self.selectedTab?.url)
        }
    }

    private func updateCurrentSession(with url: URL?) {
        guard wallet?.ethereumAddress != nil else {
            // Avoid updating this published state.
            // If there is no wallet, it will keep updating to nil.
            return
        }

        let url =
            InternalURL(url)?.isSessionRestore == true
            ? InternalURL(url)?.extractedUrlParam : url

        self.matchingCollection = nil
        updateTrustSignals(url: url)

        if let domain = url?.baseDomain {
            if self.communityBasedTrustSignals[domain] == nil {
                TrustSignalController.getTrustSignals(domain: domain) { result in
                    switch result {
                    case .failure(let error):
                        Logger.browser.info("Trust signal query failed with \(error)")
                    case .success(let signals):
                        signals.forEach({
                            guard let domain = $0.domain, let signal = $0.signal else { return }
                            self.communityBasedTrustSignals[domain] = signal
                        })

                        self.updateTrustSignals(url: url)

                        self.checkForMaliciousContent(domain: domain)
                    }
                }
            } else {
                checkForMaliciousContent(domain: domain)
            }
        }

        DispatchQueue.main.async {
            self.currentSession =
                self.allSavedSessions.first(where: {
                    $0.dAppInfo.peerMeta.url.baseDomain == url?.baseDomain
                })
            if let session = self.currentSession, let server = self.server,
                !(server.openSessions().contains(where: {
                    session.dAppInfo.peerId == $0.dAppInfo.peerId
                }))
            {
                try? self.server?.reconnect(to: session)
            }
        }
    }

    func checkForMaliciousContent(domain: String) {
        if let tab = self.selectedTab, !showingMaliciousSiteWarning,
            alternateTrustedDomain != nil || trustSignal == .malicious
        {
            showingMaliciousSiteWarning = true
            presenter.showModal(
                style: .spaces,
                headerButton: nil,
                content: {
                    MaliciousSiteView(
                        domain: domain,
                        trustSignal: self.trustSignal,
                        alternativeDomain: self.alternateTrustedDomain,
                        navigateToAlternateDomain: {
                            self.selectedTab?.loadRequest(
                                URLRequest(
                                    url: URL(
                                        string: "https://\(self.alternateTrustedDomain ?? "")")!))
                        },
                        closeTab: {
                            self.closeTab(tab)
                        }
                    )
                    .overlayIsFixedHeight(isFixedHeight: true)
                }, onDismiss: { self.reset() })
        }
    }

    func reset() {
        currentSequence = nil
        showingMaliciousSiteWarning = false
    }

    func tryWalletConnect() {
        if let wallet = wallet, wallet.ethereumAddress == nil || !wallet.web3IsValid,
            !Defaults[.cryptoPublicKey].isEmpty
        {
            // This would only happen if we created/imported a wallet within this session, or
            // there was a network issue while creating web3 nodes.
            self.wallet = WalletAccessor()
        }
        selectedTab?.webView?
            .evaluateJavascriptInDefaultContentWorld(
                WalletConnectDetector.scrapeWalletConnectURI
            ) {
                object, error in
                guard let walletConnectUriString = object as? String,
                    let wcURL = WCURL(walletConnectUriString.removingPercentEncoding ?? "")
                else { return }
                self.presenter.connectWallet(to: wcURL)
                DispatchQueue.main.async {
                    self.tryMatchCurrentPageToCollection()
                }
            }
    }

    func tryMatchCurrentPageToCollection() {
        matchingCollection = AssetStore.shared.collections.first(
            where: {
                $0.externalURL?.baseDomain
                    == self.selectedTab?.url?.baseDomain
            })

        guard matchingCollection?.stats == nil else { return }

        selectedTab?.webView?
            .evaluateJavascriptInDefaultContentWorld(
                Collection.scrapeForOpenSeaLink
            ) {
                object, error in
                guard let openSeaSlugs = object as? [String],
                    !openSeaSlugs.isEmpty
                else { return }

                DispatchQueue.global(qos: .userInitiated).async {
                    AssetStore.shared.fetch(collection: openSeaSlugs[0]) { collection in
                        if self.selectedTab?.url?.baseDomain
                            == collection.externalURL?.baseDomain
                        {
                            DispatchQueue.main.async {
                                self.matchingCollection = collection
                            }
                        }
                    }
                }
            }
    }

    func startSequence() {
        #if XYZ
            presenter.showModal(
                style: .spaces,
                headerButton: nil,
                content: {
                    WalletSequenceContent(model: self)
                        .overlayIsFixedHeight(isFixedHeight: true)
                }, onDismiss: { self.reset() })
        #endif
    }

    func showWalletPanel() {
        #if XYZ
            updateBalances()
            presenter.presentFullScreenModal(
                content: AnyView(
                    CryptoWalletView(dismiss: {
                        self.presenter.dismissCurrentOverlay()
                        if !Defaults[.cryptoPublicKey].isEmpty, self.wallet?.ethereumAddress == nil
                        {
                            DispatchQueue.global(qos: .userInitiated).async {
                                self.wallet = WalletAccessor()
                                self.updateBalances()
                            }
                            AssetStore.shared.refresh()
                            if !Defaults[.walletOnboardingDone] {
                                DispatchQueue.main.async {
                                    self.showWalletPanelHalfScreen()
                                }
                                Defaults[.walletOnboardingDone] = true
                            }

                        }
                    })
                    .environmentObject(self)
                    .overlayIsFixedHeight(isFixedHeight: true)
                    .onDisappear {
                        self.reset()
                    }
                ), completion: {})
        #endif
    }

    func showWalletPanelHalfScreen() {
        #if XYZ
            presenter.showModal(
                style: .grouped,
                headerButton: nil,
                content: {
                    CryptoWalletView(dismiss: { self.presenter.dismissCurrentOverlay() })
                        .frame(minHeight: 500)
                        .environmentObject(self)
                        .overlayIsFixedHeight(isFixedHeight: true)
                }, onDismiss: {})
        #endif
    }

    func toggle(session: Session, to chain: EthNode) {
        guard let walletInfo = session.walletInfo else {
            return
        }
        let info = Session.WalletInfo(
            approved: walletInfo.approved,
            accounts: walletInfo.accounts,
            chainId: chain.id, peerId: walletInfo.peerId,
            peerMeta: walletInfo.peerMeta)

        var updatedSession = session
        updatedSession.walletInfo = info
        Defaults[.dAppsSession(updatedSession.dAppInfo.peerId)] =
            try! JSONEncoder().encode(updatedSession)
        Defaults[.sessionsPeerIDs].insert(updatedSession.dAppInfo.peerId)

        if let server = server,
            server.openSessions().contains(where: { session.dAppInfo.peerId == $0.dAppInfo.peerId })
        {
            try? server.updateSession(session, with: info)
            try? server.reconnect(to: updatedSession)
            if updatedSession.dAppInfo.peerId == currentSession?.dAppInfo.peerId {
                currentSession = updatedSession
            }
        }

        ClientLogger.shared.logCounter(
            .SwitchedChain,
            attributes: [
                ClientLogCounterAttribute(
                    key: LogConfig.Web3Attribute.walletAddress, value: Defaults[.cryptoPublicKey]),
                ClientLogCounterAttribute(
                    key: LogConfig.Web3Attribute.connectedSite,
                    value: session.dAppInfo.peerMeta.url.absoluteString),
            ])

        objectWillChange.send()
    }

    func send(_ response: Response) {
        server?.send(response)
    }

    func askToTransact(
        request: Request,
        options: TransactionOptions,
        transaction: EthereumTransaction,
        transact: @escaping (EthNode) -> String
    ) {
        guard
            let session = allSavedSessions.first(where: {
                $0.dAppInfo.peerMeta.url.baseDomain
                    == currentSession?.dAppInfo.peerMeta.url.baseDomain
            }), let walletInfo = session.walletInfo
        else {
            send(.reject(request))
            return
        }
        let dappInfo = session.dAppInfo

        DispatchQueue.main.async {
            self.currentSequence = SequenceInfo(
                type: .sendTransaction,
                thumbnailURL: dappInfo.peerMeta.icons.first ?? .aboutBlank,
                dAppMeta: dappInfo.peerMeta,
                chain: EthNode.from(chainID: walletInfo.chainId),
                message:
                    "This will transfer this amount from your wallet to a wallet provided by \(dappInfo.peerMeta.name).",
                onAccept: { chainId in
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.server?.send(
                            .transaction(transact(EthNode.from(chainID: chainId)), for: request)
                        )
                        ClientLogger.shared.logCounter(
                            .TransactionSuccessful,
                            attributes: [
                                ClientLogCounterAttribute(
                                    key: LogConfig.Web3Attribute.transactionAmount,
                                    value: Web3Utils.formatToEthereumUnits(
                                        options.value ?? BigUInt.zero, toUnits: .eth)),
                                ClientLogCounterAttribute(
                                    key: LogConfig.Web3Attribute.walletAddress,
                                    value: Defaults[.cryptoPublicKey]),
                                ClientLogCounterAttribute(
                                    key: LogConfig.Web3Attribute.connectedSite,
                                    value: dappInfo.peerMeta.url.absoluteString),
                            ])
                    }
                },
                onReject: {
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.server?.send(.reject(request))
                    }
                },
                transaction: transaction,
                options: options
            )
            ClientLogger.shared.logCounter(
                .TransactionAttempted,
                attributes: [
                    ClientLogCounterAttribute(
                        key: LogConfig.Web3Attribute.transactionAmount,
                        value: Web3Utils.formatToEthereumUnits(
                            options.value ?? BigUInt.zero, toUnits: .eth)),
                    ClientLogCounterAttribute(
                        key: LogConfig.Web3Attribute.walletAddress,
                        value: Defaults[.cryptoPublicKey]),
                    ClientLogCounterAttribute(
                        key: LogConfig.Web3Attribute.connectedSite,
                        value: dappInfo.peerMeta.url.absoluteString),
                ])
            self.startSequence()
        }
    }

    func askToSign(
        request: Request, message: String, typedData: Bool, sign: @escaping (EthNode) -> String
    ) {
        guard
            let session = allSavedSessions.first(where: {
                $0.dAppInfo.peerMeta.url.baseDomain
                    == currentSession?.dAppInfo.peerMeta.url.baseDomain
            }), let walletInfo = session.walletInfo
        else {
            send(.reject(request))
            return
        }
        let dappInfo = session.dAppInfo

        DispatchQueue.main.async {
            self.currentSequence = SequenceInfo(
                type: typedData ? .signTypedData : .personalSign,
                thumbnailURL: dappInfo.peerMeta.icons.first ?? .aboutBlank,
                dAppMeta: dappInfo.peerMeta,
                chain: EthNode.from(chainID: walletInfo.chainId),
                message:
                    message,
                onAccept: { chainId in
                    DispatchQueue.global(qos: .userInitiated).async {
                        let signature = sign(EthNode.from(chainID: chainId))
                        if !signature.isEmpty {
                            ClientLogger.shared.logCounter(
                                .PersonalSign,
                                attributes: [
                                    ClientLogCounterAttribute(
                                        key: LogConfig.Web3Attribute.walletAddress,
                                        value: Defaults[.cryptoPublicKey]),
                                    ClientLogCounterAttribute(
                                        key: LogConfig.Web3Attribute.connectedSite,
                                        value: dappInfo.peerMeta.url.absoluteString),
                                ])
                        }
                        self.server?.send(.signature(signature, for: request))
                    }
                },
                onReject: {
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.server?.send(.reject(request))
                    }
                })
            self.startSequence()
        }
    }
}

class WalletDetailsModel: ObservableObject {
    @Published var showingWalletDetails = false
}

#if XYZ
    extension Web3Model: WalletServerManagerDelegate {
        func shouldShowToast(for message: LocalizedStringKey) {
            self.toastDelegate?.shouldShowToast(for: message)
        }

        func updateCurrentSequence(_ sequence: SequenceInfo) {
            self.currentSequence = sequence
        }
    }
#endif
