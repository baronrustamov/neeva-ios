// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI
import WalletCore
import web3swift

struct CryptoWalletView: View {
    @EnvironmentObject var model: Web3Model
    @State var viewState: ViewState = Defaults[.cryptoPublicKey].isEmpty ? .xyzIntro : .dashboard
    let dismiss: () -> Void

    @ViewBuilder var overlay: some View {
        if viewState != .xyzIntro {
            Button(action: dismiss) {
                Text(viewState == .starter ? "Skip" : "Done")
                    .withFont(.labelLarge)
                    .foregroundColor(.ui.adaptive.blue)
                    .frame(height: 48)
            }
            .padding(.top, 44)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
    }

    private static var cryptoPhrases: String {
        NeevaConstants.cryptoKeychain[string: NeevaConstants.cryptoSecretPhrase] ?? ""
    }

    var body: some View {
        VStack(spacing: 0) {
            Image("wallet-wordmark")
                .resizable()
                .scaledToFit()
                .frame(height: viewState == .starter ? 32 : 20)
                .padding(.top, viewState == .starter ? 40 : 16)
                .animation(
                    viewState == .showPhrases || viewState == .importWallet ? .easeInOut : nil
                )
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 16)
                .padding(.top, 44)

            if viewState != .starter {
                Color.ui.adaptive.separator.frame(height: 1)
            }

            ZStack {
                switch viewState {
                case .xyzIntro:
                    XYZIntroView(viewState: $viewState)
                case .starter:
                    WelcomeStarterView(dismiss: dismiss, viewState: $viewState) {
                        ClientLogger.shared.logCounter(
                            .CreatedWallet,
                            attributes: [
                                ClientLogCounterAttribute(
                                    key: LogConfig.Web3Attribute.walletAddress,
                                    value: Defaults[.cryptoPublicKey])
                            ])
                    }
                case .dashboard:
                    WalletDashboard(viewState: $viewState, assetStore: AssetStore.shared)
                case .showPhrases:
                    ShowPhrasesView(dismiss: dismiss, viewState: $viewState)
                case .importWallet:
                    ImportWalletView(dismiss: dismiss, viewState: $viewState) {
                        ClientLogger.shared.logCounter(
                            .ImportedWallet,
                            attributes: [
                                ClientLogCounterAttribute(
                                    key: LogConfig.Web3Attribute.walletAddress,
                                    value: Defaults[.cryptoPublicKey])
                            ])
                    }
                }
            }
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .overlay(
            overlay
        ).onChange(of: viewState) { value in
            if case .starter = viewState {
                Defaults[.walletIntroSeen] = true
            }
        }
    }
}
