// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct PriceHistoryView: View {
    let priceHistory: CheatsheetQueryController.PriceHistory

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Price History").withFont(.headingMedium)
            if let max = priceHistory.Max,
                !max.Price.isEmpty
            {
                HStack {
                    Text("Highest: ").bold()
                    Text("$")
                        + Text(max.Price)

                    if !max.Date.isEmpty {
                        Text("(")
                            + Text(max.Date)
                            + Text(")")
                    }
                }
                .foregroundColor(.hex(0xCC3300))
                .withFont(unkerned: .bodyMedium)
            }

            if let min = priceHistory.Min,
                !min.Price.isEmpty
            {
                HStack {
                    Text("Lowest: ").bold()
                    Text("$")
                        + Text(min.Price)

                    if !min.Date.isEmpty {
                        Text("(")
                            + Text(min.Date)
                            + Text(")")
                    }
                }
                .foregroundColor(.hex(0x008800))
                .withFont(unkerned: .bodyMedium)
            }

            if let average = priceHistory.Average,
                !average.Price.isEmpty
            {
                HStack {
                    Text("Average: ").bold()
                    Text("$")
                        + Text(average.Price)
                }
                .foregroundColor(.hex(0x555555))
                .withFont(unkerned: .bodyMedium)
            }
        }
        .padding(.horizontal, CheatsheetUX.horizontalPadding)
    }
}
