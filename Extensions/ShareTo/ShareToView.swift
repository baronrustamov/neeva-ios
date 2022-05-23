// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Kanna
import SDWebImageSwiftUI
import Shared
import Storage
import SwiftUI

enum ShareToUX {
    static let padding: CGFloat = 12
    static let thumbnailSize: CGFloat = 72
    static let thumbnailCornerRadius: CGFloat = 6
    static let spacing: CGFloat = 4
}

struct ShareToAction<Icon: View>: View {
    let name: String
    let icon: Icon

    var body: some View {
        HStack {
            Text(name)
            Spacer()
            icon
                .frame(width: 24, alignment: .center)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .foregroundColor(.label)
    }
}

struct ShareToView: View {
    let item: ExtensionUtils.ExtractedShareItem?
    let onDismiss: (_ didComplete: Bool) -> Void
    @ObservedObject var viewModel = ShareToViewModel()
    @Environment(\.openURL) var openURL

    var body: some View {
        if case let .shareItem(item) = item {
            NavigationView {
                contentView
                    .padding()
                    .navigationTitle("Back")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { onDismiss(false) }
                        }
                        // hack to get the title to be Neeva while the back button says Back
                        ToolbarItem(placement: .principal) {
                            Text("Neeva").font(.headline)
                        }
                    }
            }
            .navigationViewStyle(.stack)
            .onAppear(perform: {
                viewModel.shareItem = item
                viewModel.getMetadata(with: item.url)
            })
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if viewModel.loading {
            ProgressView()
                .padding(12)
        } else {
            shareView
            Spacer()
        }
    }

    private var shareView: some View {
        VStack(alignment: .leading, spacing: ShareToUX.padding) {
            ItemDetailView(item: $viewModel.shareItem)
            VStack(spacing: 0) {
                NavigationLink(
                    destination: AddToSpaceView(item: viewModel.shareItem, onDismiss: onDismiss)
                ) {
                    ShareToAction(
                        name: "Save to Spaces",
                        icon: Symbol(decorative: .bookmark, size: 18))
                }
                Divider()
                OpenInNeevaView(item: viewModel.shareItem, incognito: false)
                Divider()
                OpenInNeevaView(item: viewModel.shareItem, incognito: true)
                Divider()
                Button(action: {
                    let profile = BrowserProfile(localName: "profile")
                    profile.queue.addToQueue(viewModel.shareItem).uponQueue(.main) { result in
                        profile._shutdown()
                        onDismiss(result.isSuccess)
                    }
                }) {
                    ShareToAction(
                        name: "Load in Background",
                        icon: Symbol(
                            decorative: .squareAndArrowDownOnSquare, size: 18,
                            weight: .regular))
                }
            }
            Spacer()
        }
    }
}

// Select the ShareTo Preview Support target to use previews
struct ShareToView_Previews: PreviewProvider {
    @State static var item = ShareItem(
        url:
            "https://www.bestbuy.com/site/electronics/mobile-cell-phones/abcat0800000.c?id=abcat0800000",
        title: "Cell Phones: New Mobile Phones & Plans - Best Buy",
        description: "description",
        favicon: .init(
            url: "https://pisces.bbystatic.com/image2/BestBuy_US/Gallery/favicon-32-72227.png")
    )
    static var previews: some View {
        ItemDetailView(item: $item)
            .previewLayout(.sizeThatFits)
        ShareToView(item: .shareItem(item), onDismiss: { _ in })
    }
}
