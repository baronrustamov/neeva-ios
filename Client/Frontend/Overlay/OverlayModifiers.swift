// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

// This PreferenceKey may be used by a child View of the OverlayView (i.e., PopoverView or OverlaySheetView)
// to specify a title for the sheet.
//
// E.g.:
//
//    PopoverView(..) {
//        SomeContent()
//            .overlayTitle(title: "Some Title")
//    }
//
struct OverlayTitlePreferenceKey: PreferenceKey {
    static var defaultValue: LocalizedStringKey?
    static func reduce(value: inout LocalizedStringKey?, nextValue: () -> LocalizedStringKey?) {
        value = nextValue()
    }
}

struct OverlayTitleViewModifier: ViewModifier {
    let title: LocalizedStringKey
    func body(content: Content) -> some View {
        content.preference(
            key: OverlayTitlePreferenceKey.self,
            value: title)
    }
}

extension View {
    func overlayTitle(title: LocalizedStringKey) -> some View {
        self.modifier(OverlayTitleViewModifier(title: title))
    }
}

// This PreferenceKey may be used by a child View of the OverlayView
// to specify that the content should be treated as fixed height.
struct OverlayIsFixedHeightPreferenceKey: PreferenceKey {
    typealias Value = Bool
    static var defaultValue: Bool = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

struct OverlayIsFixedHeightViewModifier: ViewModifier {
    let isFixedHeight: Bool
    func body(content: Content) -> some View {
        content.preference(
            key: OverlayIsFixedHeightPreferenceKey.self,
            value: isFixedHeight)
    }
}

extension View {
    func overlayIsFixedHeight(isFixedHeight: Bool) -> some View {
        self.modifier(OverlayIsFixedHeightViewModifier(isFixedHeight: isFixedHeight))
    }
}

/// This PreferenceKey may be used by a child View of the OverlaySheetView
/// to specify a preferred height in the middle position
struct OverlaySheetMiddleHeightPreferenceKey: PreferenceKey {
    typealias Value = CGFloat?
    static var defaultValue: Value = nil
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

struct OverlaySheetMiddleHeightViewModifier: ViewModifier {
    let middleHeight: CGFloat?
    func body(content: Content) -> some View {
        content.preference(key: OverlaySheetMiddleHeightPreferenceKey.self, value: middleHeight)
    }
}

extension View {
    func overlaySheetMiddleHeight(height: CGFloat?) -> some View {
        self.modifier(OverlaySheetMiddleHeightViewModifier(middleHeight: height))
    }
}

/// This PreferenceKey may be used by a child View of the OverlaySheetView
/// to be layed out as if safe can be ignored
struct OverlaySheetIgnoreSafeAreaPreferenceKey: PreferenceKey {
    typealias Value = Edge.Set
    static var defaultValue: Value = []
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

struct OverlaySheetIgnoreSafeAreaViewModifier: ViewModifier {
    let edges: Edge.Set
    func body(content: Content) -> some View {
        content.preference(key: OverlaySheetIgnoreSafeAreaPreferenceKey.self, value: edges)
    }
}

extension View {
    func overlaySheetIgnoreSafeArea(edges: Edge.Set) -> some View {
        self.modifier(OverlaySheetIgnoreSafeAreaViewModifier(edges: edges))
    }
}
