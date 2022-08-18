// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct ServerLoggingSettingsView: View {
    @State private var showingAlert = false
    @State private var item = DebugLog(pathStr: "", attributeStr: "")

    let debugLoggerHistory = ClientLogger.shared.debugLoggerHistory

    var body: some View {
        List {
            if #available(iOS 15.0, *) {
                ForEach(0..<debugLoggerHistory.count, id: \.self) { i in
                    VStack(alignment: .leading) {
                        Button(debugLoggerHistory[i].pathStr) {
                            self.item = debugLoggerHistory[i]
                            showingAlert = true
                        }

                    }
                }
                .alert(
                    "\(item.attributeStr)", isPresented: $showingAlert
                ) {
                    Button("OK", role: .cancel) {}
                }
            } else {
                ForEach(0..<debugLoggerHistory.count, id: \.self) { i in
                    Text(debugLoggerHistory[i].pathStr)
                }
            }
        }
    }
}
