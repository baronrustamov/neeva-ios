// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct TabGridCardView: View {
    @EnvironmentObject var incognitoModel: IncognitoModel
    @EnvironmentObject var tabModel: TabCardModel

    let containerGeometry: GeometryProxy

    var body: some View {
        ForEach(
            tabModel.getRowSectionsNeeded(incognito: incognitoModel.isIncognito),
            id: \.self
        ) { section in
            TabGridSectionView(
                tabModel: tabModel,
                containerGeometry: containerGeometry,
                section: section,
                incognito: incognitoModel.isIncognito
            )
        }
        .padding(.horizontal, CardGridUX.GridSpacing)
        .background(Color.background)
        .onDrop(of: ["public.url", "public.text"], delegate: tabModel)
    }
}
