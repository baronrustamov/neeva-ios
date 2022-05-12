// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Shared
import SwiftUI

struct CreateSpaceOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay
    @EnvironmentObject var spaceModel: SpaceCardModel
    @State private var subscription: AnyCancellable? = nil

    var body: some View {
        if NeevaUserInfo.shared.isUserLoggedIn, !NeevaUserInfo.shared.isVerified {
            EmailVerificationPrompt(email: NeevaUserInfo.shared.email ?? "", dismiss: hideOverlay)
                .overlayIsFixedHeight(isFixedHeight: true)
                .overlayTitle(title: "Create a Space")
        } else if NeevaUserInfo.shared.isUserLoggedIn {
            CreateSpaceView { spaceName in
                if !spaceName.isEmpty {
                    let request = SpaceServiceProvider.shared.createSpace(name: spaceName)
                    subscription = request?.$state.sink { state in
                        switch state {
                        case .success:
                            SpaceStore.shared.refresh()
                            subscription = spaceModel.objectWillChange.sink {
                                if let details = spaceModel.allDetails.first(where: {
                                    $0.title == spaceName
                                }) {
                                    DispatchQueue.main.async {
                                        spaceModel.detailedSpace = details
                                        subscription?.cancel()
                                    }
                                }
                            }
                        case .failure:
                            subscription?.cancel()
                        case .initial:
                            Logger.browser.info("Waiting for result from creating space")
                        }
                    }
                }
                hideOverlay()
            }
            .overlayIsFixedHeight(isFixedHeight: true)
            .overlayTitle(title: "Create a Space")
        }
    }
}

struct CreateSpaceOverlayContent_Previews: PreviewProvider {
    static var previews: some View {
        CreateSpaceOverlayContent()
    }
}
