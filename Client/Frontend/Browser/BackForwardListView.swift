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

    @Published var sites = [Site]()
    @Published var currentItem: WKBackForwardListItem?
    @Published var listItems = [WKBackForwardListItem]()

    var numberOfItems: Int {
        sites.count
    }

    func loadSitesFromProfile() {
        let sql = profile.favicons as! SQLiteHistory
        let urls: [String] = listItems.compactMap {
            guard let internalUrl = InternalURL($0.url) else {
                return $0.url.absoluteString
            }

            return internalUrl.extractedUrlParam?.absoluteString
        }

        sql.getSites(forURLs: urls).uponQueue(.main) { result in
            guard let results = result.successValue else {
                return
            }

            // Add all results into the sites dictionary
            self.sites = results.compactMap { result in
                if let site = result { return site }
                return nil
            }.reversed()
        }
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
        loadSitesFromProfile()
    }
}

struct BackForwardListView: View {
    private let faviconWidth: CGFloat = 29

    @ObservedObject var model: BackForwardListModel
    var overlayManager: OverlayManager
    var navigationClicked: (WKBackForwardListItem) -> Void

    var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(model.sites.enumerated()), id: \.0) { index, item in
                Button {
                    if item.url.absoluteString != model.currentItem?.url.absoluteString {
                        navigationClicked(model.listItems[index])
                    }

                    overlayManager.hideCurrentOverlay()
                } label: {
                    HStack {
                        FaviconView(forSite: item)
                            .cornerRadius(3)
                            .padding(4)
                            .frame(width: faviconWidth)

                        if item.url.absoluteString == model.currentItem?.url.absoluteString {
                            Text(item.title.isEmpty ? item.url.absoluteString : item.title)
                                .bold()
                                .withFont(.bodySmall)
                                .foregroundColor(.label)
                        } else {
                            Text(item.title.isEmpty ? item.url.absoluteString : item.title)
                                .withFont(.bodySmall)
                                .foregroundColor(.label)
                        }

                        Spacer()
                    }.padding(10)
                }.buttonStyle(.tableCell)

                if index < model.numberOfItems - 1 {
                    Color.gray
                        .frame(width: 2, height: 20)
                        .padding(.leading, 10 + (faviconWidth / 2) - 1)
                        .padding(.vertical, -8)
                        .zIndex(1)
                }
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            DismissBackgroundView(opacity: 0.2) {
                overlayManager.hideCurrentOverlay()
            }.animation(nil).transition(.fade)

            if #available(iOS 15.0, *) {
                ScrollView {
                    content
                }
                .background(.regularMaterial)
                .fixedSize(horizontal: false, vertical: true)
            } else {
                ScrollView {
                    content
                }
                .background(Color.DefaultBackground)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityAction(.escape) {
            overlayManager.hideCurrentOverlay()
        }
        .accessibilityAddTraits(.isModal)
    }
}
