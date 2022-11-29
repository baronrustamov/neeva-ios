// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import SwiftUI

enum ArchivedTabsDuration: CaseIterable, Encodable, Decodable {
    case week
    case month
    case forever

    var label: LocalizedStringKey {
        switch self {
        case .week:
            return "After 7 days"
        case .month:
            return "After 30 days"
        case .forever:
            return "Never"
        }
    }
}

extension Defaults.Keys {
    static let archivedTabsDuration = Defaults.Key<ArchivedTabsDuration>(
        "profile_prefkey_archivedTabs_archivedTabsDuration", default: .week)
}

struct ArchivedTabSettings: View {
    @Default(.archivedTabsDuration) var archivedTabsDuration
    @Environment(\.presentationMode) var presentation

    var body: some View {
        List {
            Section {
                Picker("", selection: $archivedTabsDuration) {
                    Text("After 7 Days").tag(ArchivedTabsDuration.week)
                    Text("After 30 Days").tag(ArchivedTabsDuration.month)
                    Text("Never").tag(ArchivedTabsDuration.forever)
                }.labelsHidden()
            } footer: {
                Text(
                    "Let Neeva automatically archive tabs that haven’t recently been viewed. Changes will take effect on the next app launch.",
                    comment: "Describe the purpose of the options in the archive tab settings")
            }
        }
        .listStyle(.insetGrouped)
        .pickerStyle(.inline)
        .applyToggleStyle()
        .navigationTitle(Text("Auto Archive Tabs"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    self.presentation.wrappedValue.dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .frame(width: 12, height: 20)
                        Text("Back")
                    }
                }
            }
        }
    }
}

struct ArchivedTabSettings_Previews: PreviewProvider {
    static var previews: some View {
        ArchivedTabSettings()
    }
}
