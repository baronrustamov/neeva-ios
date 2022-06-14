// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SFSafeSymbols
import Shared
import Storage
import SwiftUI

private enum TrackingMenuUX {
    static let whosTrackingYouElementSpacing: CGFloat = 8
    static let whosTrackingYouRowSpacing: CGFloat = 60
    static let whosTrackingYouElementFaviconSize: CGFloat = 25
}

struct TrackingMenuFirstRowElement: View {
    let label: LocalizedStringKey
    let num: Int

    var body: some View {
        GroupedCell(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(label).withFont(.headingMedium).foregroundColor(.secondaryLabel)
                Text("\(num)").withFont(.displayMedium)
            }
            .padding(.bottom, 4)
            .padding(.vertical, 10)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("\(num) \(Text(label)) blocked"))
            .accessibilityIdentifier("TrackingMenu.TrackingMenuFirstRowElement")
        }
    }
}

struct WhosTrackingYouElement: View {
    let whosTrackingYouDomain: WhosTrackingYouDomain

    var body: some View {
        HStack(spacing: TrackingMenuUX.whosTrackingYouElementSpacing) {
            Image(whosTrackingYouDomain.domain.rawValue).resizable().cornerRadius(5)
                .frame(
                    width: TrackingMenuUX.whosTrackingYouElementFaviconSize,
                    height: TrackingMenuUX.whosTrackingYouElementFaviconSize)
            Text("\(whosTrackingYouDomain.count)").withFont(.displayMedium)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(whosTrackingYouDomain.count) trackers blocked from \(whosTrackingYouDomain.domain.rawValue)"
        )
        .accessibilityIdentifier("TrackingMenu.WhosTrackingYouElement")
    }
}

struct WhosTrackingYouView: View {
    let whosTrackingYouDomains: [WhosTrackingYouDomain]

    var body: some View {
        GroupedCell(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("Who's Tracking You").withFont(.headingMedium).foregroundColor(.secondaryLabel)
                HStack(spacing: TrackingMenuUX.whosTrackingYouRowSpacing) {
                    ForEach(whosTrackingYouDomains, id: \.domain.rawValue) {
                        whosTrackingYouDomain in
                        WhosTrackingYouElement(whosTrackingYouDomain: whosTrackingYouDomain)
                    }
                }.padding(.bottom, 4)
            }.padding(.vertical, 14)
        }
    }
}

struct TrackingMenuView: View {
    @EnvironmentObject var viewModel: TrackingStatsViewModel
    @EnvironmentObject var cookieCutterModel: CookieCutterModel

    @State private var isShowingPopup = false

    var body: some View {
        GroupedStack {
            if viewModel.preventTrackersForCurrentPage {
                HStack(spacing: 8) {
                    TrackingMenuFirstRowElement(label: "Trackers", num: viewModel.numTrackers)

                    TrackingMenuFirstRowElement(
                        label: "Cookie Popups", num: cookieCutterModel.cookiesBlocked)
                }

                if !viewModel.whosTrackingYouDomains.isEmpty {
                    WhosTrackingYouView(whosTrackingYouDomains: viewModel.whosTrackingYouDomains)
                }
            }

            TrackingMenuProtectionRowButton(
                preventTrackers: $viewModel.preventTrackersForCurrentPage)
        }
    }
}
