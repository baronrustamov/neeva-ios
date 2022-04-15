// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation
import MapKit
import Shared
import SwiftUI

struct PlaceAnnotation: Identifiable {
    typealias ID = String

    let lat: CLLocationDegrees
    let lon: CLLocationDegrees
    let address: String

    var id: String {
        address
    }

    init(from place: Place) {
        self.lat = place.position.lat
        self.lon = place.position.lon
        self.address = place.address.full
    }
}

struct LocalizedOperatingHour {
    enum Hours {
        case open(String, String)
        case closed
    }
    let articulatedHours: Hours
    let weekday: String
    let gregorianWeekday: Int
}

class PlaceViewModel: ObservableObject {
    @Published var mapRegion: MKCoordinateRegion

    static let geocoder = CLGeocoder()
    static let inputTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        // 24h clock
        formatter.dateFormat = "HHmm"
        return formatter
    }()
    static let timeLocalizedFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    let place: Place

    // Core Location Objects for Displaying and Opening Maps
    private var resolvedPlaceMark: CLPlacemark?
    var placeMark: CLPlacemark {
        resolvedPlaceMark
            ?? CLPlacemark(
                location: CLLocation(latitude: place.position.lat, longitude: place.position.lon),
                name: place.name,
                postalAddress: nil
            )
    }
    let annotatedMapItems: [PlaceAnnotation]

    // Constants
    let mapSpanMeters: CLLocationDistance = 500

    // Gregorian Day of the Week (Sunday is 1, Saturday is 7)
    var currentDayOfTheWeek: Int {
        return Calendar(identifier: .gregorian).dateComponents([.weekday], from: Date()).weekday!
    }
    var sortedLocalizedHours: [LocalizedOperatingHour]?
    var nextOpen: LocalizedOperatingHour? {
        guard let hours = sortedLocalizedHours,
            let startIdx = hours.firstIndex(where: { $0.gregorianWeekday == currentDayOfTheWeek })
        else {
            return nil
        }
        for offset in 0...6 {
            let idx = (startIdx + offset) % hours.count
            if case .open = hours[idx].articulatedHours {
                return hours[idx]
            }
        }
        return nil
    }

    var telephoneURL: URL? {
        guard let telephone = place.telephone ?? place.telephonePretty?.remove(" ")
        else {
            return nil
        }
        return URL(string: "tel://\(telephone)")
    }

    init(_ place: Place) {
        print("init")
        self.place = place

        mapRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: place.position.lat, longitude: place.position.lon),
            latitudinalMeters: mapSpanMeters,
            longitudinalMeters: mapSpanMeters
        )
        annotatedMapItems = [PlaceAnnotation(from: place)]

        Self.geocoder.geocodeAddressString(place.address.full) { [self] placemarks, error in
            if let placemark = placemarks?.first {
                self.resolvedPlaceMark = CLPlacemark(
                    location: CLLocation(
                        latitude: place.position.lat, longitude: place.position.lon),
                    name: place.name,
                    postalAddress: placemark.postalAddress
                )
            }
        }

        if let hours = place.hours {
            self.sortedLocalizedHours = Self.sortAndFormatOperatingHour(from: hours)
        }
    }

    class func sortAndFormatOperatingHour(from hours: [Place.Hour]) -> [LocalizedOperatingHour] {
        // fill in days that are missing because they are closed
        return stride(from: 0, through: 6, by: 1).map { yelpDay -> (LocalizedOperatingHour, Int) in
            // put the days from API response into gregorian calendar
            // yelp uses 0 through 6 for monday through sunday
            // Calendar.gregorian uses 1 through 7 for sunday through saturday
            let gregorianWeekday = (yelpDay + 1) % 7 + 1

            // find weekday in current local
            var calendar = Calendar.autoupdatingCurrent
            calendar.locale = Locale.autoupdatingCurrent
            let weekday = (gregorianWeekday + 7 - calendar.firstWeekday) % 7 + 1

            var articulatedHours: LocalizedOperatingHour.Hours = .closed
            if let hour = hours.first(where: { $0.day == yelpDay }) {
                // Parse time of day
                let start = Self.inputTimeFormatter.date(from: hour.start)!
                let end = Self.inputTimeFormatter.date(from: hour.end)!

                articulatedHours = .open(
                    Self.timeLocalizedFormatter.string(from: start),
                    Self.timeLocalizedFormatter.string(from: end)
                )
            }

            let operatingHour = LocalizedOperatingHour(
                articulatedHours: articulatedHours,
                // in English in Gregrorian, the symols are ["Sun", "Mon", ...]
                // this array seems to always be in Gregorian, despite the locale
                weekday: calendar.shortWeekdaySymbols[gregorianWeekday - 1],
                gregorianWeekday: gregorianWeekday
            )

            return (operatingHour, weekday)
        }.sorted {
            $0.1 < $1.1
        }.map {
            $0.0
        }
    }
}

class PlaceListViewModel: ObservableObject {
    @Published var mapRect: MKMapRect

    static let geocoder = CLGeocoder()

    let placelist: [Place]

    let annotatedMapItems: [PlaceAnnotation]
    let placeIndex: [PlaceAnnotation.ID: Int]
    let telephoneURLs: [URL?]

    init(_ placelist: [Place]) {
        self.placelist = placelist

        annotatedMapItems = placelist.map {
            PlaceAnnotation(from: $0)
        }
        placeIndex = annotatedMapItems.enumerated()
            .reduce(into: [PlaceAnnotation.ID: Int]()) { partialResult, item in
                partialResult[item.element.id] = item.offset
            }
        telephoneURLs = placelist.map {
            guard let telephone = $0.telephone ?? $0.telephonePretty?.remove(" ")
            else {
                return nil
            }
            return URL(string: "tel://\(telephone)")
        }

        let unionRect = placelist.map { place -> MKMapPoint in
            MKMapPoint(
                CLLocationCoordinate2D(latitude: place.position.lat, longitude: place.position.lon))
        }.map {
            MKMapRect(origin: $0, size: MKMapSize(width: 0.0001, height: 0.0001))
        }
        .reduce(MKMapRect.null) { prev, next in
            prev.union(next)
        }
        let newSize = MKMapSize(
            width: unionRect.width * 3,
            height: unionRect.height * 3
        )
        mapRect = MKMapRect(
            x: unionRect.midX - newSize.width / 2,
            y: unionRect.midY - newSize.height / 2,
            width: newSize.width,
            height: newSize.height
        )
    }
}
