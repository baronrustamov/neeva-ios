// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Storage
import SwiftUI

struct SuggestedSearchesView: View {
    let profile: Profile
    @StateObject var model = SuggestedSearchesModel()

    @Environment(\.onOpenURL) private var openURL
    @Environment(\.setSearchInput) private var setSearchInput

    var body: some View {
        VStack(spacing: 0) {
            ForEach(model.suggestions.prefix(3), id: \.id) { suggestedSearch in
                Button(
                    action: {
                        if suggestedSearch.isExample {
                            var attributes = EnvironmentHelper.shared.getFirstRunAttributes()
                            attributes.append(
                                ClientLogCounterAttribute(
                                    key: "sample query",
                                    value: suggestedSearch.query))

                            ClientLogger.shared.logCounter(
                                .PreviewSampleQueryClicked, attributes: attributes)
                        } else {
                            ClientLogger.shared.logCounter(
                                LogConfig.Interaction.openSuggestedSearch)
                        }

                        openURL(suggestedSearch.site.url)
                    },
                    label: {
                        HStack {
                            Symbol(
                                decorative: suggestedSearch.isExample ? .magnifyingglass : .clock)
                            Text(
                                suggestedSearch.query.trimmingCharacters(
                                    in: .whitespacesAndNewlines)
                            )
                            .foregroundColor(.label)
                            Spacer()
                        }
                        .frame(height: 37)
                        .padding(.horizontal, ZeroQueryUX.Padding)
                    }
                )
                .onDrag { NSItemProvider(url: suggestedSearch.site.url) }
                .buttonStyle(.tableCell)
                .overlay(
                    Button(action: { setSearchInput(suggestedSearch.query) }) {
                        VStack {
                            Spacer(minLength: 0)
                            Symbol(decorative: .arrowUpLeft)
                                .padding(.horizontal, 5)
                                .padding(.leading)
                            Spacer(minLength: 0)
                        }
                    }.padding(.trailing, ZeroQueryUX.Padding),
                    alignment: .trailing
                )
                .contextMenu {
                    ZeroQueryCommonContextMenuActions(
                        siteURL: suggestedSearch.site.url, title: nil, description: nil)
                }
            }
        }
        .accentColor(Color(light: .ui.gray70, dark: .secondaryLabel))
        .padding(.top, 7)
        .onAppear {
            model.reload(from: profile)
        }
    }
}
