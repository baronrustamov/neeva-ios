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
                        Text("Cookie Cutter")
                            .withFont(.bodyLarge)

                        Text("Site appears broken? Try deactivating.")
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

                Button {
                    openSettings(.cookieCutter)
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
                }.accessibilityLabel(Text("Cookie Cutter Settings"))
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
