// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct ReaderModePopover: View {
    let disableReadingMode: () -> Void

    @EnvironmentObject var textSizeModel: TextSizeModel
    @EnvironmentObject var model: ReaderModeModel
    @EnvironmentObject var brightnessModel: BrightnessModel

    var body: some View {
        VStack {
            GroupedCell.Decoration {
                VStack(spacing: 0) {
                    TextSizeStepper(roundedCorners: .top, model: textSizeModel)

                    Color.groupedBackground.frame(height: 1)

                    GroupedCell {
                        HStack {
                            ReaderModeColorPicker(
                                theme: .light,
                                onSelect: { theme in
                                    model.changeTheme(to: theme)
                                }
                            )
                            .accessibilityLabel(
                                Text(
                                    "Light Theme",
                                    comment:
                                        "accessibility label for one type of themes for reader mode feature"
                                ))

                            Spacer()

                            ReaderModeColorPicker(
                                theme: .sepia,
                                onSelect: { theme in
                                    model.changeTheme(to: theme)
                                }
                            )
                            .accessibilityLabel(
                                Text(
                                    "Sepia Theme",
                                    comment:
                                        "accessibility label for one type of themes for reader mode feature"
                                ))

                            Spacer()

                            ReaderModeColorPicker(
                                theme: .dark,
                                onSelect: { theme in
                                    model.changeTheme(to: theme)
                                }
                            )
                            .accessibilityLabel(
                                Text(
                                    "Dark Theme",
                                    comment:
                                        "accessibility label for one type of themes for reader mode feature"
                                ))
                        }
                    }.accessibilityLabel(Text("Reading Mode Theme"))

                    Color.groupedBackground.frame(height: 1)

                    GroupedCell(
                        content: {
                            HStack {
                                OverlayStepperButton(
                                    action: brightnessModel.decrease,
                                    symbol: Symbol(decorative: .minus, style: .bodyLarge),
                                    foregroundColor: brightnessModel.canDecrease
                                        ? .label : .tertiaryLabel
                                )
                                .disabled(!brightnessModel.canDecrease)

                                Spacer()
                                brightnessModel.symbol
                                Spacer()

                                OverlayStepperButton(
                                    action: brightnessModel.increase,
                                    symbol: Symbol(decorative: .plus, style: .bodyLarge),
                                    foregroundColor: brightnessModel.canIncrease
                                        ? .label : .tertiaryLabel
                                )
                                .disabled(!brightnessModel.canIncrease)
                            }.padding(.horizontal, -GroupedCellUX.padding)
                        }, roundedCorners: .bottom
                    )
                    .buttonStyle(.tableCell)
                    .accessibilityElement(children: .ignore)
                    .modifier(
                        OverlayStepperAccessibilityModifier(
                            accessibilityLabel: "Screen Brightness",
                            increment: brightnessModel.increase,
                            decrement: brightnessModel.decrease))
                }
            }

            GroupedCell {
                Button {
                    disableReadingMode()
                } label: {
                    Text("Close Reading Mode")
                        .withFont(.bodyLarge)
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                        .frame(minWidth: 165)

                    Spacer()
                        .padding(.horizontal)

                    Symbol(decorative: .docPlaintext, style: .headingLarge)
                }
                .foregroundColor(.label)
                .accessibilityLabel(Text("Close Reading Mode"))
            }
        }
        .padding()
        .background(
            Color.groupedBackground
                .cornerRadius(GroupedCellUX.cornerRadius, corners: .top)
                .ignoresSafeArea()
        )
        .background(
            RoundedRectangle(cornerRadius: GroupedCellUX.cornerRadius)
                .fill(Color.black.opacity(0.12))
                .blur(radius: 16)
                .offset(y: 4)
        )
    }
}

struct ReaderModePopover_Previews: PreviewProvider {
    static var previews: some View {
        ReaderModePopover(disableReadingMode: {})
            .environmentObject(
                ReaderModeModel(
                    setReadingMode: { _ in }, tabManager: SceneDelegate.getTabManagerOrNil()!)
            )
            .environmentObject(BrightnessModel())
    }
}
