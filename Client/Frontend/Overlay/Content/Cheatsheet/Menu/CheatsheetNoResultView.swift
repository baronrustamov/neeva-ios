// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct CheatsheetNoResultView: View {
    @Default(.cheatsheetDebugQuery) var cheatsheetDebugQuery: Bool

    @Environment(\.onOpenURLForCheatsheet) var onOpenURLForCheatsheet

    let currentCheatsheetQueryAsURL: URL?

    var body: some View {
        VStack(alignment: .center) {
            Text("Sorry, we couldn't find any results related to your search")
                .withFont(.headingLarge)
                .foregroundColor(.label)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
            Text("If this persists, let us know what happened, and we'll fix it soon.")
                .withFont(.bodyLarge)
                .foregroundColor(.secondaryLabel)
            Image("question-mark", bundle: .main)
                .resizable()
                .scaledToFit()
                .frame(minHeight: 50, maxHeight: 300)
                .accessibilityHidden(true)
                .padding(.bottom)
            Spacer()

            if cheatsheetDebugQuery {
                VStack(alignment: .leading) {
                    Button(action: {
                        if let url = currentCheatsheetQueryAsURL {
                            onOpenURLForCheatsheet(url, "debug")
                        }
                    }) {
                        HStack {
                            Text("View Query")
                            Symbol(decorative: .arrowUpForward)
                                .scaledToFit()
                        }
                        .foregroundColor(.label)
                    }

                    Button(action: {
                        if let string = currentCheatsheetQueryAsURL?.absoluteString {
                            UIPasteboard.general.string = string
                        }
                    }) {
                        HStack(alignment: .top) {
                            Symbol(decorative: .docOnDoc)
                                .frame(width: 20, height: 20, alignment: .center)
                            Text(currentCheatsheetQueryAsURL?.absoluteString ?? "nil")
                                .withFont(.bodySmall)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .foregroundColor(.secondaryLabel)
                    }
                }
                .padding(.horizontal)
            }
        }
        .multilineTextAlignment(.center)
        .padding(.top, 10)
        .padding(.horizontal, 27)
    }
}
