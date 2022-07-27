// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct FeatureFlagSettingsView: View {
    @State var needsRestart = false

    @Default(FeatureFlag.defaultsKey) private var currentFeatureFlags

    var body: some View {
        List {
            ForEach(FeatureFlag.allCases.map(\.rawValue), id: \.self) { flag in
                Toggle(
                    flag,
                    isOn: Binding(
                        get: { currentFeatureFlags.contains(flag) },
                        set: { isOn in
                            needsRestart = true
                            if isOn {
                                currentFeatureFlags.insert(flag)
                            } else {
                                currentFeatureFlags.remove(flag)
                            }
                        }
                    ))
            }
        }
        .listStyle(.insetGrouped)
        .overlay(DebugSettingsRestartPromptView(isVisible: needsRestart), alignment: .bottom)
        .applyToggleStyle()
    }
}

struct FeatureFlagSettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FeatureFlagSettingsView()
                .navigationTitle(String("Feature Flags"))
                .navigationBarTitleDisplayMode(.inline)
        }.navigationViewStyle(.stack)
        NavigationView {
            FeatureFlagSettingsView(needsRestart: true)
                .navigationTitle(String("Feature Flags"))
                .navigationBarTitleDisplayMode(.inline)
        }.navigationViewStyle(.stack)
    }
}
