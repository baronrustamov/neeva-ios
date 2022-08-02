// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct GridPicker: View {
    var isInToolbar = false

    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var incognitoModel: IncognitoModel
    @EnvironmentObject var switcherToolbarModel: SwitcherToolbarModel
    @EnvironmentObject var browserModel: BrowserModel

    @State var selectedIndex: Int = 1

    var isSearchingForTabs: Bool {
        gridModel.tabCardModel.isSearchingForTabs
    }

    var segments: [Segment] {
        var segments = [
            Segment(
                symbol: Symbol(.incognito, weight: .medium, label: "Incognito Tabs"),
                selectedIconColor: .background,
                selectedColor: .label,
                selectedAction: { gridModel.switchToTabs(incognito: true) }),
            Segment(
                symbol: Symbol(.squareOnSquare, weight: .medium, label: "Normal Tabs"),
                selectedIconColor: .white,
                selectedColor: Color.ui.adaptive.blue,
                selectedAction: { gridModel.switchToTabs(incognito: false) }),
        ]
        if NeevaConstants.currentTarget != .xyz {
            segments.append(
                Segment(
                    symbol: Symbol(.bookmarkOnBookmark, label: "Spaces"),
                    selectedIconColor: .white, selectedColor: Color.ui.adaptive.blue,
                    selectedAction: gridModel.switchToSpaces
                ))
        }
        return segments
    }

    @ViewBuilder
    var picker: some View {
        HStack {
            Spacer()

            SegmentedPicker(
                segments: segments,
                selectedSegmentIndex: $selectedIndex, dragOffset: switcherToolbarModel.dragOffset,
                canAnimate: !gridModel.switchModeWithoutAnimation
            ).useEffect(deps: gridModel.switcherState) { _ in
                switch gridModel.switcherState {
                case .tabs:
                    if switcherToolbarModel.dragOffset == nil {
                        selectedIndex = 1
                    }
                case .spaces:
                    if switcherToolbarModel.dragOffset == nil {
                        selectedIndex = 2
                    }

                    if incognitoModel.isIncognito {
                        gridModel.tabCardModel.manager.toggleIncognitoMode(
                            fromTabTray: true, openLazyTab: false)
                    }
                }
            }.useEffect(deps: incognitoModel.isIncognito) { isIncognito in
                if gridModel.switcherState == .tabs && switcherToolbarModel.dragOffset == nil {
                    selectedIndex = isIncognito ? 0 : 1
                }
            }.opacity(isSearchingForTabs ? 0.5 : 1)

            Spacer()
        }
    }

    var body: some View {
        picker
            .frame(height: gridModel.pickerHeight)
            .background(
                (!isInToolbar
                    ? Color.background : Color.clear)
                    .ignoresSafeArea()
            )
            .opacity(browserModel.showGrid ? 1 : 0)
            .disabled(isSearchingForTabs)
    }
}

struct SwipeToSwitchToSpacesGesture: ViewModifier {
    var fromPicker: Bool = false

    @EnvironmentObject var switcherToolbarModel: SwitcherToolbarModel
    @EnvironmentObject var tabCardModel: TabCardModel

    private var gesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let horizontalAmount = value.translation.width as CGFloat

                // Divide by 2.5 to follow drag more accurately
                horizontalOffsetChanged(
                    fromPicker ? horizontalAmount : (-horizontalAmount / 2.5))
            }.onEnded { value in
                horizontalOffsetChanged(nil)
            }
    }

    private func horizontalOffsetChanged(_ offset: CGFloat?) {
        switcherToolbarModel.dragOffset = offset
    }

    func body(content: Content) -> some View {
        if !tabCardModel.isSearchingForTabs {
            if fromPicker {
                content.simultaneousGesture(gesture)
            } else {
                content.gesture(gesture)
            }
        } else {
            content
        }
    }
}
