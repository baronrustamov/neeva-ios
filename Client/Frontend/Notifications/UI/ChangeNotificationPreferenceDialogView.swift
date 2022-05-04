// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct ChangeNotificationPreferenceDialogView: View {
    let onOpen: () -> Void
    let onCancel: () -> Void

    var body: some View {
        GroupedStack {
            HStack {
                Text("You've disabled notifications, would you like to enable them in settings?")
                    .withFont(.bodyLarge)
                    .foregroundColor(.label)
                    .frame(height: 50)

                Spacer()
            }

            GroupedCellButton("Enable in Settings", style: .labelLarge, action: onOpen)

            GroupedCellButton("Cancel", action: onCancel)
        }
        .padding(.bottom)
        .overlayIsFixedHeight(isFixedHeight: true)
    }
}

struct ChangeNotificationPreferenceDialogView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeNotificationPreferenceDialogView {
        } onCancel: {
        }
    }
}
