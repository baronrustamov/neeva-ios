// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation

class ReaderModeModel: ObservableObject {
    @Published private(set) var state: ReaderModeState = .unavailable
    @Published private(set) var style: ReaderModeStyle = ReaderModeStyle(
        theme: .light, fontType: .sansSerif)

    private let setReadingMode: (Bool) -> Void
    let tabManager: TabManager

    var delegate: ReaderModeDelegate?
    private(set) var isOriginalTabSecure: Bool = false

    fileprivate var isUsingUserDefinedColor = false

    func enableReadingMode() {
        isOriginalTabSecure = tabManager.selectedTab?.webView?.hasOnlySecureContent ?? false
        setReadingMode(true)
    }

    func disableReadingMode() {
        isOriginalTabSecure = false
        setReadingMode(false)
    }

    func changeTheme(to: ReaderModeTheme) {
        style.theme = to

        isUsingUserDefinedColor = true
        delegate?.readerMode(
            didConfigureStyle: style, isUsingUserDefinedColor: isUsingUserDefinedColor)
    }

    func applyTheme(contentScript: TabContentScript) {
        guard let readerMode = contentScript as? ReaderMode else { return }

        var style = Defaults[.readerModeStyle] ?? readerMode.defaultTheme
        style.ensurePreferredColorThemeIfNeeded()
        readerMode.style = style
    }

    func setReadingModeState(state: ReaderModeState) {
        if state == .available, let currentURL = tabManager.selectedTab?.url,
            ReaderModeBlocklist.isSiteBlocked(url: currentURL)
        {
            self.state = .unavailable
        } else {
            self.state = state
        }
    }

    init(setReadingMode: @escaping (Bool) -> Void, tabManager: TabManager) {
        self.setReadingMode = setReadingMode
        self.tabManager = tabManager
    }
}
