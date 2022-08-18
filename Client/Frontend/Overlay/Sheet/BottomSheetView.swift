// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

enum BottomSheetPosition: LocalizedStringKey {
    case top = "Fullscreen"
    case peeking = "Peeking from the bottom"
    case dismissed = ""
}

class BottomSheetModel: ObservableObject {
    @Published var topBarHeight: CGFloat = 0
    @Published var peekHeight: CGFloat = 0
    @Published var deltaHeight: CGFloat = 0
    @Published var position: BottomSheetPosition = .dismissed

    func showPeeking() {
        withAnimation(.easeOut(duration: BottomSheetUX.animationDuration)) {
            self.position = .peeking
            self.deltaHeight = 0
        }
    }
}

enum BottomSheetUX {
    /// Number of points you have to drag the top bar to tigger an animation
    /// of the overlay sheet to a new position.
    static let slideThreshold: CGFloat = 60

    /// Duration of slide animations.
    static let animationDuration: Double = 0.2

    static let minSpacing: CGFloat = 75
}

// This view provides an bottom sheet implementation that starts in a
// peeking position. The user can drag it to top position.
struct BottomSheetView<Content: View>: View {
    @StateObject var model = BottomSheetModel()
    let peekContentHeight: CGFloat

    @State private var contentHeight: CGFloat = 0

    let onDismiss: () -> Void
    let content: () -> Content

    private func getYOffset(_ outerGeometry: GeometryProxy) -> CGFloat {
        let defaultSize: CGFloat
        switch model.position {
        case .top:
            defaultSize = BottomSheetUX.minSpacing + model.deltaHeight
        case .peeking:
            defaultSize =
                contentHeight + model.topBarHeight - model.peekHeight + model.deltaHeight
        case .dismissed:
            defaultSize = outerGeometry.size.height
        }
        return defaultSize
    }

    var topBar: some View {
        Capsule()
            .fill(Color.tertiaryLabel)
            .frame(width: 32, height: 4)
            .padding(15).background(Color.clear)  // make the selectable area larger
            .accessibilityElement()
            .accessibilityLabel("Pop-up controller")
            .accessibilityValue(model.position.rawValue)
            .accessibilityHint("Adjust the size of this pop-up window")
            .padding(-15)
            .padding(.vertical, 8)
    }

    var body: some View {
        GeometryReader { outerGeometry in
            VStack(spacing: 0) {
                self.topBar
                    .modifier(ViewHeightKey())
                    .onPreferenceChange(ViewHeightKey.self) { self.model.topBarHeight = $0 }
                self.content()
                    .modifier(ViewHeightKey())
                    .onPreferenceChange(ViewHeightKey.self) { self.contentHeight = $0 }
            }
            .background(
                Color.DefaultBackground
                    .cornerRadius(16, corners: .top)
                    .ignoresSafeArea(edges: .bottom)
            )
            .onAppear {
                DispatchQueue.main.async {
                    model.peekHeight = peekContentHeight + model.topBarHeight + 8
                    model.showPeeking()
                }
            }
            .offset(x: 0, y: getYOffset(outerGeometry))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        guard
                            (model.position == .top && value.translation.height > 0)
                                || (model.position == .peeking && value.translation.height < 0)
                        else {
                            return
                        }

                        if value.translation.height < 0 {
                            let minValue =
                                BottomSheetUX.minSpacing - contentHeight - model.topBarHeight
                                + model.peekHeight
                            self.model.deltaHeight = max(value.translation.height, minValue)
                        } else {
                            let maxValue =
                                outerGeometry.size.height - BottomSheetUX.minSpacing
                                - model.peekHeight
                            self.model.deltaHeight = min(value.translation.height, maxValue)
                        }
                    }
                    .onEnded { _ in
                        guard self.model.deltaHeight != 0 else {
                            return
                        }

                        var newPosition = self.model.position
                        if self.model.deltaHeight > BottomSheetUX.slideThreshold {
                            newPosition = .peeking
                        } else if self.model.deltaHeight < -BottomSheetUX.slideThreshold {
                            newPosition = .top
                        }
                        withAnimation(.easeOut(duration: BottomSheetUX.animationDuration)) {
                            self.model.position = newPosition
                            self.model.deltaHeight = 0
                        }
                    }
            )
            .accessibilityAction(.escape, model.showPeeking)
            .clipped()
            .shadow(radius: 2)
        }
    }
}
