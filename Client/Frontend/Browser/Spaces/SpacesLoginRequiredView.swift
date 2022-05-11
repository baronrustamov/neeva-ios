// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct SpacesLoginRequiredView: View {
    @Environment(\.onSigninOrJoinNeeva) var onSigninOrJoinNeeva

    var body: some View {
        VStack {
            Spacer()

            Text("Please sign in")
                .withFont(.headingXLarge)

            Button(action: onSigninOrJoinNeeva) {
                HStack {
                    Image("neeva-logo", bundle: .main)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 19)
                        .padding(.trailing, 3)

                    Spacer()

                    Text("Sign in or Join Neeva")

                    Spacer()
                }
                .padding(.horizontal, 40)
            }
            .buttonStyle(.neeva(.primary))

            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
        .padding(.bottom, 16)
    }
}
