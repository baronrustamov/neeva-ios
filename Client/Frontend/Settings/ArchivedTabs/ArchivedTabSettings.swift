// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import SwiftUI

enum ArchivedTabsDuration: CaseIterable, Encodable, Decodable {
    case week
    case month
    case forever
}

extension Defaults.Keys {
    static let archivedTabsDuration = Defaults.Key<ArchivedTabsDuration>(
        "profile_prefkey_archivedTabs_archivedTabsDuration", default: .week)
}

struct ArchivedTabSettings: View {
    @Default(.archivedTabsDuration) var archivedTabsDuration

    var body: some View {
        List {
            Section {
                Picker("", selection: $archivedTabsDuration) {
                    Text("7 Days").tag(ArchivedTabsDuration.week)
                    Text("30 Days").tag(ArchivedTabsDuration.month)
                    Text("Never").tag(ArchivedTabsDuration.forever)
                }.labelsHidden()
            }
        }
        .listStyle(.insetGrouped)
        .pickerStyle(.inline)
        .applyToggleStyle()
        .navigationTitle(Text("Archive Tabs"))
    }
}

struct ArchivedTabSettings_Previews: PreviewProvider {
    static var previews: some View {
        ArchivedTabSettings()
    }
}
