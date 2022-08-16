// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct DebugLocaleSetting: View {
    @ObservedObject var userInfo = NeevaUserInfo.shared

    var body: some View {
        Picker(String("Country"), selection: $userInfo.countryCode) {
            ForEach(Array(SearchEngine.countryMapping).sorted(by: { $0.0 < $1.0 }), id: \.key) {
                (key, value) in
                HStack {
                    Text(key)
                    if key != value {
                        Text(verbatim: "(\(value))")
                            .foregroundColor(.secondary)
                    }
                }.tag(key)
            }
        }
    }
}

struct DebugLocaleSetting_Previews: PreviewProvider {
    static var previews: some View {
        SettingPreviewWrapper {
            DebugLocaleSetting()
        }
    }
}
