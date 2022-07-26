// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct NeevaUserFlagSettingsView: View {
    @ObservedObject var userFlagStore = UserFlagStore.shared

    var body: some View {
        List {
            ForEach(UserFlagStore.UserFlag.allCases, id: \.rawValue) { flag in
                HStack {
                    Text(flag.rawValue)
                        .font(.system(.body, design: .monospaced))
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    Text(
                        userFlagStore.userFlags.contains(
                            flag) ? "true" : "false")
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct NeevaUserFlagSettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NeevaUserFlagSettingsView()
                .navigationTitle(String("Server User Flags"))
                .navigationBarTitleDisplayMode(.inline)
        }.navigationViewStyle(.stack)
    }
}
