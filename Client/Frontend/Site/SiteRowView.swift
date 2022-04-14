// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Storage
import SwiftUI

struct SiteRowView: View {
    @Environment(\.onOpenURL) var openURL

    let tabManager: TabManager
    private let padding: CGFloat = 4

    var site: Site? = nil
    var savedTab: SavedTab? = nil

    var deleteSite: (Site) -> Void = { _ in }
    var action: () -> Void

    @ViewBuilder
    var siteContent: some View {
        if let site = site {
            let title: String = {
                if site.displayTitle.isEmpty {
                    return site.title
                }

                return site.displayTitle
            }()

            Button {
                action()
                openURL(site.url)
            } label: {
                HStack {
                    FaviconView(forSite: site)
                        .frame(width: HistoryPanelUX.IconSize, height: HistoryPanelUX.IconSize)
                        .padding(.trailing, padding)

                    VStack(alignment: .leading, spacing: padding) {
                        Text(title)
                            .foregroundColor(.label)

                        Text(site.url.absoluteString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }.lineLimit(1)

                    Spacer()
                }
                .padding(.trailing, -6)
                .padding(.horizontal, GroupedCellUX.padding)
                .padding(.vertical, 10)
                .frame(minHeight: GroupedCellUX.minCellHeight)
            }
            .accessibilityLabel(Text(title))
            .accessibilityIdentifier(site.url.absoluteString)
            .buttonStyle(.tableCell)
            .contextMenu {
                TabMenu(tabManager: tabManager).swiftUIOpenInNewTabMenu(site.url)

                Button {
                    deleteSite(site)
                } label: {
                    Label {
                        Text("Delete")
                    } icon: {
                        Symbol(decorative: .trash)
                    }
                }
            }
        }
    }

    @ViewBuilder
    var savedTabContent: some View {
        if let savedTab = savedTab {
            Button(action: action) {
                HStack {
                    if let url = savedTab.url {
                        FaviconView(forSiteUrl: url)
                            .frame(width: HistoryPanelUX.IconSize, height: HistoryPanelUX.IconSize)
                            .padding(.trailing, padding)
                    }

                    VStack(alignment: .leading, spacing: padding) {
                        Text(savedTab.title ?? "")
                            .foregroundColor(.label)

                        Text(savedTab.url?.absoluteString ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }.lineLimit(1)

                    Spacer()
                }
                .padding(.trailing, -6)
                .padding(.horizontal, GroupedCellUX.padding)
                .padding(.vertical, 10)
                .frame(minHeight: GroupedCellUX.minCellHeight)
            }
            .accessibilityLabel(Text(savedTab.title ?? ""))
            .accessibilityIdentifier(savedTab.url?.absoluteString ?? "")
            .buttonStyle(.tableCell)
            .contextMenu {
                TabMenu(tabManager: tabManager).swiftUIOpenInNewTabMenu(savedTab)
            }
        }
    }

    var body: some View {
        if site != nil {
            siteContent
        } else {
            savedTabContent
        }
    }
}
