// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import MapKit
import SDWebImageSwiftUI
import Shared
import SwiftUI

enum PlaceViewUX {
    enum Ratings {
        static let spacing: CGFloat = 2
        static let size: CGFloat = 12
    }

    enum QuickActionButton {
        static let cornerRadius: CGFloat = 10
        static let padding: CGFloat = 7
        static let pressedHighlightOpacity: CGFloat = 0.2
        static let height: CGFloat = 60
    }

    static let sectionSpacing: CGFloat = 12
    static let textSpacing: CGFloat = 5

    static let mapCornerRadius: CGFloat = 10
    static let mapOverlayOpacity: CGFloat = 0.5
    static let mapHeight: CGFloat = 200
    static let mapPinSize: CGFloat = 25

    static let imageSize: CGFloat = 80
    static let imageCornerRadius: CGFloat = 10

    static let listIconSize: CGFloat = 15
    static let listImageSize: CGFloat = 50
    static let listImageCornerRadius: CGFloat = 10
}

private struct MapOverlayView: View {
    var body: some View {
        ZStack(alignment: .center) {
            Color.black
            Text("Tap to pan and zoom")
                .withFont(.headingLarge)
                .foregroundColor(.white)
        }
    }
}

private struct RatingsView: View {
    private struct StarView: View {
        let fill: Double

        var body: some View {
            switch fill {
            case 0:
                Image(systemSymbol: .star)
                    .renderingMode(.template)
            case 0..<1:
                Image(systemSymbol: .starLeadinghalfFill)
                    .renderingMode(.template)
            case 1...:
                Image(systemSymbol: .starFill)
                    .renderingMode(.template)
            default:
                EmptyView()
            }
        }
    }

    let rating: Double

    var body: some View {
        HStack(alignment: .center, spacing: PlaceViewUX.Ratings.spacing) {
            StarView(fill: max(min(1, rating), 0))
            StarView(fill: max(min(1, rating - 1), 0))
            StarView(fill: max(min(1, rating - 2), 0))
            StarView(fill: max(min(1, rating - 3), 0))
            StarView(fill: max(min(1, rating - 4), 0))
        }
        .foregroundColor(Color.brand.orange)
        .font(.system(size: PlaceViewUX.Ratings.size))
    }
}

private struct QuickActionButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat = PlaceViewUX.QuickActionButton.cornerRadius
    let padding: CGFloat = PlaceViewUX.QuickActionButton.padding

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
            configuration.label
                .foregroundColor(.brand.blue)
                .padding(padding)
                .frame(height: PlaceViewUX.QuickActionButton.height)
            Spacer()
        }
        .background(
            Color.secondaryBackground
                .cornerRadius(cornerRadius)
        )
        .overlay(
            Color.white
                .cornerRadius(cornerRadius)
                .opacity(
                    configuration.isPressed
                        ? PlaceViewUX.QuickActionButton.pressedHighlightOpacity : 0
                )
        )

    }
}

struct PlaceView: View {
    @Environment(\.onOpenURLForCheatsheet) var onOpenURLForCheatsheet

    @StateObject private var viewModel: PlaceViewModel

    @State private var enableMapInteraction: Bool = false
    @State private var hourExpanded: Bool = false
    @State private var addressExpanded: Bool = false

    var place: Place {
        viewModel.place
    }
    var categories: String? {
        let joined = place.categories.joined(separator: ", ")
        return !joined.isEmpty ? joined : nil
    }
    var subTitles: [Text] {
        var texts: [Text] = []
        if let categories = categories {
            texts.append(
                Text(categories)
                    .foregroundColor(.secondaryLabel)
            )
        }
        if let operatingStatus = place.articulatedOperatingStatus {
            if categories != nil {
                texts.append(
                    Text(" · ")
                )
            }
            texts.append(
                Text(operatingStatus)
                    .foregroundColor(place.isOpenNow ? .brand.green : .brand.red)
            )
            if let hour = place.articulatedHour {
                texts += [
                    Text(" "),
                    Text(hour)
                        .foregroundColor(.secondaryLabel),
                ]
            }
        }
        return texts
    }

    init(viewModel: PlaceViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PlaceViewUX.sectionSpacing) {
            GeometryReader { geometry in
                ZStack {
                    Map(
                        coordinateRegion: $viewModel.mapRegion,
                        interactionModes: enableMapInteraction ? .all : [],
                        showsUserLocation: true,
                        userTrackingMode: nil,
                        annotationItems: viewModel.annotatedMapItems
                    ) { place in
                        MapMarker(
                            coordinate: CLLocationCoordinate2D(
                                latitude: place.lat, longitude: place.lon),
                            tint: Color.brand.variant.red
                        )
                    }

                    MapOverlayView()
                        .opacity(enableMapInteraction ? 0 : PlaceViewUX.mapOverlayOpacity)
                        .onTapGesture {
                            enableMapInteraction.toggle()
                        }
                }
                .frame(width: geometry.size.width)
            }
            .frame(height: PlaceViewUX.mapHeight)
            .cornerRadius(PlaceViewUX.mapCornerRadius)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: PlaceViewUX.textSpacing) {
                    Text(place.name)
                        .withFont(.headingXLarge)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(.label)

                    subTitle
                        .withFont(unkerned: .bodyMedium)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    ratings
                }

                Spacer()

                if let imageURL = place.imageURL {
                    WebImage(url: imageURL)
                        .resizable()
                        .scaledToFill()
                        .frame(width: PlaceViewUX.imageSize, height: PlaceViewUX.imageSize)
                        .clipped()
                        .cornerRadius(PlaceViewUX.imageCornerRadius)
                }
            }

            quickActions

            detailsSection
        }
    }

    @ViewBuilder
    var subTitle: some View {
        let texts = subTitles
        if texts.isEmpty {
            EmptyView()
        } else {
            texts.reduce(Text(""), +)
        }
    }

    @ViewBuilder
    var ratings: some View {
        HStack(alignment: .center) {
            // rating is out of 5
            if let rating = place.rating {
                RatingsView(rating: rating)
            }

            if let reviews = place.reviewCount {
                Text("\(reviews) Reviews")
                    .withFont(.bodySmall)
                    .foregroundColor(.secondaryLabel)
            }

            if let price = place.price {
                Text(price)
                    .withFont(.bodySmall)
                    .foregroundColor(.secondaryLabel)
            }
        }
    }

    @ViewBuilder
    var quickActions: some View {
        HStack(spacing: PlaceViewUX.textSpacing) {
            if let url = viewModel.telephoneURL,
                UIApplication.shared.canOpenURL(url)
            {
                Button(
                    action: {
                        UIApplication.shared.open(url)
                    },
                    label: {
                        VStack {
                            Image(systemSymbol: .phoneFill)
                                .resizable()
                                .scaledToFit()
                            Text("Call")
                                .withFont(.bodyMedium)
                        }
                    }
                )
                .buttonStyle(QuickActionButtonStyle())
            }

            if let website = place.websiteURL {
                Button(
                    action: {
                        onOpenURLForCheatsheet(website, String(describing: Self.self))
                    },
                    label: {
                        VStack {
                            Image(systemSymbol: .globe)
                                .resizable()
                                .scaledToFit()
                            Text("Website")
                                .withFont(.bodyMedium)
                        }
                    }
                )
                .buttonStyle(QuickActionButtonStyle())
            }

            if let yelpLink = place.yelpURL {
                Button(
                    action: {
                        onOpenURLForCheatsheet(yelpLink, String(describing: Self.self))
                    },
                    label: {
                        VStack {
                            Image("yelp-icon")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                            Text("Yelp")
                                .withFont(.bodyMedium)
                        }
                    }
                )
                .buttonStyle(QuickActionButtonStyle())
            }

            Button(
                action: {
                    let mapItem = MKMapItem(placemark: MKPlacemark(placemark: viewModel.placeMark))
                    mapItem.name = place.name
                    mapItem.openInMaps()
                },
                label: {
                    VStack {
                        Image(systemSymbol: .arrowTriangleTurnUpRightDiamondFill)
                            .resizable()
                            .scaledToFit()
                        Text("Directions")
                            .withFont(.bodyMedium)
                            .lineLimit(1)
                    }
                }
            )
            .buttonStyle(QuickActionButtonStyle())
        }
    }

    @ViewBuilder
    var detailsSection: some View {
        VStack(alignment: .leading, spacing: PlaceViewUX.textSpacing) {
            // Operating Hour
            if let hours = viewModel.sortedLocalizedHours,
                let nextOpen = viewModel.nextOpen
            {
                VStack(alignment: .leading, spacing: PlaceViewUX.textSpacing) {
                    HStack(alignment: .center) {
                        Text("Hours")
                            .withFont(.headingMedium)
                            .foregroundColor(.label)
                        if let operatingStatus = place.articulatedOperatingStatus {
                            Text(operatingStatus)
                                .withFont(.headingMedium, weight: .semibold)
                                .foregroundColor(place.isOpenNow ? .brand.green : .brand.red)
                            if let hour = place.articulatedHour {
                                Text(" \(hour)")
                                    .withFont(.bodyMedium)
                                    .foregroundColor(.secondaryLabel)
                            }
                        }
                        Spacer()
                        Button(
                            action: {
                                hourExpanded.toggle()
                            },
                            label: {
                                if hourExpanded {
                                    Image(systemSymbol: .chevronUp)
                                        .foregroundColor(.label)
                                } else {
                                    Image(systemSymbol: .chevronDown)
                                        .foregroundColor(.label)
                                }
                            }
                        )
                        .padding(.horizontal)
                    }

                    Group {
                        if !hourExpanded {
                            HStack {
                                if case let .open(start, end) = nextOpen.articulatedHours {
                                    if nextOpen.gregorianWeekday != viewModel.currentDayOfTheWeek {
                                        Text(nextOpen.weekday)
                                            .withFont(.bodyMedium)
                                            .foregroundColor(.label)
                                    }
                                    Text("\(start) - \(end)")
                                        .withFont(.bodyMedium)
                                        .foregroundColor(.label)
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: PlaceViewUX.textSpacing) {
                                ForEach(hours, id: \.gregorianWeekday) { hour in
                                    HStack {
                                        Text(hour.weekday)
                                            .withFont(.bodyMedium)
                                        Spacer()
                                        switch hour.articulatedHours {
                                        case .open(let start, let end):
                                            Text("\(start) - \(end)")
                                                .withFont(.bodyMedium)
                                        case .closed:
                                            Text("Closed")
                                                .withFont(.bodyMedium)
                                        }
                                    }
                                    .foregroundColor(.label)
                                }
                            }
                        }
                    }
                }

                Divider()
            }

            // Address Section
            VStack(alignment: .leading, spacing: PlaceViewUX.textSpacing) {
                HStack(alignment: .center) {
                    Text("Address")
                        .withFont(.headingMedium)
                        .foregroundColor(.label)
                    Spacer()
                    Button(
                        action: {
                            addressExpanded.toggle()
                        },
                        label: {
                            if addressExpanded {
                                Image(systemSymbol: .chevronUp)
                                    .foregroundColor(.label)
                            } else {
                                Image(systemSymbol: .chevronDown)
                                    .foregroundColor(.label)
                            }
                        }
                    )
                    .padding(.horizontal)
                }
                addressTextView
            }

            // Phone number
            if let phone = place.telephonePretty ?? place.telephone {
                Divider()
                VStack(alignment: .leading, spacing: PlaceViewUX.textSpacing) {
                    Text("Phone")
                        .withFont(.headingMedium)
                        .foregroundColor(.label)
                    Button(
                        action: {
                            if let url = viewModel.telephoneURL,
                                UIApplication.shared.canOpenURL(url)
                            {
                                UIApplication.shared.open(url)
                            }
                        },
                        label: {
                            HStack {
                                Text(phone)
                                    .withFont(.bodyMedium)
                                Spacer()
                            }
                        })
                }
            }
        }
        .padding(PlaceViewUX.sectionSpacing)
        .background(
            Color.secondaryBackground
                .cornerRadius(PlaceViewUX.QuickActionButton.cornerRadius)
        )
    }

    @ViewBuilder
    private var addressTextView: some View {
        if !addressExpanded {
            if #available(iOS 15, *) {
                Text(place.address.street)
                    .withFont(.bodyMedium)
                    .textSelection(.enabled)
            } else {
                Text(place.address.street)
                    .withFont(.bodyMedium)
                    .contextMenu {
                        Button(
                            action: {
                                UIPasteboard.general.string = place.address.street
                            },
                            label: {
                                Text("Copy to clipboard")
                                Image(systemName: "doc.on.doc")
                            })
                    }
            }
        } else {
            let text = place.address.full.replacingOccurrences(of: ", ", with: ",\n")
            if #available(iOS 15, *) {
                Text(text)
                    .withFont(.bodyMedium)
                    .textSelection(.enabled)
            } else {
                Text(text)
                    .withFont(.bodyMedium)
                    .contextMenu {
                        Button(
                            action: {
                                UIPasteboard.general.string = text
                            },
                            label: {
                                Text("Copy to clipboard")
                                Image(systemName: "doc.on.doc")
                            })
                    }
            }

        }
    }
}

struct PlaceListView: View {
    @Environment(\.onOpenURLForCheatsheet) var onOpenURLForCheatsheet

    @StateObject private var viewModel: PlaceListViewModel

    @State private var enableMapInteraction: Bool = false

    var placeList: [Place] { viewModel.placelist }

    init(viewModel: PlaceListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PlaceViewUX.sectionSpacing) {
            GeometryReader { geometry in
                ZStack {
                    Map(
                        mapRect: $viewModel.mapRect,
                        interactionModes: enableMapInteraction ? .all : [],
                        showsUserLocation: true,
                        userTrackingMode: nil,
                        annotationItems: viewModel.annotatedMapItems
                    ) { place in
                        MapAnnotation(
                            coordinate: CLLocationCoordinate2D(
                                latitude: place.lat, longitude: place.lon)
                        ) {
                            Image(systemName: "\(viewModel.placeIndex[place.id]!+1).circle.fill")
                                .foregroundColor(.brand.red)
                                .scaledToFit()
                                .frame(
                                    width: PlaceViewUX.mapPinSize, height: PlaceViewUX.mapPinSize
                                )
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                )
                        }
                    }

                    MapOverlayView()
                        .opacity(enableMapInteraction ? 0 : PlaceViewUX.mapOverlayOpacity)
                        .onTapGesture {
                            enableMapInteraction.toggle()
                        }
                }
                .frame(width: geometry.size.width)
            }
            .frame(height: PlaceViewUX.mapHeight)
            .cornerRadius(PlaceViewUX.mapCornerRadius)

            VStack(alignment: .center, spacing: PlaceViewUX.textSpacing) {
                ForEach(Array(placeList.enumerated()), id: \.element.address.full) { idx, place in
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .top) {
                            Image(systemName: "\(idx+1).circle.fill")
                                .foregroundColor(.brand.red)
                                .scaledToFit()
                                .frame(
                                    width: PlaceViewUX.listIconSize,
                                    height: PlaceViewUX.listIconSize
                                )
                                .padding(PlaceViewUX.textSpacing)

                            HeaderView(place: place)

                            Spacer()

                            if let imageURL = place.imageURL {
                                WebImage(url: imageURL)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(
                                        width: PlaceViewUX.listImageSize,
                                        height: PlaceViewUX.listImageSize
                                    )
                                    .clipped()
                                    .cornerRadius(PlaceViewUX.listImageCornerRadius)
                            }
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard let query = place.mapQuery,
                            var components = URLComponents(
                                url: NeevaConstants.appSearchURL, resolvingAgainstBaseURL: false)
                        else {
                            return
                        }
                        components.queryItems = [
                            URLQueryItem(name: "q", value: query.query),
                            URLQueryItem(name: "c", value: "Maps"),
                            URLQueryItem(name: "src", value: "InternalSearchLink"),
                        ]
                        components.fragment = "maps-id-\(query.placeID)"
                        guard let url = components.url else {
                            return
                        }
                        onOpenURLForCheatsheet(url, String(describing: Self.self))
                    }

                    if idx != placeList.endIndex.advanced(by: -1) {
                        Divider()
                    }
                }
            }
            .padding()
            .background(
                Color.groupedBackground
                    .cornerRadius(PlaceViewUX.QuickActionButton.cornerRadius)
            )
        }
    }

    private struct HeaderView: View {
        let place: Place

        var body: some View {
            VStack(alignment: .leading) {
                // Name
                Text(place.name)
                    .withFont(.headingMedium)
                    .foregroundColor(.label)
                    .lineLimit(1)

                // Ratings
                HStack(alignment: .center) {
                    // rating is out of 5
                    if let rating = place.rating {
                        RatingsView(rating: rating)
                    }

                    if let reviews = place.reviewCount {
                        Text("\(reviews) Reviews")
                            .withFont(.bodySmall)
                            .foregroundColor(.secondaryLabel)
                    }

                    if let price = place.price {
                        Text(price)
                            .withFont(.bodySmall)
                            .foregroundColor(.secondaryLabel)
                    }
                }

                // Categories
                if let categories = place.categories.joined(separator: ", "),
                    !categories.isEmpty
                {
                    Text(categories)
                        .withFont(.bodySmall)
                        .foregroundColor(.secondaryLabel)
                        .lineLimit(1)
                }

                // Operating Status
                if let operatingStatus = place.articulatedOperatingStatus {
                    HStack {
                        Text(operatingStatus)
                            .withFont(.bodySmall, weight: .semibold)
                            .foregroundColor(place.isOpenNow ? .brand.green : .brand.red)
                        if let hour = place.articulatedHour {
                            Text(" \(hour)")
                                .withFont(.bodySmall)
                                .foregroundColor(.secondaryLabel)
                        }
                    }
                }
            }
        }
    }
}

struct PlaceView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
