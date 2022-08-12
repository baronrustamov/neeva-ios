// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import Shared
import SwiftUI

enum CheatsheetUX {
    static let horizontalPadding: CGFloat = 16
}

public struct CheatsheetMenuView: View {
    @Default(.seenCheatsheetIntro) var seenCheatsheetIntro: Bool
    @Default(.showTryCheatsheetPopover) var defaultShowTryCheatsheetPopover: Bool

    @Environment(\.hideOverlay) private var hideOverlay
    @Environment(\.onOpenURLForCheatsheet) var onOpenURLForCheatsheet
    @EnvironmentObject private var model: CheatsheetMenuViewModel

    @State var height: CGFloat = 0
    @State var openSupport: Bool = false
    private let menuAction: (OverflowMenuAction) -> Void

    init(menuAction: @escaping (OverflowMenuAction) -> Void) {
        self.menuAction = menuAction
    }

    public var body: some View {
        ZStack {
            // Show Cheatsheet Info if on Neeva domain page
            if NeevaConstants.isInNeevaDomain(model.sourcePage?.url) {
                CheatsheetInfoViewOnSRP {
                    hideOverlay()
                    defaultShowTryCheatsheetPopover = !seenCheatsheetIntro
                }
            } else if !seenCheatsheetIntro {
                CheatsheetInfoViewOnPage {
                    seenCheatsheetIntro = true
                }
                .onDisappear {
                    seenCheatsheetIntro = true
                }
            } else if model.cheatsheetDataLoading {
                CheatsheetLoadingView()
            } else if !model.cheatSheetIsEmpty {
                content
                    .onHeightOfViewChanged { height in
                        self.height = height
                    }
                    .onAppear {
                        model.log(.ShowCheatsheetContent)
                    }
            } else if let error = model.cheatsheetDataError {
                ErrorView(error, in: self, tryAgain: { model.reload() })
            } else if let error = model.searchRichResultsError {
                ErrorView(error, in: self, tryAgain: { model.reload() })
            } else {
                CheatsheetNoResultView(currentCheatsheetQueryAsURL: model.currentQueryAsURL)
                    .onAppear {
                        model.onNoResultViewAppear()
                    }
            }
        }
        .frame(maxWidth: .infinity, minHeight: height < 200 ? 200 : height)
    }

    @ViewBuilder
    var content: some View {
        VStack(alignment: .leading) {
            ForEach(model.results) { result in
                CheatsheetResultView(viewModel: model, result: result)
            }

            Divider()
                .padding(.horizontal, CheatsheetUX.horizontalPadding)
            supportSection
        }
        .selectableIfAvailable(true)
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onChange(of: openSupport) { newValue in
                        if newValue {
                            let image =
                                self
                                .environmentObject(model)
                                .takeScreenshot(
                                    origin: proxy.frame(in: .global).origin,
                                    size: proxy.size
                                )
                            openSupport = false
                            model.log(.OpenCheatsheetSupport)
                            menuAction(.support(screenshot: image))
                        }
                    }
            }
        )
    }

    @ViewBuilder
    var supportSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Support").withFont(.headingXLarge)
                .padding(.bottom, 12)
            Text("Have questions or feedback for NeevaScope?")
                .withFont(.bodyMedium)
                .fixedSize(horizontal: false, vertical: true)
            Button(
                action: {
                    openSupport = true
                },
                label: {
                    HStack {
                        Text("Contact us via Support \(Image(systemName: "bubble.left"))")
                            .foregroundColor(.blue)
                            .underline()
                            .withFont(.bodyMedium)
                        Spacer()
                    }
                })
        }
        .padding(.horizontal, CheatsheetUX.horizontalPadding)
    }
}

struct CheatsheetMenuView_Previews: PreviewProvider {
    static var previews: some View {
        CheatsheetMenuView(menuAction: { _ in })
    }
}
