// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

public struct CheckboxView: View {
    var checked: Bool
    
    public var body: some View {
        if checked {
            Symbol(decorative: .checkmarkCircleFill, size: 20)
                .foregroundColor(.blue)
        } else {
            Symbol(decorative: .circle, size: 20)
                .foregroundColor(.tertiaryLabel)
        }
    }
    
    public init(checked: Bool) {
        self.checked = checked
    }
}

struct CheckboxView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CheckboxView(checked: true)
            CheckboxView(checked: false)
        }
    }
}
