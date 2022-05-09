// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI
import web3swift

private struct XYZIntroModel: Identifiable, Codable {
    var id = UUID().hashValue
    var image: String
    var text: String
}

private class XYZIntroViewModel {
    @Published var dataSource: [XYZIntroModel] = [
        XYZIntroModel(
            image: "xyzintro-3",
            text: "Stake, swap tokens, and connect to dApps"),
        XYZIntroModel(
            image: "xyzintro-2",
            text: "Beat scammers! Receive warnings before connecting"),
    ]
}

public struct XYZIntroView: View {
    fileprivate let viewModel = XYZIntroViewModel()
    @Default(.cryptoPublicKey) var publicKey
    @State var isCreatingWallet: Bool = false
    @Binding var viewState: ViewState
    @State var selectionState: Int

    public init(viewState: Binding<ViewState>) {
        self._viewState = viewState
        self.selectionState = viewModel.dataSource[0].id
    }

    public var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                TabView(selection: $selectionState) {
                    ForEach(
                        viewModel.dataSource, id: \.id,
                        content: {
                            createIntroView(with: $0, proxy: geometry)
                        })
                }
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .tabViewStyle(.page)
                Button(action: { viewState = .starter }) {
                    Text("Let's go!")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.wallet(.primary))
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
    }

    private func createIntroView(with model: XYZIntroModel, proxy: GeometryProxy) -> some View {
        VStack {
            ZStack(alignment: .bottom) {
                Image(model.image)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(width: proxy.size.width, height: proxy.size.width)
                    .padding(.bottom, 20)
                LinearGradient(
                    colors: [Color.background, Color.background.opacity(0)],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(width: proxy.size.width, height: 75)
            }
            Text(model.text)
                .withFont(.displayLarge)
                .gradientForeground()
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .padding(.bottom, 40)
                .padding(.horizontal, 28)
            Spacer()
        }.clipped()
    }
}
