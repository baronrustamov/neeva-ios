// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Storage
import SwiftUI

private struct SiteRowViewUX {
    static let padding: CGFloat = 4
}

enum SiteRowData {
    case site(Site, (Site) -> Void)
    case savedTab(SavedTab)
}

private struct SiteRowButton: View {
    let title: String?
    let url: URL?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let url = url {
                    FaviconView(forSiteUrl: url)
                        .frame(width: HistoryPanelUX.IconSize, height: HistoryPanelUX.IconSize)
                        .padding(.trailing, SiteRowViewUX.padding)
                }

                VStack(alignment: .leading, spacing: SiteRowViewUX.padding) {
                    Text(title ?? "")
                        .foregroundColor(.label)

                    Text(url?.absoluteString ?? "")
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
    }
}

private struct SiteView: View {
    @Environment(\.onOpenURL) var openURL

    let site: Site
    let title: String
    let tabManager: TabManager
    let action: () -> Void
    let deleteSite: (Site) -> Void

    var body: some View {
        SiteRowButton(title: title, url: site.url) {
            action()
            openURL(site.url)
        }
        .accessibilityLabel(Text(title.isEmpty ? site.url.absoluteString : title))
        .accessibilityIdentifier(site.url.absoluteString)
        .buttonStyle(.tableCell)
        .contextMenu {
            ContextMenuActionsBuilder.OpenInTabAction(
                content: .url(site.url), tabManager: tabManager)

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

private struct SavedTabView: View {
    let savedTab: SavedTab
    let tabManager: TabManager
    let action: () -> Void

    var body: some View {
        SiteRowButton(title: savedTab.title, url: savedTab.url, action: action)
            .accessibilityLabel(Text(savedTab.title ?? ""))
            .accessibilityIdentifier(savedTab.url?.absoluteString ?? "")
            .buttonStyle(.tableCell)
            .contextMenu {
                ContextMenuActionsBuilder.OpenInTabAction(
                    content: .tab(savedTab), tabManager: tabManager)
            }
    }
}

struct SiteRowView: View {
    let tabManager: TabManager

    let data: SiteRowData
    let action: () -> Void

    var body: some View {
        switch data {
        case .site(let site, let deleteSite):
            let title: String = {
                if site.displayTitle.isEmpty {
                    return site.title
                }

                return site.displayTitle
            }()

            SiteView(
                site: site, title: title, tabManager: tabManager, action: action,
                deleteSite: deleteSite)
        case .savedTab(let savedTab):
            SavedTabView(savedTab: savedTab, tabManager: tabManager, action: action)
        }
    }
}
