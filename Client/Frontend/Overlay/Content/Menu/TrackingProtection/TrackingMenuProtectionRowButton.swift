// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

public struct TrackingMenuProtectionRowButton: View {
    @Binding var preventTrackers: Bool
    @Environment(\.openSettings) var openSettings

    public var body: some View {
        GroupedCell.Decoration {
            VStack(spacing: 0) {
                Toggle(isOn: $preventTrackers) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(FeatureFlag[.cookieCutter] ? "Cookie Cutter" : "Tracking Prevention")
                            .withFont(.bodyLarge)

                        Text(
                            FeatureFlag[.cookieCutter]
                                ? "Site appears broken? Try disabling."
                                : "Website not working? Try disabling."
                        )
                        .foregroundColor(.secondaryLabel)
                        .font(.footnote)
                    }
                    .padding(.vertical, 12)
                    .padding(.trailing, 18)
                }
                .applyToggleStyle()
                .padding(.horizontal, GroupedCellUX.padding)
                .accessibilityIdentifier("TrackingMenu.TrackingMenuProtectionRow")

                Color.groupedBackground.frame(height: 1)

                if FeatureFlag[.cookieCutter] {
                    Button {
                        openSettings()
                    } label: {
                        HStack {
                            Text("Cookie Cutter Settings")
                                .foregroundColor(.label)

                            Spacer()

                            Symbol(decorative: .chevronRight)
                                .foregroundColor(.secondaryLabel)
                        }
                        .padding(.horizontal, GroupedCellUX.padding)
                        .frame(minHeight: GroupedCellUX.minCellHeight)
                    }
                }
            }
        }
    }
}

struct TrackingMenuProtectionRowButton_Previews: PreviewProvider {
    static var previews: some View {
        TrackingMenuProtectionRowButton(preventTrackers: .constant(true))
        TrackingMenuProtectionRowButton(preventTrackers: .constant(false))
    }
}
