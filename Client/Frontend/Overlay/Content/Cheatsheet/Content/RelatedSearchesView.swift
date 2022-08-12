// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

// RandomAccessCollection is to satisfy the requirements of `ForEach`
struct RelatedSearchesView<T: RandomAccessCollection>: View where T.Element == String {
    let title: LocalizedStringKey
    let searches: T

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .withFont(.headingXLarge)

            ForEach(searches, id: \.self) { search in
                QueryButtonView(query: search)
            }
        }
        .padding(.horizontal, CheatsheetUX.horizontalPadding)
    }
}
