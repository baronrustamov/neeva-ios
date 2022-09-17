// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct TrackingMenuProtectionOnboardingShieldButton: View {
    @Binding var preventTrackers: Bool
    @Environment(\.openSettings) var openSettings

    var body: some View {
        VStack(spacing: 0) {
            if Defaults[.cookieCutterEnabled] {
                Toggle(isOn: $preventTrackers) {
                    DetailedSettingsLabel(
                        title: "Neeva Shield",
                        description: preventTrackers
                            ? "Site appears broken? Deactivate Neeva Shield for this site."
                            : "Activate Neeva Shield for this site."
                    )
                    .padding(.vertical, 12)
                    .padding(.trailing, 18)
                }
                .applyToggleStyle()
                .padding(.horizontal, GroupedCellUX.padding)
                .accessibilityIdentifier("TrackingMenu.TrackingMenuProtectionRow")
            } else {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Neeva Shield")
                            .withFont(.bodyLarge)

                        Text("Activate Neeva Shield for this site.")
                            .foregroundColor(.secondaryLabel)
                            .font(.footnote)
                    }.padding(.horizontal, GroupedCellUX.padding)

                    Spacer()
                }.padding(.vertical, 12)
            }
        }
    }
}

struct TrackingMenuProtectionOnboardingShieldButton_Previews: PreviewProvider {
    static var previews: some View {
        TrackingMenuProtectionOnboardingShieldButton(preventTrackers: .constant(true))
        TrackingMenuProtectionOnboardingShieldButton(preventTrackers: .constant(false))
    }
}
