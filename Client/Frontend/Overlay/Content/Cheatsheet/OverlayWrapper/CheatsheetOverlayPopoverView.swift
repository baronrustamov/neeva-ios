// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct CheatsheetOverlayPopoverView<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    let style: OverlayStyle = .cheatsheet

    let onDismiss: () -> Void
    let content: () -> Content

    init(
        onDismiss: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.onDismiss = onDismiss
        self.content = content
    }

    var horizontalPadding: CGFloat {
        paddingForSizeClass(horizontalSizeClass)
    }

    var verticalPadding: CGFloat {
        paddingForSizeClass(verticalSizeClass)
    }

    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()

                VStack {
                    content()
                }
                .padding(14)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .background(
                    Color(style.backgroundColor)
                        .cornerRadius(16)
                )
                // 60 is button height + VStack padding
                .frame(
                    minWidth: 400,
                    maxWidth: geo.size.width - (horizontalPadding * 2),
                    maxHeight: geo.size.height - verticalPadding - 60,
                    alignment: .center
                ).fixedSize(horizontal: !style.expandPopoverWidth, vertical: true)

                Spacer()
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .accessibilityAction(.escape, onDismiss)
        }
    }

    func paddingForSizeClass(_ sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        if let sizeClass = sizeClass, case .regular = sizeClass {
            return 50
        } else {
            return 12
        }
    }
}
