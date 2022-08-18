/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import SwiftUI

struct SuggestionsContent: View {
    @ObservedObject var suggestionModel: SuggestionModel

    var body: some View {
        VStack(spacing: 0) {
            if let error = suggestionModel.error {
                GeometryReader { geom in
                    ScrollView {
                        ErrorView(error, in: self, tryAgain: suggestionModel.reload)
                            .frame(minHeight: geom.size.height)
                    }
                }
            } else {
                SuggestionsList()
                    .environmentObject(suggestionModel)
            }
        }.onAppear {
            suggestionModel.reload()
        }
    }
}
