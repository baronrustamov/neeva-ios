// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import SDWebImageSwiftUI
import Shared
import SwiftUI

struct CollectionStatView: View {
    let statName: String
    let statAmount: String
    let inEth: Bool

    var body: some View {
        VStack(spacing: 2) {
            Text(statName)
                .withFont(.headingSmall)
                .foregroundColor(.secondaryLabel)
            if inEth {
                HStack(spacing: 0) {
                    Image("ethLogo")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.label)
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                    Text("\(statAmount)")
                        .withFont(.labelLarge)
                        .foregroundColor(.label)
                }
            } else {
                Text(statAmount)
                    .withFont(.labelLarge)
                    .foregroundColor(.label)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}

enum CollectionStatsWindow: String, CaseIterable, Identifiable {
    case today = "Today"
    case week = "Week"
    case month = "Month"
    case overall = "All time"

    var id: String { self.rawValue }

    func volume(from stats: CollectionStats) -> String {
        switch self {
        case .today:
            return String(format: "%.1f", stats.oneDayVolume)
        case .week:
            return String(format: "%.1f", stats.weekVolume / 1000) + "K"
        case .month:
            return String(format: "%.1f", stats.monthVolume / 1000) + "K"
        case .overall:
            return String(format: "%.1f", stats.overallVolume / 1000) + "K"
        }
    }

    func averagePrice(from stats: CollectionStats) -> String {
        switch self {
        case .today:
            return String(format: "%.2f", stats.oneDayAveragePrice)
        case .week:
            return String(format: "%.2f", stats.weekAveragePrice)
        case .month:
            return String(format: "%.2f", stats.monthAveragePrice)
        case .overall:
            return String(format: "%.2f", stats.overallAveragePrice)
        }
    }

    func sales(from stats: CollectionStats) -> String {
        switch self {
        case .today:
            return String(format: "%.f", stats.oneDaySales)
        case .week:
            return String(format: "%.1f", stats.weekSales / 1000) + "K"
        case .month:
            return String(format: "%.1f", stats.monthSales / 1000) + "K"
        case .overall:
            return String(format: "%.1f", stats.overallSales / 1000) + "K"
        }
    }
}

struct CollectionWindowStatsMenu: View {
    let stats: CollectionStats
    @Binding var window: CollectionStatsWindow

    var body: some View {
        Menu(
            content: {
                ForEach(CollectionStatsWindow.allCases) { win in
                    Button(
                        action: {
                            window = win
                        },
                        label: {
                            Text(win.rawValue)
                        })
                }
            },
            label: {
                HStack(spacing: 6) {
                    Text(window.rawValue)
                        .withFont(.labelLarge)
                    Symbol(decorative: .chevronDown, style: .labelLarge)
                }
                .gradientForeground()
                .padding(12)
            }
        )
    }
}

public struct CompactStatsView: View {
    let stats: CollectionStats

    public init(stats: CollectionStats) {
        self.stats = stats
    }

    public var body: some View {
        HStack(spacing: 16) {
            CollectionStatView(
                statName: "Items", statAmount: String(stats.count),
                inEth: false)
            CollectionStatView(
                statName: "Owners", statAmount: String(stats.numOwners),
                inEth: false)
            CollectionStatView(
                statName: "Floor Price",
                statAmount: String(format: "%.2f", stats.floorPrice ?? 0),
                inEth: true)
            CollectionStatView(
                statName: "Traded",
                statAmount: String(format: "%.1f", stats.overallVolume / 1000) + "K",
                inEth: true)
        }
    }
}

struct CollectionStatsView: View {
    let stats: CollectionStats
    @State var window = CollectionStatsWindow.overall

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                CollectionStatView(
                    statName: "Items", statAmount: String(stats.count),
                    inEth: false)
                CollectionStatView(
                    statName: "Owners", statAmount: String(stats.numOwners),
                    inEth: false)
                CollectionStatView(
                    statName: "Floor Price",
                    statAmount: String(format: "%.2f", stats.floorPrice ?? 0),
                    inEth: true)
                CollectionStatView(
                    statName: "Traded", statAmount: window.volume(from: stats), inEth: true)
                CollectionStatView(
                    statName: "Average", statAmount: window.averagePrice(from: stats),
                    inEth: true)
            }
            CollectionWindowStatsMenu(stats: stats, window: $window)
        }
    }
}

public struct CollectionView: View {
    @ObservedObject var assetStore: AssetStore = AssetStore.shared
    private let collectionRef: Collection
    private let collectionSlug: String

    private var collection: Collection {
        assetStore.collections.first(where: { $0.openSeaSlug == collectionSlug }) ?? collectionRef
    }

    public init(collection: Collection) {
        self.collectionRef = collection
        self.collectionSlug = collection.openSeaSlug
    }

    public var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                WebImage(
                    url: collection.bannerImageURL,
                    context: [
                        .imageThumbnailPixelSize: CGSize(
                            width: 512,
                            height: 512),
                        .imagePreserveAspectRatio: true,
                    ]
                )
                .placeholder {
                    Color.TrayBackground
                }
                .resizable()
                .scaledToFill()
                .frame(maxHeight: 128)
                .clipped()
                Image("opensea-badge")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 18)
                    .padding(8)
            }
            VStack(spacing: 8) {
                WebImage(url: collection.imageURL)
                    .placeholder {
                        Color.TrayBackground
                    }
                    .resizable()
                    .scaledToFit()
                    .background(Color.background)
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .roundedOuterBorder(cornerRadius: 24, color: .white, lineWidth: 2)
                HStack(spacing: 4) {
                    if collection.safelistRequestStatus >= .approved {
                        Image("twitter-verified-large")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.ui.adaptive.blue)
                            .frame(width: 16, height: 16)
                    }
                    Text(collection.name ?? "")
                        .withFont(.labelLarge)
                        .foregroundColor(
                            collection.safelistRequestStatus >= .approved
                                ? .ui.adaptive.blue : .label)
                }
                if let stats = collection.stats {
                    CollectionStatsView(stats: stats)
                }
            }
            .offset(y: -28)
        }
    }
}
