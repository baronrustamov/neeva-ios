// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import SDWebImageSwiftUI
import Shared
import Storage
import SwiftUI

private enum ShareToUX {
    static let padding: CGFloat = 12
}

struct ShareToView: View {
    let item: ExtensionUtils.ExtractedShareItem?
    let onDismiss: (_ didComplete: Bool) -> Void

    @Environment(\.openURL) var openURL

    var body: some View {
        if case let .shareItem(item) = item {
            NavigationView {
                VStack(alignment: .leading, spacing: ShareToUX.padding) {
                    ItemDetailView(item: item)
                    VStack(spacing: 0) {
                        NavigationLink(
                            destination: AddToSpaceView(item: item, onDismiss: onDismiss)
                        ) {
                            ShareToAction(
                                name: "Save to Spaces",
                                icon: Symbol(decorative: .bookmark, size: 18))
                        }
                        Divider()
                        OpenInNeevaView(item: item, incognito: false)
                        Divider()
                        OpenInNeevaView(item: item, incognito: true)
                        Divider()
                        Button(action: {
                            let profile = BrowserProfile(localName: "profile")
                            profile.queue.addToQueue(item).uponQueue(.main) { result in
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
            }.navigationViewStyle(.stack)
        }
    }
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

struct ItemDetailView: View {
    let item: ShareItem

    var body: some View {
        HStack(spacing: ShareToUX.padding) {
            WebImage(url: item.favicon?.url)
                .resizable()
                .background(Color.tertiarySystemFill)
                .tapTargetFrame()
                .cornerRadius(8)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title ?? "")
                    .lineLimit(1)
                Text(URL(string: item.url)?.host ?? "")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }.padding(ShareToUX.padding)
    }
}

struct OpenInNeevaView: View {
    @Environment(\.openURL) var openURL

    let item: ShareItem
    let incognito: Bool

    var body: some View {
        Button(action: {
            item.url.addingPercentEncoding(
                withAllowedCharacters: NSCharacterSet.alphanumerics
            )
            .flatMap {
                URL(
                    string: "neeva://open-url?\(incognito ? "private=true&" : "")url=\($0)"
                )
            }
            .map { openURL($0) }
        }) {
            ShareToAction(
                name: incognito ? "Open in Neeva Incognito" : "Open in Neeva",
                icon: Image("open-in-neeva\(incognito ? "-incognito" : "")")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
            )
        }
    }
}

struct AddToSpaceView: View {
    let onDismiss: (_ didComplete: Bool) -> Void

    @StateObject private var request: AddToSpaceRequest

    init(item: ShareItem, onDismiss: @escaping (Bool) -> Void) {
        _request = .init(
            wrappedValue: AddToSpaceRequest(
                title: item.title ?? item.url,
                description: nil,
                url: item.url.asURL!
            ))
        self.onDismiss = onDismiss
    }

    var body: some View {
        let isCreating = request.mode == .saveToNewSpace
        VStack {
            switch request.state {
            case .initial:
                ScrollView(showsIndicators: false) {
                    Shared.AddToSpaceView(request: request)
                }

                if isCreating {
                    Spacer()
                }
            case .creatingSpace, .savingToSpace:
                LoadingView("Saving...")
            case .deletingFromSpace:
                LoadingView("Deleting...")
            case .savedToSpace, .deletedFromSpace:
                Color.clear.onAppear { onDismiss(true) }
            case .failed:
                ErrorView(request.error!, viewName: "ShareTo.AddToSpaceView")
            }
        }
        .navigationTitle(request.mode.title)
        .navigationBarBackButtonHidden(isCreating)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if isCreating {
                    Button("Cancel") {
                        request.mode = .saveToExistingSpace
                    }
                }
            }
        }
    }
}

// Select the ShareTo Preview Support target to use previews
struct ShareToView_Previews: PreviewProvider {
    static let item = ShareItem(
        url:
            "https://www.bestbuy.com/site/electronics/mobile-cell-phones/abcat0800000.c?id=abcat0800000",
        title: "Cell Phones: New Mobile Phones & Plans - Best Buy",
        favicon: .init(
            url: "https://pisces.bbystatic.com/image2/BestBuy_US/Gallery/favicon-32-72227.png")
    )
    static var previews: some View {
        ItemDetailView(item: item)
            .previewLayout(.sizeThatFits)
        ShareToView(item: .shareItem(item), onDismiss: { _ in })
    }
}
