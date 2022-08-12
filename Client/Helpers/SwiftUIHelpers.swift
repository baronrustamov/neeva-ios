// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import SwiftUI

// Optionally wraps an embedded view with a ScrollView based on a specified
// threshold height value. I.e., if the view needs to be larger than the
// specified value, then a ScrollView will be inserted.
public struct VerticalScrollViewIfNeeded<EmbeddedView>: View where EmbeddedView: View {
    let embeddedView: () -> EmbeddedView

    @State var viewHeight: CGFloat = 0
    @Environment(\.inPopover) var inPopover

    var content: some View {
        embeddedView()
            .background(
                GeometryReader { contentGeom in
                    Color.clear
                        .allowsHitTesting(false)
                        .useEffect(deps: contentGeom.size.height) {
                            viewHeight = $0
                        }
                }
            )
    }

    public var body: some View {
        GeometryReader { parentGeom in
            if viewHeight > parentGeom.size.height {
                ScrollView {
                    content
                }.padding(.vertical, inPopover ? 6.5 : 0)
            } else {
                content
            }
        }
    }
}

// Used to observe / read the preference value that we store.
struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = value + nextValue()
    }
}

// Used to extract the intrinsic size of the content and store it as
// a preference value.
extension ViewHeightKey: ViewModifier {
    func body(content: Content) -> some View {
        return content.background(
            GeometryReader { proxy in
                Color.clear.preference(key: Self.self, value: proxy.size.height)
            })
    }
}

struct ViewWidthKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = value + nextValue()
    }
}

// Used to extract the intrinsic size of the content and store it as
// a preference value.
extension ViewWidthKey: ViewModifier {
    func body(content: Content) -> some View {
        return content.background(
            GeometryReader { proxy in
                Color.clear.preference(key: Self.self, value: proxy.size.width)
            })
    }
}
