// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared
import SwiftUI

struct SpotlightSettingsView: View {
    @Default(.createUserActivities) var createUserActivities
    @Default(.makeActivityAvailForSearch) var makeActivityAvailForSearch
    @Default(.addThumbnailToActivities) var addThumbnailToActivities
    @Default(.addSpacesToCS) var addSpacesToCS
    @Default(.addSpaceURLsToCS) var addSpaceURLsToCS
    @Default(.overwriteSpotlightDefaults) var overwriteSpotlightDefaults

    @Default(.numOfIndexedUserActivities) var numOfIndexedUserActivities
    @Default(.numOfWillIndexEvents) var numOfWillIndexEvents
    @Default(.numOfDidIndexEvents) var numOfDidIndexEvents

    @State private var deletingActivities = false

    @State private var deletingSpaces = false
    @State private var deletingSpaceURLs = false
    @State private var deletingAllSpaceIndex = false
    var spaceIndexBusy: Bool {
        deletingSpaces || deletingSpaceURLs || deletingAllSpaceIndex
    }

    var body: some View {
        List {
            Section(header: Text(verbatim: "Browsing User Activity")) {
                Toggle(String("Create User Activities"), isOn: $createUserActivities)
                Toggle(
                    String("Add User Activities to Spotlight"), isOn: $makeActivityAvailForSearch)
                Toggle(String("Add Thumbnails to Attributes"), isOn: $addThumbnailToActivities)
                Button(
                    action: {
                        deletingActivities = true
                        UserActivityHandler.clearIndexedItems {
                            deletingActivities = false
                        }
                    },
                    label: {
                        HStack {
                            Text(verbatim: "Delete all user activities")
                                .foregroundColor(.red)
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .opacity(deletingActivities ? 1 : 0)
                        }
                    })
            }

            Section(header: Text(verbatim: "Spaces")) {
                Toggle(String("Add Spaces to Spotlight"), isOn: $addSpacesToCS)
                Toggle(String("Add URLs in Spaces to Spotlight"), isOn: $addSpaceURLsToCS)
                // Delete Buttons
                Group {
                    Button(
                        action: {
                            deletingSpaces = true
                            SpaceStore.shared.removeAllSpacesFromCoreSpotlight { _ in
                                deletingSpaces = false
                            }
                        },
                        label: {
                            HStack {
                                Text(verbatim: "Remove All Spaces from Index")
                                    .foregroundColor(.red)
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .opacity(deletingSpaces ? 1 : 0)
                            }
                        })

                    Button {
                        deletingSpaceURLs = true
                        SpaceStore.shared.removeAllSpaceURLsFromCoreSpotlight { _ in
                            deletingSpaceURLs = false
                        }
                    } label: {
                        HStack {
                            Text(verbatim: "Remove All Spaces URLs from Index")
                                .foregroundColor(.red)
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .opacity(deletingSpaceURLs ? 1 : 0)
                        }
                    }

                    Button {
                        deletingAllSpaceIndex = true
                        SpaceStore.shared.clearIndex { _ in
                            deletingAllSpaceIndex = false
                        }
                    } label: {
                        HStack {
                            Text(verbatim: "Clear Space Index")
                                .foregroundColor(.red)
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .opacity(deletingAllSpaceIndex ? 1 : 0)
                        }
                    }
                }
                .disabled(spaceIndexBusy)
            }

            Section {
                Toggle(
                    String("Force enable Spotlight integration on next launch"),
                    isOn: $overwriteSpotlightDefaults
                )
            }

            Section {
                NumberField("numOfIndexedUserActivities", number: $numOfIndexedUserActivities)
                NumberField("numOfWillIndexEvents", number: $numOfWillIndexEvents)
                NumberField("numOfDidIndexEvents", number: $numOfDidIndexEvents)
            }

        }
        .font(.system(.footnote, design: .monospaced))
        .minimumScaleFactor(0.75)
        .listStyle(.insetGrouped)
        .applyToggleStyle()
    }
}
