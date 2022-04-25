// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

/// A `View` intended to be embedded within an `OverlayView`, used to
/// present the `AddToSpaceView` UI.
struct AddToSpaceOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay
    @EnvironmentObject private var overlayModel: OverlaySheetModel

    @ObservedObject var request: AddToSpaceRequest

    let bvc: BrowserViewController
    let importData: SpaceImportHandler?

    var isFixedHeight: Bool {
        !NeevaUserInfo.shared.isVerified
            || (request.mode == .saveToNewSpace
                && (request.state == .creatingSpace || request.state == .initial))
    }

    @ViewBuilder
    var content: some View {
        if NeevaUserInfo.shared.isUserLoggedIn, !NeevaUserInfo.shared.isVerified {
            EmailVerificationPrompt(email: NeevaUserInfo.shared.email ?? "", dismiss: hideOverlay)
        } else if request.state == .savedToSpace || request.state == .savingToSpace {
            VStack {
                Spacer()

                ShareAddedSpaceView(request: request, bvc: bvc)
                    .onAppear {
                        withAnimation {
                            overlayModel.position = .middle
                        }
                    }
            }
        } else {
            AddToSpaceView(
                request: request,
                onDismiss: hideOverlay,
                importData: importData
            )
        }
    }

    var body: some View {
        content
            .overlayTitle(title: request.mode.title)
            .overlayIsFixedHeight(
                isFixedHeight: isFixedHeight
            )
            .environment(\.onSigninOrJoinNeeva) {
                ClientLogger.shared.logCounter(
                    .AddToSpaceErrorSigninOrJoinNeeva,
                    attributes: EnvironmentHelper.shared.getFirstRunAttributes())
                hideOverlay()
                bvc.presentIntroViewController(
                    true,
                    onDismiss: {
                        DispatchQueue.main.async {
                            bvc.hideCardGrid(withAnimation: true)
                        }
                    }
                )
            }
    }
}
