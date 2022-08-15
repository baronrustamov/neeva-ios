// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SFSafeSymbols
import Shared
import SwiftUI

struct GroupedButtonView: View {
    let label: LocalizedStringKey
    let nicon: Nicon?
    let symbol: SFSymbol?
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    /// - Parameters:
    ///   - label: The text displayed on the button
    ///   - nicon: The Nicon to use
    ///   - isDisabled: Whether to apply gray out disabled style
    init(label: LocalizedStringKey, nicon: Nicon, action: @escaping () -> Void) {
        self.label = label
        self.nicon = nicon
        self.symbol = nil
        self.action = action
    }

    /// - Parameters:
    ///   - label: The text displayed on the button
    ///   - symbol: The SFSymbol to use
    ///   - isDisabled: Whether to apply gray out disabled style
    public init(label: LocalizedStringKey, symbol: SFSymbol, action: @escaping () -> Void) {
        self.label = label
        self.nicon = nil
        self.symbol = symbol
        self.action = action
    }

    var body: some View {
        GroupedCellButton(action: action) {
            VStack(spacing: 4) {
                if let nicon = self.nicon {
                    Symbol(decorative: nicon, size: 20)
                } else if let symbol = self.symbol {
                    Symbol(decorative: symbol, size: 20)
                }

                Text(label).withFont(.bodyLarge)
            }.frame(height: 83)
        }
        .accentColor(isEnabled ? .label : .quaternaryLabel)
    }
}

struct GroupedButtonView_Previews: PreviewProvider {
    static var previews: some View {
        GroupedButtonView(label: "Test", nicon: .house) {}
    }
}
