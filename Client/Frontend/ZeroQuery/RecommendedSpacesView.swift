// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct RecommendedSpacesView: View {
    @ObservedObject var store: SpaceStore
    @ObservedObject var viewModel: ZeroQueryModel
    @Binding var expandSuggestedSpace: TriState

    var body: some View {
        if let suggestedSpaceId = SpaceStore.suggested.suggestedSpaceID,
            let space = store.allSpaces.first(where: { $0.id.id == suggestedSpaceId })
        {
            ZeroQueryHeader(
                title: "From the Neeva Community",
                action: { expandSuggestedSpace.advance() },
                label: "\(expandSuggestedSpace.verb) this section",
                icon: expandSuggestedSpace.icon,
                hideToggle: !Defaults[.didFirstNavigation]
            )
            if expandSuggestedSpace != .hidden {
                CompactSpaceDetailList(
                    primitive: SpaceCardDetails(
                        space: space,
                        manager: SpaceStore.suggested),
                    state: expandSuggestedSpace
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .environment(
                    \.onOpenURLForSpace,
                    { url, id in
                        if url.absoluteString.starts(
                            with: NeevaConstants.appSpacesURL.absoluteString),
                            let navPath = NavigationPath.navigationPath(
                                from: URL(
                                    string: NeevaConstants.appDeepLinkURL.absoluteString
                                        + "space?id="
                                        + url.lastPathComponent)!,
                                with: viewModel.bvc)
                        {
                            viewModel.bvc.hideZeroQuery()
                            NavigationPath.handle(nav: navPath, with: viewModel.bvc)
                        } else {
                            viewModel.bvc.tabManager.createOrSwitchToTab(
                                for: url)
                            viewModel.bvc.hideZeroQuery()
                        }

                        ClientLogger.shared.logCounter(
                            .SpacesRecommendedDetailUIVisited,
                            attributes: [
                                ClientLogCounterAttribute(
                                    key: LogConfig.SpacesAttribute.spaceID, value: id)
                            ]
                        )
                    }
                )
                .environmentObject(viewModel.bvc.gridModel)
                .environmentObject(viewModel.bvc.gridModel.tabCardModel)
                .environmentObject(viewModel.bvc.gridModel.spaceCardModel)
            }
        }
    }
}
