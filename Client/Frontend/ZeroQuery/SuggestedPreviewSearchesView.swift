// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct SuggestedPreviewSearchesView: View {
    @Environment(\.onOpenURL) private var openURL
    let queryList = ["best headphones", "lemon bar recipe", "react hooks"]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(queryList, id: \.self) { query in
                Button(action: { onClick(input: query) }) {
                    HStack {
                        Symbol(decorative: .magnifyingglass)
                        Text(query)
                            .foregroundColor(.label)
                        Spacer()
                    }
                    .frame(height: 37)
                    .padding(.horizontal, ZeroQueryUX.Padding)

                }
                .buttonStyle(.tableCell)
            }
        }
        .accentColor(Color(light: .ui.gray70, dark: .secondaryLabel))
        .padding(.top, 7)
    }

    func onClick(input: String) {
        if let target = SearchEngine.current.searchURLForQuery(input) {
            var attributes = EnvironmentHelper.shared.getFirstRunAttributes()
            attributes.append(
                ClientLogCounterAttribute(
                    key: "sample query",
                    value: input))
            ClientLogger.shared.logCounter(.PreviewSampleQueryClicked, attributes: attributes)
            openURL(target)
        }
    }
}

struct PreviewModeQueryChipsView_Previews: PreviewProvider {
    static var previews: some View {
        SuggestedPreviewSearchesView()
    }
}
