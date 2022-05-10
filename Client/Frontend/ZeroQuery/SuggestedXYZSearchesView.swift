// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SDWebImageSwiftUI
import Shared
import SwiftUI

enum ZeroQuerySuggestion: Hashable {
    case xyz(String)
    case com(String)

    var query: String {
        switch self {
        case .xyz(let query):
            return query
        case .com(let query):
            return query
        }
    }
}

public struct SuggestedXYZSearchesView: View {
    @Environment(\.onOpenURL) private var openURL
    let suggestionList: [ZeroQuerySuggestion] = [
        .com("Web3 news"), .com("Best Web3 Sites"), .com("Web3 updates"),
    ]

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(suggestionList, id: \.self) { suggestion in
                Button(action: { onClick(input: suggestion) }) {
                    HStack {
                        Symbol(decorative: .magnifyingglass)
                            .foregroundColorOrGradient(.label)
                        switch suggestion {
                        case .xyz:
                            WebImage(url: SearchEngine.nft.icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                                .padding(4)
                                .background(Color.tertiaryBackground)
                                .cornerRadius(4)
                        case .com:
                            if SearchEngine.current.isNeeva {
                                Image("neevaMenuIcon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 16, height: 16)
                                    .padding(4)
                                    .background(Color.tertiaryBackground)
                                    .cornerRadius(4)
                            } else {
                                WebImage(url: SearchEngine.current.icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 16, height: 16)
                                    .padding(4)
                                    .background(Color.tertiaryBackground)
                                    .cornerRadius(4)
                            }
                        }

                        Text(suggestion.query)
                            .withFont(.bodyLarge)
                            .foregroundColorOrGradient(.label)
                        Spacer()
                    }
                    .padding(16)

                }
                .buttonStyle(.tableCell)
            }
        }
        .padding(.top, 8)
    }

    func onClick(input: ZeroQuerySuggestion) {
        switch input {
        case .xyz(let query):
            if let target = SearchEngine.nft.searchURLForQuery(query) {
                openURL(target)
            }
        case .com(let query):
            if let target = SearchEngine.current.searchURLForQuery(query) {
                openURL(target)
            }
        }

    }
}

struct SuggestedXYZSearchesView_Previews: PreviewProvider {
    static var previews: some View {
        SuggestedXYZSearchesView()
    }
}
