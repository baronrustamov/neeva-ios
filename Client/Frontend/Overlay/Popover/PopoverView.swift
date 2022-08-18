// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct PopoverView<Content: View>: View {
    @State private var title: LocalizedStringKey?
    @State private var safeAreaBottom: CGFloat = 0

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    let style: OverlayStyle
    let headerButton: OverlayHeaderButton?
    let content: () -> Content
    let onDismiss: () -> Void

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

                HStack {
                    Spacer()

                    VStack(spacing: 12) {
                        SheetHeaderButtonView(headerButton: headerButton, onDismiss: onDismiss)

                        VStack {
                            if style.showTitle, let title = title {
                                SheetHeaderView(title: title, onDismiss: onDismiss)
                            }

                            ScrollView(.vertical, showsIndicators: false) {
                                content()
                                    .padding(.bottom, safeAreaBottom)
                                    .onPreferenceChange(OverlayTitlePreferenceKey.self) {
                                        self.title = $0
                                    }
                            }
                        }
                        .padding(14)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .background(
                            Color(style.backgroundColor)
                                .cornerRadius(16)
                        )
                    }
                    .frame(
                        minWidth: 400,
                        maxWidth: geo.size.width - (horizontalPadding * 2),
                        minHeight: 300,
                        maxHeight: geo.size.height - (verticalPadding * 2)
                    )
                    .fixedSize(
                        horizontal: !style.expandPopoverWidth, vertical: !style.expandPopoverHeight)

                    Spacer()
                }

                Spacer()
            }
        }
        .accessibilityAction(.escape, onDismiss)
        .ignoresSafeArea()
        .safeAreaChanged { safeArea in
            safeAreaBottom = safeArea.bottom
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
