// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct NotificationPromptViewOverlayContent: View {
    var body: some View {
        NotificationPromptView()
            .overlayIsFixedHeight(isFixedHeight: true)
            .background(Color(.systemBackground))
    }
}

struct NotificationPromptView: View {
    @Environment(\.hideOverlay) private var hideOverlay

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading) {
                Text("Stay in the know").withFont(.headingXLarge).padding(.top, 32)
                Text("From news to shopping, we bring the best of the web to you!")
                    .withFont(.bodyLarge)
                    .foregroundColor(.secondaryLabel)
                Text("You can opt out in settings anytime.")
                    .withFont(.bodyLarge)
                    .foregroundColor(.secondaryLabel)
            }
            .padding(.horizontal, 32)
            .fixedSize(horizontal: false, vertical: true)
            Image("notification-prompt", bundle: .main)
                .resizable()
                .frame(width: 259, height: 222)
                .padding(32)
            Button(
                action: {
                    NotificationPermissionHelper.shared.requestPermissionIfNeeded(
                        openSettingsIfNeeded: false, callSite: .tourFlow
                    ) { authorized in
                        if authorized {
                            LocalNotifications.scheduleAllNeevaOnboardingCallbackIfAuthorized()
                        }

                        DispatchQueue.main.async {
                            hideOverlay()
                        }
                    }

                    ClientLogger.shared.logCounter(.NotificationPromptEnable)
                },
                label: {
                    Text("Enable notifications")
                        .withFont(.labelLarge)
                        .foregroundColor(.brand.white)
                        .padding(13)
                        .frame(maxWidth: .infinity)
                }
            )
            .buttonStyle(.neeva(.primary))
            .padding(.top, 36)
            .padding(.horizontal, 16)
            Button(
                action: {
                    hideOverlay()
                    ClientLogger.shared.logCounter(.NotificationPromptSkip)
                },
                label: {
                    Text("Skip for now")
                        .withFont(.labelLarge)
                        .foregroundColor(.ui.adaptive.blue)
                        .padding(13)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                }
            ).padding(.top, 10)
        }
        .padding(.bottom, 20)
    }
}

struct NotificationPromptView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPromptView()
    }
}
