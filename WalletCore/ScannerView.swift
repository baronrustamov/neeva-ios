// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import CodeScanner
import Shared
import SwiftUI

public struct ScannerView: View {
    @Binding var showQRScanner: Bool
    @Binding var returnAddress: String
    let onComplete: () -> Void

    public init(
        showQRScanner: Binding<Bool>, returnAddress: Binding<String>,
        onComplete: @escaping () -> Void = {}
    ) {
        self._showQRScanner = showQRScanner
        self._returnAddress = returnAddress
        self.onComplete = onComplete
    }

    public var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { showQRScanner = false }) {
                    Symbol(.xmark, size: 20, weight: .semibold, label: "Close")
                        .foregroundColor(Color.ui.gray60)
                }
                .frame(width: 40, height: 40, alignment: .center)
            }
            .padding()
            Spacer()
            CodeScannerView(
                codeTypes: [.qr], simulatedData: "address placeholder", completion: onScan
            )
            .frame(maxHeight: 300)
            Text(verbatim: "Scan QR code")
            Spacer()
        }
        .padding()
    }

    func onScan(result: Result<ScanResult, ScanError>) {
        showQRScanner = false

        switch result {
        case .success(let result):
            let qrStr = result.string.components(separatedBy: ":")
            guard qrStr.count == 2 else { return }
            returnAddress = qrStr[1]
        case .failure(_):
            returnAddress = ""
        }

        onComplete()
    }
}
