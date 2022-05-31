// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct PopoverView<Content: View>: View {
    @State private var title: LocalizedStringKey? = nil

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    let style: OverlayStyle
    let onDismiss: () -> Void
    let headerButton: OverlayHeaderButton?
    let useScrollView: Bool
    let content: () -> Content

    init(
        style: OverlayStyle,
        onDismiss: @escaping () -> Void,
        headerButton: OverlayHeaderButton? = nil,
        useScrollView: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.style = style
        self.onDismiss = onDismiss
        self.headerButton = headerButton
        self.useScrollView = useScrollView
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

                SheetHeaderButtonView(headerButton: headerButton, onDismiss: onDismiss)
                    .padding(.vertical, 12)

                VStack {
                    if style.showTitle, let title = title {
                        SheetHeaderView(title: title, onDismiss: onDismiss)
                    }

                    if useScrollView {
                        ScrollView(.vertical, showsIndicators: false) {
                            presentedContent
                        }
                    } else {
                        presentedContent
                    }
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

    @ViewBuilder
    var presentedContent: some View {
        content()
            .onPreferenceChange(OverlayTitlePreferenceKey.self) {
                self.title = $0
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
