// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

private let impressionOnSRPTimeInterval: TimeInterval = 2
private let impressionOnPageTimeInterval: TimeInterval = 2

struct CheatsheetInfoViewOnSRP: View {
    let buttonAction: () -> Void

    var body: some View {
        CheatsheetInfoView(buttonText: "Got it!") {
            ClientLogger.shared.logCounter(
                .AckCheatsheetEducationOnSRP,
                attributes: EnvironmentHelper.shared.getAttributes()
            )
            buttonAction()
        }
        .onAppear {
            ClientLogger.shared.logCounter(
                .ShowCheatsheetEducationOnSRP,
                attributes: EnvironmentHelper.shared.getAttributes()
            )
        }
        .modifier(
            ImpressionLoggerModifier(
                timeInterval: impressionOnSRPTimeInterval,
                path: .CheatsheetEducationImpressionOnSRP,
                attributes: EnvironmentHelper.shared.getAttributes()
            )
        )
    }
}

struct CheatsheetInfoViewOnPage: View {
    let buttonAction: () -> Void

    var body: some View {
        CheatsheetInfoView(buttonText: "Let's try it!") {
            ClientLogger.shared.logCounter(
                .AckCheatsheetEducationOnPage,
                attributes: EnvironmentHelper.shared.getAttributes()
            )
            buttonAction()
        }
        .onAppear {
            ClientLogger.shared.logCounter(
                .ShowCheatsheetEducationOnPage,
                attributes: EnvironmentHelper.shared.getAttributes()
            )
        }
        .modifier(
            ImpressionLoggerModifier(
                timeInterval: impressionOnPageTimeInterval,
                path: .CheatsheetEducationImpressionOnPage,
                attributes: EnvironmentHelper.shared.getAttributes()
            )
        )
    }
}

private struct CheatsheetInfoView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.overlayMinHeightToFillScrollView) var minHeightToFillScrollView

    @State private var textWidth: CGFloat = 0
    @State private var textHeight: CGFloat = 0
    @State private var buttonHeight: CGFloat = 0

    let buttonText: String
    let buttonAction: () -> Void

    let verticalPadding: CGFloat = 10

    var imageHeight: CGFloat {
        let height = minHeightToFillScrollView - verticalPadding - textHeight - buttonHeight
        // in popover, we can't get any minHeightToFillScrollView, so this value will be negative
        return (height < 0) ? 250 : height
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading) {
                header
                text
            }.onSizeOfViewChanged { size in
                textHeight = size.height
                textWidth = size.width
            }

            ZStack {
                Spacer()
                // hide the image on small iPhones in landscape
                if horizontalSizeClass == .regular || verticalSizeClass == .regular {
                    Image("cheatsheet", bundle: .main)
                        .resizable()
                        .scaledToFit()
                        .padding(.vertical)
                        .frame(maxHeight: imageHeight)
                        .accessibilityHidden(true)
                        .layoutPriority(-1)
                }
            }

            button
                .frame(maxWidth: textWidth)
                .onHeightOfViewChanged {
                    buttonHeight = $0
                }
        }
        .multilineTextAlignment(.leading)
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, 16)
        .layoutPriority(1)
        .frame(minHeight: minHeightToFillScrollView)
    }

    @ViewBuilder
    var header: some View {
        HStack(alignment: .center) {
            Image("neeva-logo", bundle: .main)
                .resizable()
                .scaledToFit()
                .frame(height: 18, alignment: .center)
            Text("NeevaScope")
                .withFont(.headingXLarge)
        }
    }

    @ViewBuilder
    var text: some View {
        Text(
            "Tap on the Neeva logo to see information related to the website you're visiting."
        )
        .withFont(.bodyLarge)
        .foregroundColor(.secondaryLabel)
        .fixedSize(horizontal: false, vertical: true)
        .layoutPriority(1)
        Text(
            "From related content to reviews, NeevaScope is your guide to the web!"
        )
        .withFont(.bodyLarge)
        .foregroundColor(.secondaryLabel)
        .fixedSize(horizontal: false, vertical: true)
        .layoutPriority(1)
    }

    @ViewBuilder
    var button: some View {
        Button(action: buttonAction) {
            HStack {
                Spacer()
                Text(buttonText)
                    .withFont(.labelLarge)
                Spacer()
            }
        }
        .buttonStyle(.neeva(.primary))
    }
}
