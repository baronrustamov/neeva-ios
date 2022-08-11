// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct WelcomeFlowPrivacyAndTermsLinksView: View {
    var termsButton: some View {
        SafariVCLink("Terms of Service", url: NeevaConstants.appTermsURL)
    }

    var privacyButton: some View {
        SafariVCLink("Privacy Policy", url: NeevaConstants.appPrivacyURL)
    }

    var body: some View {
        HStack {
            termsButton
            Text("·").foregroundColor(.secondaryLabel)
            privacyButton
        }
        .withFont(unkerned: .bodySmall)
        .padding(.bottom, 15)
    }
}
