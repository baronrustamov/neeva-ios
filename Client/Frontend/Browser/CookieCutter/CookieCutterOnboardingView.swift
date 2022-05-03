// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct CookieCutterOnboardingView: View {
    @EnvironmentObject var trackingStatsViewModel: TrackingStatsViewModel

    let onOpenMyCookieCutter: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            SheetHeaderView(title: "Cookie Popup Declined", addPadding: false, onDismiss: onDismiss)
                .padding(.leading, 32)
                .padding(.trailing, 24)

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Cookie Cutter just declined a ")
                        + Text("cookie popup ")
                        .bold()
                        + Text("and blocked ")
                        + Text("\(trackingStatsViewModel.numTrackers) trackers.")
                        .bold()

                    Text(
                        "Cookie Cutter by Neeva stops annoying cookie popups and blocks invasive trackers across the web."
                    )
                }

                HStack {
                    Spacer()

                    Image("cookie-cutter-onboarding")
                        .resizable()
                        .scaledToFit()

                    Spacer()
                }

                VStack(spacing: 23) {
                    Button(action: onOpenMyCookieCutter) {
                        Text("Open My Cookie Cutter")
                            .withFont(.labelLarge)
                            .foregroundColor(.brand.white)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.neeva(.primary))

                    Button {
                        NotificationPermissionHelper.shared.requestPermissionIfNeeded(
                            openSettingsIfNeeded: false, callSite: .defaultBrowserInterstitial
                        ) { authorized in
                            if authorized {
                                LocalNotifications.scheduleNeevaOnboardingCallback(
                                    notificationType: .neevaOnboardingCookieCutter)
                            }
                        }
                    } label: {
                        Text("Remind Me Later")
                            .withFont(.labelLarge)
                            .foregroundColor(.ui.adaptive.blue)

                    }
                }.padding(.top, 26)
            }
            .foregroundColor(.secondary)
            .padding([.horizontal, .bottom], 32)
        }.frame(minHeight: 600)
    }
}

struct CookieCutterOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        CookieCutterOnboardingView {
        } onDismiss: {
        }.environmentObject(
            TrackingStatsViewModel(
                testingData: .init(numTrackers: 57, numDomains: 57, trackingEntities: [])))
    }
}
