// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import SwiftUI

extension Defaults.Keys {
    static let archivedTabsDuration = Defaults.Key<TimeSection>(
        "profile.prefkey.archivedTabs.archivedTabsDuration", default: .lastWeek)
}

struct ArchivedTabSettings: View {
    @Default(.archivedTabsDuration) var archivedTabsDuration

    var body: some View {
        List {
            Section {
                Picker("", selection: $archivedTabsDuration) {
                    Text("7 Days").tag(TimeSection.lastWeek)
                    Text("30 Days").tag(TimeSection.lastMonth)
                    Text("Forever").tag(TimeSection.overAMonth)
                }.labelsHidden()
            }
        }
        .listStyle(.insetGrouped)
        .pickerStyle(.inline)
        .applyToggleStyle()
        .navigationTitle(Text("Keep Tabs"))
    }
}

struct ArchivedTabSettings_Previews: PreviewProvider {
    static var previews: some View {
        ArchivedTabSettings()
    }
}
