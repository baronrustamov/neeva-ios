// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Storage
import SwiftUI
import UIKit
import WebKit

class BackForwardListModel: ObservableObject {
    let profile: Profile
    let backForwardList: WKBackForwardList

    @Published var currentItem: WKBackForwardListItem?
    @Published var listItems = [WKBackForwardListItem]()

    var numberOfItems: Int {
        listItems.count
    }

    func populateListItems(_ bfList: WKBackForwardList) {
        let items =
            bfList.forwardList.reversed() + [bfList.currentItem].compactMap({ $0 })
            + bfList.backList.reversed()

        // error url's are OK as they are used to populate history on session restore.
        listItems = items.filter {
            guard let internalUrl = InternalURL($0.url) else { return true }
            if let url = internalUrl.originalURLFromErrorPage, InternalURL.isValid(url: url) {
                return false
            }
            return true
        }
    }

    init(profile: Profile, backForwardList: WKBackForwardList) {
        self.profile = profile
        self.backForwardList = backForwardList
        self.currentItem = backForwardList.currentItem

        populateListItems(backForwardList)
    }
}

struct BackForwardListView: View {
    private let faviconWidth: CGFloat = 29

    @ObservedObject var model: BackForwardListModel
    var overlayManager: OverlayManager
    var navigationClicked: (WKBackForwardListItem) -> Void

    @State var contentHeight: CGFloat = 0

    var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(model.listItems.enumerated()), id: \.0) { index, item in
                    let url: URL = {
                        guard let internalUrl = InternalURL(item.url) else {
                            return item.url
                        }

                        return internalUrl.extractedUrlParam ?? item.url
                    }()

                    let title: String = {
                        guard let title = item.title else {
                            return url.absoluteString
                        }

                        return title.isEmpty ? url.absoluteString : title
                    }()

                    VStack(alignment: .leading) {
                        Button {
                            if item.url.absoluteString != model.currentItem?.url.absoluteString {
                                navigationClicked(model.listItems[index])
                            }

                            overlayManager.hideCurrentOverlay()
                        } label: {
                            HStack {
                                FaviconView(forSiteUrl: url)
                                    .cornerRadius(3)
                                    .padding(4)
                                    .frame(width: faviconWidth)

                                if item.url.absoluteString == model.currentItem?.url.absoluteString
                                {
                                    Text(title)
                                        .bold()
                                        .withFont(.bodySmall)
                                        .foregroundColor(.label)
                                } else {
                                    Text(title)
                                        .withFont(.bodySmall)
                                        .foregroundColor(.label)
                                }

                                Spacer()
                            }.padding(10)
                        }
                        .buttonStyle(.tableCell)
                        .accessibilityIdentifier("backForwardListItem-\(title)")

                        if index < model.numberOfItems - 1 {
                            Color.gray
                                .frame(width: 2, height: 20)
                                .padding(.leading, 10 + (faviconWidth / 2) - 1)
                                .padding(.vertical, -8)
                                .zIndex(1)
                        }
                    }.onHeightOfViewChanged { height in
                        contentHeight += height
                    }
                }
            }
        }
    }

    var body: some View {
        GeometryReader { geom in
            let maxHeight: CGFloat = {
                // 60 is the minimum amount of padding between the top of the view,
                // and the top of the BackForwardListView so that the user can tap to close.
                // Fictional number which can be modified as needed.
                geom.size.height - 60
            }()

            VStack(spacing: 0) {
                DismissBackgroundView(opacity: 0.2) {
                    overlayManager.hideCurrentOverlay()
                }
                .animation(nil)
                .transition(.fade)

                Group {
                    if #available(iOS 15.0, *) {
                        content.background(.regularMaterial)
                    } else {
                        content.background(Color.DefaultBackground)
                    }
                }.frame(height: min(maxHeight, contentHeight))
            }
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .contain)
            .accessibilityAction(.escape) {
                overlayManager.hideCurrentOverlay()
            }
            .accessibilityAddTraits(.isModal)
            .accessibilityLabel(Text("Back/Forward List"))
        }
    }
}
