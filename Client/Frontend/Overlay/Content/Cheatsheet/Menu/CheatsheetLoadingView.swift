// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct CheatsheetLoadingView: View {
    public var body: some View {
        VStack(alignment: .center, spacing: 36) {
            Spacer()
            NeevaScopeLoadingView()
                .aspectRatio(1, contentMode: .fit)
                .frame(height: 100)
            Text("Your NeevaScope is coming into focus...")
                .withFont(.headingLarge)
                .foregroundColor(.label)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: 170)
            Spacer()
        }
    }
}

struct CheatsheetLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        CheatsheetLoadingView()
    }
}
