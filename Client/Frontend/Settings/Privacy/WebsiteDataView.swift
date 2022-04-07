// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI
import WebKit

class WebsiteDataController: ObservableObject {
    @Published private(set) var siteRecords: [WKWebsiteDataRecord]?

    init() {
        reload()
    }
    func reload() {
        let types = WKWebsiteDataStore.allWebsiteDataTypes()
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: types) { records in
            self.siteRecords = records.sorted { $0.displayName < $1.displayName }
        }
    }
}

struct WebsiteDataView: View {
    @StateObject var websiteData = WebsiteDataController()
    @State var showAllData = false
    @State private var isDeleting = false
    @State var filterText: String?

    func onClear() {
        let types = WKWebsiteDataStore.allWebsiteDataTypes()
        WKWebsiteDataStore.default().removeData(
            ofTypes: types,
            modifiedSince: .distantPast,
            completionHandler: websiteData.reload
        )
    }

    var filteredRecords: [WKWebsiteDataRecord]? {
        guard let records = websiteData.siteRecords else { return nil }
        if let filterText = filterText?.lowercased(), !filterText.isEmpty {
            return records.filter { $0.displayName.lowercased().contains(filterText) }
        } else {
            return records
        }
    }

    var body: some View {
        GeometryReader { geom in
            let size = max(
                geom.size.width + geom.safeAreaInsets.leading + geom.safeAreaInsets.trailing,
                geom.size.height + geom.safeAreaInsets.top + geom.safeAreaInsets.bottom)

            List {
                Section(header: Text("Website Data")) {
                    // these constants come from the legacy settings UI.
                    // on screens larger than the iPhone SE (2020) / iPhone 8,
                    // display only 8 items so the “clear all” button remains visible.
                    let numberOfInitialRecords = size > 667 ? 10 : 8
                    if let data = filteredRecords {
                        if data.isEmpty {
                            HStack {
                                Spacer()
                                Text(filterText == nil ? "No Data" : "No Matches")
                                    .foregroundColor(.secondary)
                                    .font(.title3)
                                Spacer()
                            }
                        }
                        let dataToDisplay =
                            showAllData ? data : Array(data.prefix(numberOfInitialRecords))
                        ForEach(dataToDisplay, id: \.displayName) { record in
                            Text(record.displayName)
                        }.onDelete { indexSet in
                            let types = WKWebsiteDataStore.allWebsiteDataTypes()
                            WKWebsiteDataStore.default().removeData(
                                ofTypes: types,
                                for: indexSet.compactMap({ websiteData.siteRecords?[$0] }),
                                completionHandler: websiteData.reload
                            )

                        }

                        if !showAllData && data.count > numberOfInitialRecords {
                            Button("Show More") { showAllData = true }
                        }
                    } else {
                        LoadingView("Loading data…", mini: true)
                    }
                }
                Group {
                    HStack {
                        Spacer(minLength: 0)
                        Button("Clear All Website Data") { isDeleting = true }
                            .actionSheet(isPresented: $isDeleting) {
                                ActionSheet(
                                    title: Text(
                                        "This action will clear all of your private data. It cannot be undone."
                                    ),
                                    buttons: [
                                        .destructive(Text("Clear Data"), action: self.onClear),
                                        .cancel(),
                                    ]
                                )
                            }
                            .accentColor(.red)
                        Spacer(minLength: 0)
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Website Data")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                EditButton()
            }
        }
        .searchBar("Filter Sites…", text: $filterText)
    }
}

struct WebsiteDataView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WebsiteDataView()
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
