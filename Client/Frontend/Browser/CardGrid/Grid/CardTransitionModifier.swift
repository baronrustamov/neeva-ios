// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct CardTransitionUX {
    static let animation = Animation.interpolatingSpring(stiffness: 425, damping: 30)
}

struct ScrollToCompletionModifier<Details: CardDetails>: ViewModifier {
    let details: Details

    // Getting GridScrollModel indirectly here to avoid unnecessary updates due to
    // properties of GridScrollModel being updated that this View doesn't care about.
    // See the useEffect call below.
    @EnvironmentObject var browserModel: BrowserModel
    var gridScrollModel: GridScrollModel { browserModel.gridModel.scrollModel }

    func runCompletion() {
        if details.isSelected, let completion = gridScrollModel.scrollToCompletion {
            gridScrollModel.scrollToCompletion = nil
            DispatchQueue.main.async(execute: completion)
        }
    }

    func body(content: Content) -> some View {
        content
            // NOTE: There is potential for a race condition here when `didHorizontalScroll`
            // is signaled after vertically scrolling the `CardGrid`. We might end up
            // triggering `scrollCompletion` early in some cases as a result. The async
            // execution of `completion` helps mask that issue, but unclear if it is a
            // robust solution.
            // NOTE: Observing just these specific published vars and not all of GridScrollModel
            // to avoid spurious updates.
            .useEffect(gridScrollModel.$didHorizontalScroll, gridScrollModel.$didVerticalScroll) {
                runCompletion()
            }
    }
}

struct CardTransitionModifier<Details: CardDetails>: ViewModifier {
    let details: Details
    let containerGeometry: GeometryProxy
    var extraBottomPadding: CGFloat = 0

    @EnvironmentObject var cardTransitionModel: CardTransitionModel
    @EnvironmentObject var gridVisibilityModel: GridVisibilityModel

    func body(content: Content) -> some View {
        content
            .zIndex(details.isSelected ? 1 : 0)
            .opacity(details.isSelected && cardTransitionModel.state != .hidden ? 0 : 1)
            .animation(nil)
            .overlay(overlay)
            .modifier(ScrollToCompletionModifier(details: details))
    }

    var overlay: some View {
        GeometryReader { geom in
            if details.isSelected && cardTransitionModel.state != .hidden {
                let rect = calculateCardRect(geom: geom)
                overlayCard
                    .offset(x: rect.minX, y: rect.minY)
                    .frame(width: rect.width, height: rect.height)
                    .animation(CardTransitionUX.animation)
                    .transition(.identity)
            }
        }.accessibilityHidden(true)
    }

    @ViewBuilder var overlayCard: some View {
        if let tabGroupDetails = details as? TabGroupCardDetails {
            let selectedTabDetails = (tabGroupDetails.allDetails.first { $0.isSelected })!
            Card(details: selectedTabDetails, animate: true, showGrid: gridVisibilityModel.showGrid)
        } else {
            Card(details: details, animate: true, showGrid: gridVisibilityModel.showGrid)
        }
    }

    func calculateCardRect(geom: GeometryProxy) -> CGRect {
        if gridVisibilityModel.showGrid {
            return geom.frame(in: .local)
        }

        let cardFrame = geom.frame(in: .global)
        let containerFrame = containerGeometry.frame(in: .global)

        let x = -cardFrame.minX
        let y = containerFrame.minY - cardFrame.minY

        // On iPhone we should find the full width of the display
        // since the `containerFrame` does not account for the notch and safe area (in landscape mode).
        let width =
            UIDevice.current.useTabletInterface ? containerFrame.width : UIScreen.main.bounds.width
        let height = containerFrame.size.height - extraBottomPadding + CardUX.HeaderSize

        return CGRect(x: x, y: y, width: width, height: height)
    }
}
