// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import CodeScanner
import Shared
import SwiftUI

struct WelcomeFlowSignInQRCodeView: View {
    @ObservedObject var model: WelcomeFlowModel

    @State var error = ""
    @State var showError = false

    var body: some View {
        VStack {
            Spacer()

            CodeScannerView(codeTypes: [.qr]) { result in
                model.authStore.signInwithQRCode(
                    result,
                    onError: { message in
                        self.error = message
                        self.showError = true
                    },
                    onSuccess: {
                        model.clearPreviousScreens()
                        model.changeScreenTo(.defaultBrowser)
                    })
            }

            Spacer()
        }
        .alert(isPresented: self.$showError) {
            Alert(
                title: Text("Error"),
                message: Text(self.error),
                dismissButton: .default(
                    Text("OK"), action: { self.showError = false }
                )
            )
        }
        .onAppear {
            model.logCounter(.ScreenImpression)
        }
    }
}
