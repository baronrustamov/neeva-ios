// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct LoggingSettingsView: View {
    @Default(.enableAuthLogging) var enableAuthLogging
    @Default(.enableBrowserLogging) var enableBrowserLogging
    @Default(.enableWebKitConsoleLogging) var enableWebKitConsoleLogging
    @Default(.enableNetworkLogging) var enableNetworkLogging
    @Default(.enableStorageLogging) var enableStorageLogging
    @Default(.enableLogToConsole) var enableLogToConsole
    @Default(.enableLogToFile) var enableLogToFile

    var body: some View {
        List {
            Section(header: Text(verbatim: "Categories")) {
                Group {
                    Toggle(String("auth"), isOn: $enableAuthLogging)
                    Toggle(String("browser"), isOn: $enableBrowserLogging)
                    Toggle(String("network"), isOn: $enableNetworkLogging)
                    Toggle(String("storage"), isOn: $enableStorageLogging)
                }.font(.system(.body, design: .monospaced))
            }
            Section(header: Text(verbatim: "Options")) {
                Toggle(
                    String("Include JS console output (browser)"), isOn: $enableWebKitConsoleLogging
                )
                Toggle(String("Log to console"), isOn: $enableLogToConsole)
                Toggle(String("Log to file"), isOn: $enableLogToFile)
            }
            DecorativeSection {
                Button(String("Roll Log Files")) {
                    Logger.rollLogs()
                }
                Button(String("Snapshot Log Files")) {
                    Logger.copyPreviousLogsToDocuments()
                }
            }
            DecorativeSection {
                Button(String("Delete Log Files")) {
                    Logger.deleteLogs()
                }.accentColor(.red)
            }
        }
        .listStyle(.insetGrouped)
        .applyToggleStyle()
    }
}

struct LoggingSettings_Previews: PreviewProvider {
    static var previews: some View {
        LoggingSettingsView()
        LoggingSettingsView().previewDevice("iPhone 8")
    }
}
