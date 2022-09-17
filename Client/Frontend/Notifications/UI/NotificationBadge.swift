// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SFSafeSymbols
import Shared
import SwiftUI

/// Used for adding a badge **into** a view.
struct NotificationBadge: View {
    let count: Int?
    private let maxCount = 99
    private let smallCircleSize: CGFloat = 8
    let fontSize: CGFloat?

    var textOversized: Bool {
        count ?? 0 > maxCount
    }

    var body: some View {
        ZStack {
            if textOversized {
                Capsule()
            } else {
                Circle()
            }

            if let count = count {
                Text(textOversized ? "\(maxCount)+" : String(count))
                    .font(.system(size: fontSize ?? 10))
                    .padding(.vertical, 3)
                    .padding(.horizontal, textOversized ? 6 : 5)
                    .foregroundColor(.white)
            }
        }
        .foregroundColor(.blue)
        .frame(minHeight: smallCircleSize)
        .fixedSize()
    }
}

enum NotificationBadgeLocation {
    case left
    case right
    case top
    case bottom

    static let topLeft = [NotificationBadgeLocation.left, NotificationBadgeLocation.top]
    static let topRight = [NotificationBadgeLocation.right, NotificationBadgeLocation.top]
    static let bottomLeft = [NotificationBadgeLocation.left, NotificationBadgeLocation.bottom]
    static let bottomRight = [NotificationBadgeLocation.right, NotificationBadgeLocation.bottom]
}

/// Used for **overlaying** a badge overlay over an entire view.
struct NotificationBadgeOverlay<Content: View>: View {
    let from: [NotificationBadgeLocation]
    let count: Int?
    let value: LocalizedStringKey
    let showBadgeOnZero: Bool
    let contentSize: CGSize?
    let fontSize: CGFloat?
    let content: Content

    var horizontalPadding: CGFloat {
        let count = count ?? 0
        if count > 99 {
            return -(contentSize?.width ?? 0) / 2 - 12
        } else if count > 9 {
            if let contentSize = contentSize {
                return -contentSize.width / 2 + 3
            } else {
                return 0
            }
        } else {
            if let contentSize = contentSize {
                return -(contentSize.width / 2) + 5
            } else {
                return 3
            }
        }
    }

    var topPadding: CGFloat {
        if from.contains(.top) || from.contains(.bottom) {
            return 3
        }
        return 0
    }

    @ViewBuilder
    var horizontalAlignedContent: some View {
        HStack {
            if showBadgeOnZero || (!showBadgeOnZero && count ?? 0 > 0) {
                if from.contains(.left) {
                    NotificationBadge(count: count, fontSize: fontSize)
                        .padding(.top, topPadding)
                        .padding(.leading, horizontalPadding)
                    Spacer()
                } else if from.contains(.right) {
                    Spacer()
                    NotificationBadge(count: count, fontSize: fontSize)
                        .padding(.top, topPadding)
                        .padding(.trailing, horizontalPadding)
                } else {
                    Spacer()
                    NotificationBadge(count: count, fontSize: fontSize)
                    Spacer()
                }
            }
        }
    }

    var body: some View {
        ZStack {
            content
                .accessibilityValue(value)

            VStack {
                if from.contains(.top) {
                    horizontalAlignedContent
                    Spacer()
                } else if from.contains(.bottom) {
                    Spacer()
                    horizontalAlignedContent
                } else {
                    Spacer()
                    horizontalAlignedContent
                    Spacer()
                }
            }.accessibilityHidden(true)
        }.fixedSize()
    }
}

struct NotificationBadge_Previews: PreviewProvider {
    static var previews: some View {
        List {
            NotificationBadge(count: nil, fontSize: nil)
            NotificationBadge(count: 1, fontSize: nil)
            NotificationBadge(count: 22, fontSize: nil)
            NotificationBadge(count: 100, fontSize: nil)
        }
    }
}
