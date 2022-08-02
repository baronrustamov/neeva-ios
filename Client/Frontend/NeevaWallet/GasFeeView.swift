// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI
import WalletCore
import web3swift

enum GasFeeOption: String, CaseIterable {
    case never = "Never"
    case gwei40 = "< 40 gwei"
    case gwei60 = "< 60 gwei"
}

struct GasFeeView: View {
    @EnvironmentObject var model: Web3Model
    @State var isExpanded: Bool = true
    @State var selectedValue: GasFeeOption = .never
    @ObservedObject var gasFeeModel: GasFeeModel
    @Default(.showGasFeeInToolbar) var showGasFeeInToolbar

    private var gasFeeString: String {
        String(format: "%.0f gwei", gasFeeModel.gasPrice)
    }

    var body: some View {
        Section(
            content: {
                content
            },
            header: {
                header
            }
        )
        .modifier(WalletListSeparatorModifier())
    }

    @ViewBuilder
    private var content: some View {
        if isExpanded {
            gasFeeCell
            showInToolbarCell
        }
    }

    private var header: some View {
        WalletHeader(
            title: "Gas Fee",
            isExpanded: $isExpanded
        )
    }

    private var gasFeeCell: some View {
        HStack {
            Image("eth")
                .resizable()
                .frame(width: 36, height: 36, alignment: .leading)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(gasFeeModel.gasFeeState.tintColor, lineWidth: 2)
                )
            Text(verbatim: "Current Gas Fee")
                .foregroundColor(gasFeeModel.gasFeeState.tintColor)
                .withFont(.bodyLarge)
            Spacer()
            Text(gasFeeString)
                .foregroundColor(gasFeeModel.gasFeeState.tintColor)
                .withFont(.bodyLarge)
        }
    }

    private var notifyCell: some View {
        HStack {
            Text(verbatim: "Notify me at")
            Spacer()
            Picker(
                "",
                selection: $selectedValue,
                content: {
                    ForEach(GasFeeOption.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
            )
            .pickerStyle(.menu)
            .accentColor(.label)
            Symbol(
                decorative: .chevronDown,
                style: .bodyMedium
            )
        }
    }

    private var showInToolbarCell: some View {
        HStack {
            Text(verbatim: "Show in toolbar")
            Toggle("", isOn: $showGasFeeInToolbar)
                .toggleStyle(SwitchToggleStyle(tint: Color.ui.adaptive.blue))
        }
    }
}
