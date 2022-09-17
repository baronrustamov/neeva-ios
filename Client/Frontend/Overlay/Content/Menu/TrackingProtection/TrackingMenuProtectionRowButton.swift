// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct TrackingMenuProtectionRowButton: View {
    @Binding var preventTrackers: Bool
    @Environment(\.openSettings) var openSettings

    var body: some View {
        GroupedCell.Decoration {
            VStack(spacing: 0) {
                if Defaults[.cookieCutterEnabled] {
                    Toggle(isOn: $preventTrackers) {
                        DetailedSettingsLabel(
                            title: "Neeva Shield",
                            description: "Site appears broken? Try deactivating."
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

                            Text("Deactivated. Activate in Settings.")
                                .foregroundColor(.secondaryLabel)
                                .font(.footnote)
                        }.padding(.horizontal, GroupedCellUX.padding)

                        Spacer()
                    }.padding(.vertical, 12)
                }

                Color.groupedBackground.frame(height: 1)

                Button {
                    openSettings(.cookieCutter)
                } label: {
                    HStack {
                        Text("Neeva Shield Settings")
                            .foregroundColor(.label)

                        Spacer()

                        Symbol(decorative: .chevronRight)
                            .foregroundColor(.secondaryLabel)
                    }
                    .padding(.horizontal, GroupedCellUX.padding)
                    .frame(minHeight: GroupedCellUX.minCellHeight)
                }
                .accessibilityLabel(Text("Neeva Shield Settings"))
                .frame(minWidth: 275)
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
