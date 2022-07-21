// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct CookieCutterOnboardingView: View {
    @EnvironmentObject var trackingStatsViewModel: TrackingStatsViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    let onOpenMyCookieCutter: () -> Void
    let onRemindMeLater: () -> Void
    let onDismiss: () -> Void

    var landscapeMode: Bool {
        verticalSizeClass == .compact || horizontalSizeClass == .regular
    }

    var body: some View {
        VStack(spacing: 14) {
            SheetHeaderView(title: "Cookie Popup Declined", addPadding: false, onDismiss: onDismiss)
                .padding(.leading, 32)
                .padding(.trailing, 24)

            VStack {
                OrientationDependentStack(
                    orientation: landscapeMode
                        ? UIDeviceOrientation.landscapeLeft : UIDeviceOrientation.portrait,
                    VStackAlignment: .leading,
                    spacing: 16
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(format: Strings.CookiePopupOnboardingMessagePart1, trackingStatsViewModel.numTrackers))
                        Text(Strings.CookiePopupOnboardingMessagePart2)
                    }

                    HStack {
                        Spacer()

                        Image("cookie-cutter-onboarding")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)

                        Spacer()
                    }
                }

                VStack(spacing: 23) {
                    Button(action: onOpenMyCookieCutter) {
                        Text(Strings.OpenMyCookieCutterButton)
                            .withFont(.labelLarge)
                            .foregroundColor(.brand.white)
                            .frame(maxWidth: .infinity)
                    }.buttonStyle(.neeva(.primary))

                    if FeatureFlag[.cookieCutterRemindMeLater] {
                        Button(action: onRemindMeLater) {
                            Text(Strings.RemindMeLaterButton)
                                .withFont(.labelLarge)
                                .foregroundColor(.ui.adaptive.blue)

                        }
                    }
                }.padding(.top, 26)
            }
            .foregroundColor(.secondary)
            .padding([.horizontal, .bottom], 32)
        }.if(!landscapeMode) {
            $0.frame(minHeight: FeatureFlag[.cookieCutterRemindMeLater] ? 600 : 560)
        }.padding(.top, landscapeMode ? 24 : 8)
    }
}

struct CookieCutterOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        CookieCutterOnboardingView(onOpenMyCookieCutter: {}, onRemindMeLater: {}, onDismiss: {})
            .environmentObject(
                TrackingStatsViewModel(
                    testingData: .init(numTrackers: 57, numDomains: 57, trackingEntities: [])))
    }
}
