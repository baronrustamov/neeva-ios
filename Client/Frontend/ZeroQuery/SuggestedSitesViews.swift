// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import Storage
import SwiftUI

private enum SuggestedSiteUX {
    static let FaviconSize: CGFloat = 28
    static let HomeIconSize: CGFloat = 20
    static let IconSize: CGFloat = 40
    static let PinIconSize: CGFloat = 12
    static let IconCornerRadius: CGFloat = 4
    static let BlockSize: CGFloat = 64
    static let BlockSpacing: CGFloat = 24
}

struct SuggestedNavigationView<Content: View>: View {
    let url: URL
    let isPinnedSite: Bool!
    let title: () -> String
    let icon: () -> Content

    @Environment(\.onOpenURL) private var openURL

    var hint: String {
        let pinned = isPinnedSite ? "Pinned " : ""
        return pinned + "Suggested Site"
    }

    var body: some View {
        Button(action: {
            ClientLogger.shared.logCounter(LogConfig.Interaction.openSuggestedSite)
            openURL(url)
        }) {
            VStack(spacing: 2) {
                icon()
                    .modifier(SuggestedItemBackgroundModifier())
                HStack {
                    if isPinnedSite {
                        Image("pin_small").renderingMode(.template)
                            .foregroundColor(Color.ui.gray60)
                            .frame(
                                width: SuggestedSiteUX.PinIconSize,
                                height: SuggestedSiteUX.PinIconSize, alignment: .center)
                    }
                    Text(title())
                        .withFont(.bodyMedium)
                        .lineLimit(1)
                        .foregroundColorOrGradient(.secondaryLabel)
                        .padding(.top, 4)
                }
                .contentShape(Rectangle())
            }
            .frame(width: SuggestedSiteUX.BlockSize, height: SuggestedSiteUX.BlockSize)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(title())
            .accessibilityHint(hint)
        }
        .onDrag { NSItemProvider(url: url) }
    }
}

private struct SuggestedItemBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if NeevaConstants.currentTarget == .xyz {
            content
                .hexagonClip(with: SuggestedSiteUX.IconSize)
        } else {
            content
                .frame(
                    width: SuggestedSiteUX.IconSize,
                    height: SuggestedSiteUX.IconSize,
                    alignment: .center
                )
                .background(Color(light: .ui.gray97, dark: .systemFill))
                .cornerRadius(SuggestedSiteUX.IconCornerRadius)
        }

    }
}

struct SuggestedHomeView: View {
    var title: String {
        NeevaConstants.currentTarget == .xyz
            ? Defaults[.cryptoPublicKey].isEmpty ? "You" : "Your Wallet" : "Home"
    }
    @State private var shareTargetView: UIView!

    var body: some View {
        SuggestedNavigationView(
            url: NeevaConstants.appHomeURL, isPinnedSite: false,
            title: {
                title
            },
            icon: {
                Symbol(.house, size: SuggestedSiteUX.HomeIconSize, label: title)
                    .accentColor(.ui.adaptive.blue)
            }
        )
        .uiViewRef($shareTargetView)
        .contextMenu {
            ZeroQueryCommonContextMenuActions(
                siteURL: NeevaConstants.appHomeURL,
                title: title,
                description: "Neeva Home",
                showOpenInIncognito: false,
                shareTarget: shareTargetView)
        }
    }
}

struct SuggestedSiteView: View {
    let site: Site!
    let isPinnedSite: Bool!

    @Environment(\.zeroQueryHideTopSite) private var zeroQueryHideTopSite

    @State private var isDeleting = false
    @State private var shareTargetView: UIView!

    var title: String {
        if let provider = site.metadata?.providerName {
            return provider.capitalized
        } else {
            return site.tileURL.shortDisplayString.capitalized
        }
    }

    var body: some View {
        SuggestedNavigationView(
            url: site.url, isPinnedSite: isPinnedSite, title: { title },
            icon: {
                FaviconView(forSite: site)
            }
        )
        .uiViewRef($shareTargetView)
        .actionSheet(isPresented: $isDeleting) {
            ActionSheet(
                title: Text("Permanently remove \(title) from Suggested Sites?"),
                buttons: [
                    .destructive(Text("Remove")) {
                        zeroQueryHideTopSite(site)
                    },
                    .cancel(),
                ])
        }
        .contextMenu {
            ZeroQueryCommonContextMenuActions(
                siteURL: site.url.absoluteURL,
                title: title,
                description: site.metadata?.description,
                shareTarget: shareTargetView)

            if #available(iOS 15.0, *) {
                Button(role: .destructive, action: { isDeleting = true }) {
                    Label("Remove", systemSymbol: .trash)
                }
            } else {
                Button(action: { isDeleting = true }) {
                    Label("Remove", systemSymbol: .trash)
                }
            }

            if FeatureFlag[.pinToTopSites] {
                Text("Pin/unpin not yet implemented")
            }
        }
    }
}

struct SuggestedSitesView: View {
    let isExpanded: Bool
    var withHome: Bool = NeevaConstants.currentTarget == .client
    @ObservedObject var viewModel: SuggestedSitesViewModel
    @Environment(\.zeroQueryWidth) private var zeroQueryWidth
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var columnCount: Int {
        guard verticalSizeClass == .compact || horizontalSizeClass == .regular else {
            return 4
        }

        var columnCount = 0
        var excessSpace = zeroQueryWidth + SuggestedSiteUX.BlockSpacing
        while excessSpace > 0 {
            excessSpace -= SuggestedSiteUX.BlockSize + SuggestedSiteUX.BlockSpacing
            if excessSpace > 0 {
                columnCount += 1
            }
        }
        return columnCount
    }

    var body: some View {
        let columns = Array(
            repeating: GridItem(
                .fixed(SuggestedSiteUX.BlockSize), spacing: SuggestedSiteUX.BlockSpacing),
            count: columnCount)
        if isExpanded {
            LazyVGrid(columns: columns, alignment: .leading, spacing: SuggestedSiteUX.BlockSpacing)
            {
                if withHome {
                    SuggestedHomeView()
                }
                ForEach(viewModel.sites.prefix(withHome ? 7 : 8), id: \.self) { suggestedSite in
                    SuggestedSiteView(
                        site: suggestedSite, isPinnedSite: suggestedSite is PinnedSite
                    )
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, ZeroQueryUX.Padding - 2)
        } else {
            horizontalScrollView
                .frame(height: SuggestedSiteUX.BlockSize + 20)
        }
    }

    @ViewBuilder
    private var horizontalScrollView: some View {
        if NeevaConstants.currentTarget == .xyz {
            ScrollView(.horizontal, showsIndicators: false) {
                horizontalScrollContentView
            }
        } else {
            FadingHorizontalScrollView { _ in
                horizontalScrollContentView
            }
        }
    }

    private var horizontalScrollContentView: some View {
        HStack {
            HStack(spacing: SuggestedSiteUX.BlockSpacing) {
                if withHome {
                    SuggestedHomeView()
                }
                ForEach(viewModel.sites.prefix(withHome ? 7 : 8), id: \.self) { suggestedSite in
                    SuggestedSiteView(
                        site: suggestedSite, isPinnedSite: suggestedSite is PinnedSite
                    )
                }
            }
            .frame(height: SuggestedSiteUX.BlockSize)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, ZeroQueryUX.Padding - 2)
            .fixedSize()

            Spacer()
        }
    }
}
