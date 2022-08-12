// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Shared
import SwiftUI

struct ShareAddedSpaceView: View {
    @Environment(\.hideOverlay) private var hideOverlay
    @EnvironmentObject private var chromeModel: TabChromeModel
    @EnvironmentObject private var browserModel: BrowserModel

    @State var subscription: AnyCancellable? = nil
    @State var refreshing = false
    @State var presentingShareUI: Bool = true
    @ObservedObject var request: AddToSpaceRequest
    let bvc: BrowserViewController

    private var space: Space? {
        SpaceStore.shared.allSpaces.first(where: {
            $0.id.id == request.targetSpaceID
        })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(
                    systemSymbol: request.state == .savingToSpace
                        ? .checkmarkCircle : .checkmarkCircleFill
                )
                .foregroundColor(.label)
                .frame(width: 24, height: 24)
                Text(
                    request.state == .savingToSpace
                        ? request.textInfo.0 : request.textInfo.1
                )
                .foregroundColor(.label)
                .withFont(.bodyLarge)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .animation(nil)
            if request.state == .savedToSpace {
                HStack(spacing: 24) {
                    Spacer()
                    Button(
                        action: {
                            browserModel.openSpace(
                                spaceID: request.targetSpaceID!)

                            let entity: SpaceEntityData? = space?.contentData?.first
                            if let id = entity?.id, let space = space {
                                bvc
                                    .showModal(
                                        style: .spaces,
                                        toPosition: .top
                                    ) {
                                        AddOrUpdateSpaceContent(
                                            space: space, config: .updateSpaceItem(id)
                                        ).environmentObject(
                                            bvc.gridModel.spaceCardModel)
                                    }
                            }
                        },
                        label: {
                            Text("Edit Item")
                                .foregroundColor(refreshing ? .tertiaryLabel : .ui.adaptive.blue)
                                .withFont(.labelLarge)
                                .disabled(refreshing)
                        })
                    Button(
                        action: {
                            if let tab = bvc.tabManager.selectedTab {
                                bvc.screenshotHelper.takeScreenshot(tab)
                            }
                            browserModel.openSpace(
                                spaceID: request.targetSpaceID!)
                            hideOverlay()
                        },
                        label: {
                            Text("Open Space")
                                .foregroundColor(refreshing ? .tertiaryLabel : .ui.adaptive.blue)
                                .withFont(.labelLarge)
                                .disabled(refreshing)
                        })
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                if let space = space, space.ACL == .owner || space.isPublic {
                    Color.TrayBackground.frame(height: 2)
                    Text("Share Space")
                        .withFont(.headingSmall)
                        .foregroundColor(.secondaryLabel)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                if let space = space {
                    ShareSpaceView(
                        space: space,
                        shareTarget: bvc.view,
                        isPresented: $presentingShareUI,
                        compact: true,
                        noteText:
                            "Just added \"\(request.title)\" to my \"\(request.targetSpaceName!)\" Space."
                    )
                } else {
                    Spacer().frame(height: 210)
                }
            }
        }
        .animation(.easeInOut)
        .environment(
            \.shareURL,
            { [weak bvc] url, view in
                guard let bvc = bvc else { return }
                let helper = ShareExtensionHelper(url: url, tab: nil)
                let controller = helper.createActivityViewController({ (_, _) in })
                if UIDevice.current.userInterfaceIdiom != .pad {
                    controller.modalPresentationStyle = .formSheet
                } else {
                    controller.popoverPresentationController?.sourceView = view
                    controller.popoverPresentationController?.permittedArrowDirections = .up
                }

                bvc.present(controller, animated: true, completion: nil)
            }
        ).environmentObject(bvc.gridModel.spaceCardModel)
        .environmentObject(bvc.gridModel.tabCardModel)
        .onChange(of: presentingShareUI) { _ in
            hideOverlay()
        }.onChange(of: request.state) { state in
            if case .savedToSpace = state {
                ClientLogger.shared.logCounter(
                    .SaveToSpace,
                    attributes: getLogCounterAttributesForSpaces(
                        details: space == nil
                            ? nil
                            : SpaceCardDetails(space: space!, manager: SpaceStore.shared)))

                if let space = space {
                    SpaceStore.shared.refreshSpace(spaceID: space.id.id, anonymous: false)
                } else {
                    SpaceStore.shared.refresh()
                }

                refreshing = true

                subscription = SpaceStore.shared.$state.sink { state in
                    if case .ready = state {
                        refreshing = false
                        subscription?.cancel()
                        if let updater = request.updater, let entity = space?.contentData?.first?.id
                        {
                            updater.update(entity: entity, within: space!.id.id)
                        }
                    } else if case .failed = state {
                        refreshing = false
                        subscription?.cancel()
                    }
                }
            }
        }
    }
}
