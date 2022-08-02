// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

enum FindViewContent {
    case inPage(FindInPageModel)
    case cardGrid(TabCardModel)
}

struct FindView: View {
    let content: FindViewContent
    let onDismiss: () -> Void

    var body: some View {
        VStack {
            HStack {
                if case .inPage(let model) = content {
                    FindInPageView(model: model, onDismiss: onDismiss)
                } else if case .cardGrid(let tabCardModel) = content {
                    FindInCardGridView(tabCardModel: tabCardModel, onDismiss: onDismiss)
                }
            }
            .padding(.horizontal)
            .padding(.top, 7)

            Spacer()
        }
        .frame(height: FindInPageViewUX.height)
        .background(
            Color(UIColor.systemGroupedBackground.elevated)
                .cornerRadius(12, corners: .top)
                .ignoresSafeArea()
        )
    }
}

struct FindView_Previews: PreviewProvider {
    static var previews: some View {
        FindView(content: .inPage(FindInPageModel(tab: nil))) {}
    }
}
