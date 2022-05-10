// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct SheetHeaderView: View {
    let title: LocalizedStringKey
    var addPadding: Bool = true
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .withFont(.headingXLarge)
                .foregroundColor(.label)
                .padding(.leading, addPadding ? 16 : 0)

            Spacer()

            Button(action: onDismiss) {
                Symbol(.xmark, style: .headingMedium, label: "Close")
                    .foregroundColor(.tertiaryLabel)
                    .padding(7)
                    .background(
                        Circle()
                            .foregroundColor(.secondaryBackground)
                    ).tapTargetFrame()
            }.padding(.trailing, addPadding ? 8 : 0)
        }
    }
}

struct SheetHeaderButtonView: View {
    let headerButton: OverlayHeaderButton?
    let onDismiss: () -> Void

    var body: some View {
        if let headerButton = headerButton {
            HStack(spacing: 0) {
                Spacer().layoutPriority(0.5)

                Button {
                    headerButton.action()
                    onDismiss()
                } label: {
                    HStack(spacing: 10) {
                        Text(headerButton.text)
                            .withFont(.labelLarge)
                        Symbol(decorative: headerButton.icon)
                    }.frame(maxWidth: .infinity)
                }
                .buttonStyle(.neeva(.primary))
                .layoutPriority(0.5)
            }
        }
    }
}

struct SheetHeader_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SheetHeaderButtonView(
                headerButton: OverlayHeaderButton(text: "Header Button", icon: .bubbleLeft) {}
            ) {}
            SheetHeaderView(title: "Header") {}
        }

    }
}
