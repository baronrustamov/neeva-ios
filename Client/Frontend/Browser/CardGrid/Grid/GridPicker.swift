// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct GridPicker: View {
    var isInToolbar = false

    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var gridSwitcherModel: GridSwitcherModel
    @EnvironmentObject var gridSwitcherAnimationModel: GridSwitcherAnimationModel
    @EnvironmentObject var gridVisibilityModel: GridVisibilityModel
    @EnvironmentObject var incognitoModel: IncognitoModel
    @EnvironmentObject var switcherToolbarModel: SwitcherToolbarModel

    @State var selectedIndex: Int = 1

    var isSearchingForTabs: Bool {
        gridModel.tabCardModel.isSearchingForTabs
    }

    var segments: [Segment] {
        let segments = [
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
            Segment(
                symbol: Symbol(.bookmarkOnBookmark, label: "Spaces"),
                selectedIconColor: .white, selectedColor: Color.ui.adaptive.blue,
                selectedAction: gridModel.switchToSpaces
            ),
        ]
        return segments
    }

    @ViewBuilder
    var picker: some View {
        HStack {
            Spacer()

            SegmentedPicker(
                segments: segments,
                selectedSegmentIndex: $selectedIndex, dragOffset: switcherToolbarModel.dragOffset,
                canAnimate: gridSwitcherAnimationModel.switchWithAnimation
            ).useEffect(deps: gridSwitcherModel.state) { _ in
                switch gridSwitcherModel.state {
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
                if gridSwitcherModel.state == .tabs && switcherToolbarModel.dragOffset == nil {
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
                    ? Color.DefaultBackground : Color.clear)
                    .ignoresSafeArea()
            )
            .opacity(gridVisibilityModel.showGrid ? 1 : 0)
            .disabled(isSearchingForTabs)
    }
}

struct SwipeToSwitchGridViewGesture: ViewModifier {
    var fromPicker: Bool = false

    @GestureState var dragOffset: CGFloat = 0
    @EnvironmentObject var switcherToolbarModel: SwitcherToolbarModel
    @EnvironmentObject var tabCardModel: TabCardModel

    private var gesture: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, transaction in
                let horizontalAmount = value.translation.width

                // Divide by 2.5 to follow drag more accurately
                state = fromPicker ? horizontalAmount : (-horizontalAmount / 2.5)
            }.onEnded { _ in
                switcherToolbarModel.resetDragOffset()
            }
    }

    func body(content: Content) -> some View {
        Group {
            if !tabCardModel.isSearchingForTabs {
                if fromPicker {
                    content.simultaneousGesture(gesture)
                } else {
                    content.highPriorityGesture(gesture)
                }
            } else {
                content
            }
        }.onChange(of: dragOffset) { newValue in
            if newValue == 0 {
                switcherToolbarModel.resetDragOffset()
            } else {
                switcherToolbarModel.setDragOffset(to: newValue)
            }
        }
    }
}
