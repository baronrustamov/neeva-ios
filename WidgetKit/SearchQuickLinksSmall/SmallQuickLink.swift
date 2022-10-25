/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import SwiftUI
import WidgetKit

struct IntentProvider: TimelineProvider {
    func getSnapshot(in context: Context, completion: @escaping (QuickLinkEntry) -> Void) {
        let entry = QuickLinkEntry(date: Date(), link: .search)
        completion(entry)
    }

    func getTimeline(
        in context: Context, completion: @escaping (Timeline<QuickLinkEntry>) -> Void
    ) {
        let link = QuickLink.search
        let entries = [QuickLinkEntry(date: Date(), link: link)]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    func placeholder(in context: Context) -> QuickLinkEntry {
        return QuickLinkEntry(date: Date(), link: .search)
    }
}

struct QuickLinkEntry: TimelineEntry {
    let date: Date
    let link: QuickLink
}

struct SmallQuickLinkView: View {
    var entry: IntentProvider.Entry

    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                ImageButtonWithLabel(isSmall: true, link: entry.link)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: entry.link.backgroundColors),
                            startPoint: .bottomLeading, endPoint: .topTrailing
                        )
                    )
            case .accessoryCircular:
                circularLockScreenView
            case .accessoryRectangular:
                rectangularLockScreenView
            default:
                EmptyView()
            }
        }
        .widgetURL(entry.link.url)
    }

    @ViewBuilder
    var circularLockScreenView: some View {
        ZStack {
            if #available(iOS 16, *) {
                AccessoryWidgetBackground()
            }

            Image("neeva-circular")
                .resizable()
                .scaledToFit()
        }
    }

    @ViewBuilder
    var rectangularLockScreenView: some View {
        ZStack {
            if #available(iOS 16, *) {
                AccessoryWidgetBackground()
                    .clipShape(Capsule())
            }

            Image("neeva-rect")
                .resizable()
                .scaledToFit()
        }
    }
}

struct SmallQuickLinkWidget: Widget {
    private let kind: String = "Quick Actions - Small"

    static var supportedFamilies: [WidgetFamily] {
        var families: [WidgetFamily] = []

        #if os(iOS)
            // Families specific to iOS
            families += [.systemSmall]
            if #available(iOS 16, *) {
                // Support lockscreen widgets
                families += [.accessoryCircular, .accessoryRectangular]
            }
        #endif

        return families
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: IntentProvider()) { entry in
            SmallQuickLinkView(entry: entry)
        }
        .configurationDisplayName(String.QuickActionsGalleryTitle)
        .description(String.SearchInNeevaTitle)
        .supportedFamilies(Self.supportedFamilies)
    }
}

struct SmallQuickActionsPreviews: PreviewProvider {
    static let testEntry = QuickLinkEntry(date: Date(), link: .search)
    static var previews: some View {
        Group {
            SmallQuickLinkView(entry: testEntry)
                .environment(\.colorScheme, .dark)
        }
    }
}
