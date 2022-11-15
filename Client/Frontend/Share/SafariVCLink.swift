// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SafariServices
import Shared
import SwiftUI

struct SafariVCLink: View {
    let title: LocalizedStringKey
    let url: URL

    private var _token: Any?
    var token: SFSafariViewController.PrewarmingToken? {
        _token as! SFSafariViewController.PrewarmingToken?
    }

    @State private var modal = ModalState()

    init(_ title: LocalizedStringKey, url: URL) {
        self.title = title
        self.url = url

        // Strictly an optimization, no need for a fallback on older versions
        _token = SFSafariViewController.prewarmConnections(to: [url])
    }

    var body: some View {
        Button {
            ClientLogger.shared.logCounter(
                .SafariVCLinkClick,
                attributes: [
                    ClientLogCounterAttribute(
                        key: LogConfig.Attribute.safariVCLinkURL, value: self.url.absoluteString
                    )
                ])

            modal.present()
        } label: {
            Text(title)
                .underline()
                .foregroundColor(.secondaryLabel)
        }.modal(state: $modal) {
            Safari(url: url)
        }
    }
}

private struct Safari: ViewControllerWrapper {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.barCollapsingEnabled = false
        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredControlTintColor = UIColor.ui.adaptive.blue
        return vc
    }

    func updateUIViewController(_ vc: SFSafariViewController, context: Context) {}
}
