// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import CodeScanner
import Shared
import SwiftUI

struct ScannerCodeView: View {
    @EnvironmentObject var model: IntroViewModel

    var body: some View {
        ZStack(alignment: .topTrailing) {
            CodeScannerView(
                codeTypes: [.qr],
                scanMode: .continuous,
                scanInterval: 3.0,
                showViewfinder: true,
                shouldVibrateOnSuccess: true,
                completion: handleScan
            )
            VStack(alignment: .trailing) {
                CloseButton(action: {
                    model.showQRScanner = false
                    model.overlayManager.hideCurrentOverlay()
                })
                .padding(.trailing, 20)
                .padding(.top, 40)
                .background(Color.clear)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            VStack(alignment: .center) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundColor(.white)
                        .opacity(50)

                    Text(model.qrcodeInstruction)
                        .withFont(.labelLarge)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.vertical)
                }
                .frame(height: 80)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 40)
            .padding(.horizontal, 20)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let result):
            guard let url = URL(string: result.string),
                let delegate = SceneDelegate.getCurrentSceneDelegateOrNil()
            else { return }
            if !delegate.checkForSignInToken(in: url) {
                model.qrcodeInstruction = "Invalid QR Code. Please try again!"
            } else {
                model.showQRScanner = false
                model.toastViewManager.makeToast(
                    text: "Sign in successfully! Please close the QR Code."
                )
            }
        case .failure(let error):
            switch error {
            case .badInput:
                DispatchQueue.main.async {
                    model.qrcodeInstruction = "Please allow us to use the camera."
                }
            case .badOutput:
                DispatchQueue.main.async {
                    model.qrcodeInstruction = "Cannot detect QR Code. Please try again!"
                }
            case .initError:
                DispatchQueue.main.async {
                    model.qrcodeInstruction = "\(error.localizedDescription)"
                }
            }
        }
    }
}

struct ScannerCodeView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerCodeView()
    }
}
