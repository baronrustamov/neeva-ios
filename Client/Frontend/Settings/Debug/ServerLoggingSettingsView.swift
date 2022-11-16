// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import SwiftUI

struct ServerLoggingSettingsView: View {
    let debugLoggerHistory = ClientLogger.shared.debugLoggerHistory

    var body: some View {
        LogListView(debugLoggerHistory: debugLoggerHistory)
    }
}

private struct LogListView: View {
    let debugLoggerHistory: [DebugLog]

    @State private var item = DebugLog(pathString: "", attributes: [])
    @State private var showingTable = false

    @Default(.enableDebugGraphQLLogger) var enableDebugGraphQLLogger

    var body: some View {
        List {
            Toggle(String("enableDebugGraphQLLogger"), isOn: $enableDebugGraphQLLogger)
            Section(header: Text("Events")) {
                ForEach(0..<debugLoggerHistory.count, id: \.self) { i in
                    VStack(alignment: .leading) {
                        NavigationLink(debugLoggerHistory[i].path) {
                            LogView(log: debugLoggerHistory[i])
                                .navigationTitle(debugLoggerHistory[i].path)
                        }
                    }
                }
            }
        }
    }
}

private struct LogView: View {
    let log: DebugLog

    var body: some View {
        VStack(alignment: .leading) {
            if #available(iOS 16, *) {
                TableLogBodyView(log: log)
            } else {
                LegacyLogBodyView(log: log)
            }
        }
    }
}

@available(iOS 16, *)
private struct TableLogBodyView: View {
    let log: DebugLog

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        Table(log.attributes) {
            TableColumn("Key") { attribute in
                if horizontalSizeClass == .compact {
                    LegacyLogRowView(attribute: attribute)
                } else {
                    Text(attribute.key)
                }
            }
            TableColumn("Value") { attribute in
                Text(attribute.value ?? "")
            }
        }
    }
}

private struct LegacyLogBodyView: View {
    let log: DebugLog

    var body: some View {
        List {
            ForEach(log.attributes, id: \.id) { attribute in
                LegacyLogRowView(attribute: attribute)
            }
        }
    }
}

private struct LegacyLogRowView: View {
    let attribute: DebugLog.Attribute

    var body: some View {
        HStack {
            Text(attribute.key)
            Spacer()
            Text(attribute.value ?? "")
                .foregroundColor(.secondaryLabel)
        }
    }
}
