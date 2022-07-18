// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

public struct CheckboxView<Label: View>: View {
    @Binding var checked: Bool
    var label: Label

    public var body: some View {
        Button {
            checked.toggle()
        } label: {
            HStack {
                if checked {
                    Symbol(decorative: .checkmarkCircleFill, size: 20)
                        .foregroundColor(.blue)
                } else {
                    Symbol(decorative: .circle, size: 20)
                        .foregroundColor(.tertiaryLabel)
                }

                if let label = label {
                    label
                }
            }
        }
    }

    public init(checked: Binding<Bool>, @ViewBuilder label: @escaping () -> Label) {
        self._checked = checked
        self.label = label()
    }
}

struct CheckboxView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CheckboxView(checked: .constant(true)) {
                Text("Label")
            }

            CheckboxView(checked: .constant(false)) {
                Text("Label")
            }
        }
    }
}
