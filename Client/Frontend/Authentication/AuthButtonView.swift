// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct AuthButtonView: View {
    let icon: Image?
    let label: LocalizedStringKey
    let foregroundColor: Color
    let backgroundColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    icon.font(.system(size: 20, weight: .semibold))
                }
                Spacer(minLength: 0)
                Text(label)
                    .font(.roobert(.semibold, size: 20))
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .foregroundColor(foregroundColor)
            .frame(height: 60)
            .background(Capsule().fill(backgroundColor))
            .padding(.bottom, 16)
        }
    }
}
