// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI
import WalletCore

struct WalletDashboard: View {
    @EnvironmentObject var model: Web3Model
    @Binding var viewState: ViewState
    @ObservedObject var assetStore: AssetStore

    var body: some View {
        NavigationView {
            List {
                AccountInfoView(viewState: $viewState, model: model)
                if FeatureFlag[.newWeb3Features] {
                    GasFeeView(gasFeeModel: model.gasFeeModel)
                }
                BalancesView(model: model)
                OpenSessionsView(model: model)
                YourNFTsView(assetStore: assetStore)
                UnlockedThemesView(unlockedThemes: model.unlockedThemes)
            }
            .modifier(WalletListStyleModifier())
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.automatic)
    }

}
