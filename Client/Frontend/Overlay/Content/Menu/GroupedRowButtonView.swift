// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SFSafeSymbols
import Shared
import SwiftUI

struct GroupedRowButtonView: View {
    let label: LocalizedStringKey
    let nicon: Nicon?
    let symbol: SFSymbol?
    let action: () -> Void
    let isPromo: Bool

    /// - Parameters:
    ///   - label: The text displayed on the button
    ///   - nicon: The Nicon to use
    init(label: LocalizedStringKey, nicon: Nicon?, action: @escaping () -> Void) {
        self.label = label
        self.nicon = nicon
        self.symbol = nil
        self.action = action
        self.isPromo = false
    }

    /// - Parameters:
    ///   - label: The text displayed on the button
    ///   - symbol: The SFSymbol to use
    init(label: LocalizedStringKey, symbol: SFSymbol?, action: @escaping () -> Void) {
        self.label = label
        self.nicon = nil
        self.symbol = symbol
        self.action = action
        self.isPromo = false
    }

    /// - Parameters:
    ///   - label: The text displayed on the button
    public init(label: LocalizedStringKey, isPromo: Bool, action: @escaping () -> Void) {
        self.label = label
        self.nicon = nil
        self.symbol = nil
        self.action = action
        self.isPromo = isPromo
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                Text(label)
                    .withFont(isPromo ? .headingMedium : .bodyLarge)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 10)
                Spacer()
                Group {
                    if let nicon = self.nicon {
                        Symbol(decorative: nicon, size: 18)
                    } else if let symbol = self.symbol {
                        Symbol(decorative: symbol, size: 18)
                    }
                }.frame(width: 24, height: 24)
            }
            .padding(.trailing, -6)
            .padding(.horizontal, GroupedCellUX.padding)
            .frame(minHeight: GroupedCellUX.minCellHeight)
        }
        .hoverEffect(.highlight)
        .buttonStyle(.tableCell)
    }
}

struct GroupedRowButtonView_Previews: PreviewProvider {
    static var previews: some View {
        GroupedRowButtonView(label: "Test", nicon: .gear) {}
            .previewLayout(.sizeThatFits)
    }
}
