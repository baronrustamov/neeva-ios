// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

private let cheatsheetUGCIndicatorImpressionTimerInterval: TimeInterval = 1

private enum CheatsheetUGCIndicatorUX {
    static let iconSize: CGFloat = 24
}

struct CheatsheetUGCIndicatorView: View {
    @State var impressionTimer: Timer? = nil

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image("reddit-logo")
                .resizable()
                .frame(
                    width: CheatsheetUGCIndicatorUX.iconSize,
                    height: CheatsheetUGCIndicatorUX.iconSize
                )
            Text("See what people have said about this page")
                .withFont(.headingSmall)
                .foregroundColor(.label)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 5)
        .onAppear {
            impressionTimer?.invalidate()
            impressionTimer = Timer.scheduledTimer(
                withTimeInterval: cheatsheetUGCIndicatorImpressionTimerInterval,
                repeats: false
            ) { _ in
                ClientLogger.shared.logCounter(
                    .CheatsheetUGCIndicatorImpression,
                    attributes: EnvironmentHelper.shared.getAttributes()
                )
            }
        }
        .onDisappear {
            impressionTimer?.invalidate()
            impressionTimer = nil
        }
    }
}
