// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

public struct DateSectionHeaderView: View {
    let text: String

    var title: some View {
        HStack {
            Text(String(text))
                .fontWeight(.medium)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.leading)
        .padding(.top, 8)
    }

    public var body: some View {
        VStack {
            Color.tertiarySystemFill.frame(height: 8)
            title
        }
    }

    public init(text: String) {
        self.text = text
    }
}

struct DateSectionHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        DateSectionHeaderView(text: "Today")
    }
}
