/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Defaults
import Foundation
import Shared
import SwiftUI
import SwiftyJSON
import WebKit

extension Defaults.Keys {
    static let readerModeStyle = Defaults.Key<ReaderModeStyle?>(
        "profile.readermode.style",
        default: nil)
}

enum ReaderModeMessageType: String {
    case stateChange = "ReaderModeStateChange"
    case pageEvent = "ReaderPageEvent"
    case contentParsed = "ReaderContentParsed"
}

enum ReaderPageEvent: String {
    case pageShow = "PageShow"
}

enum ReaderModeState: String {
    case available = "Available"
    case unavailable = "Unavailable"
    case active = "Active"
}

enum ReaderModeTheme: String, Codable {
    case light = "light"
    case dark = "dark"
    case sepia = "sepia"

    var color: Color {
        switch self {
        case .light:
            return .white
        case .dark:
            return Color(red: 42 / 255, green: 41 / 255, blue: 46 / 255, opacity: 1)
        case .sepia:
            return Color(red: 238 / 255, green: 228 / 255, blue: 219 / 255, opacity: 1)
        }
    }

    static func preferredTheme(for theme: ReaderModeTheme? = nil) -> ReaderModeTheme {
        // If there is no reader theme provided than we default to light theme
        let readerTheme = theme ?? .light
        // Get current Neeva theme (Dark vs Normal)
        // Normal means light theme. This is the overall theme used
        // by Neeva iOS app
        let appWideTheme = SceneDelegate.getKeyWindow(for: nil).traitCollection.userInterfaceStyle
        // We check for 3 basic themes we have Light / Dark / Sepia
        // Theme: Dark - app-wide dark overrides all
        if appWideTheme == .dark {
            return .dark
            // Theme: Sepia - special case for when the theme is sepia.
            // For this we only check the them supplied and not the app wide theme
        } else if readerTheme == .sepia {
            return .sepia
        }
        // Theme: Light - Default case for when there is no theme supplied i.e. nil and we revert to light
        return readerTheme
    }
}

private struct FontFamily {
    static let serifFamily = [ReaderModeFontType.serif, ReaderModeFontType.serifBold]
    static let sansFamily = [ReaderModeFontType.sansSerif, ReaderModeFontType.sansSerifBold]
    static let families = [serifFamily, sansFamily]
}

enum ReaderModeFontType: String, Codable {
    case serif = "serif"
    case serifBold = "serif-bold"
    case sansSerif = "sans-serif"
    case sansSerifBold = "sans-serif-bold"

    init(type: String) {
        let font = ReaderModeFontType(rawValue: type)
        let isBoldFontEnabled = UIAccessibility.isBoldTextEnabled

        switch font {
        case .serif,
            .serifBold:
            self = isBoldFontEnabled ? .serifBold : .serif
        case .sansSerif,
            .sansSerifBold:
            self = isBoldFontEnabled ? .sansSerifBold : .sansSerif
        case .none:
            self = .sansSerif
        }
    }

    func isSameFamily(_ font: ReaderModeFontType) -> Bool {
        return !FontFamily.families.filter { $0.contains(font) && $0.contains(self) }.isEmpty
    }
}

struct ReaderModeStyle: Codable {
    var theme: ReaderModeTheme
    var fontType: ReaderModeFontType

    /// Encode the style to a JSON dictionary that can be passed to ReaderMode.js
    func encode() -> String {
        return JSON([
            "theme": theme.rawValue, "fontType": fontType.rawValue,
        ]).stringify() ?? ""
    }

    mutating func ensurePreferredColorThemeIfNeeded() {
        self.theme = ReaderModeTheme.preferredTheme(for: self.theme)
    }
}

/// This struct captures the response from the Readability.js code.
struct ReadabilityResult {
    var domain = ""
    var url = ""
    var content = ""
    var title = ""
    var credits = ""

    init?(object: AnyObject?) {
        if let dict = object as? NSDictionary {
            if let uri = dict["uri"] as? NSDictionary {
                if let url = uri["spec"] as? String {
                    self.url = url
                }
                if let host = uri["host"] as? String {
                    self.domain = host
                }
            }
            if let content = dict["content"] as? String {
                self.content = content
            }
            if let title = dict["title"] as? String {
                self.title = title
            }
            if let credits = dict["byline"] as? String {
                self.credits = credits
            }
        } else {
            return nil
        }
    }

    /// Initialize from a JSON encoded string
    init?(string: String) {
        let object = JSON(parseJSON: string)
        let domain = object["domain"].string
        let url = object["url"].string
        let content = object["content"].string
        let title = object["title"].string
        let credits = object["credits"].string

        if domain == nil || url == nil || content == nil || title == nil || credits == nil {
            return nil
        }

        self.domain = domain!
        self.url = url!
        self.content = content!
        self.title = title!
        self.credits = credits!
    }

    /// Encode to a dictionary, which can then for example be json encoded
    func encode() -> [String: Any] {
        return [
            "domain": domain, "url": url, "content": content, "title": title, "credits": credits,
        ]
    }

    /// Encode to a JSON encoded string
    func encode() -> String {
        let dict: [String: Any] = self.encode()
        return JSON(dict).stringify()!
    }
}

/// Delegate that contains callbacks that we have added on top of the built-in WKWebViewDelegate
protocol ReaderModeDelegate {
    func readerMode(didChangeReaderModeState state: ReaderModeState, forTab tab: Tab)
    func readerMode(didDisplayReaderizedContentForTab tab: Tab)
    func readerMode(
        didParseReadabilityResult readabilityResult: ReadabilityResult,
        forTab tab: Tab)
    func readerMode(
        didConfigureStyle style: ReaderModeStyle,
        isUsingUserDefinedColor: Bool)
}

let ReaderModeNamespace = "window.__firefox__.reader"

class ReaderMode: TabContentScript {
    var delegate: ReaderModeDelegate?

    fileprivate weak var tab: Tab?
    var state = ReaderModeState.unavailable

    class func name() -> String {
        return "ReaderMode"
    }

    required init(tab: Tab) {
        self.tab = tab
    }

    required init() {
        self.tab = nil
    }

    func scriptMessageHandlerName() -> String? {
        return "readerModeMessageHandler"
    }

    fileprivate func handleReaderPageEvent(_ readerPageEvent: ReaderPageEvent) {
        switch readerPageEvent {
        case .pageShow:
            if let tab = tab {
                delegate?.readerMode(didDisplayReaderizedContentForTab: tab)
            }
        }
    }

    fileprivate func handleReaderModeStateChange(_ state: ReaderModeState) {
        self.state = state
        guard let tab = tab else {
            return
        }
        delegate?.readerMode(didChangeReaderModeState: state, forTab: tab)
    }

    fileprivate func handleReaderContentParsed(_ readabilityResult: ReadabilityResult) {
        guard let tab = tab else {
            return
        }
        delegate?.readerMode(didParseReadabilityResult: readabilityResult, forTab: tab)
    }

    func userContentController(didReceiveScriptMessage message: WKScriptMessage) {
        guard let msg = message.body as? [String: Any], let type = msg["Type"] as? String,
            let messageType = ReaderModeMessageType(rawValue: type)
        else { return }

        switch messageType {
        case .pageEvent:
            if let readerPageEvent = ReaderPageEvent(rawValue: msg["Value"] as? String ?? "Invalid")
            {
                handleReaderPageEvent(readerPageEvent)
            }
        case .stateChange:
            if let readerModeState = ReaderModeState(rawValue: msg["Value"] as? String ?? "Invalid")
            {
                handleReaderModeStateChange(readerModeState)
            }
        case .contentParsed:
            if let readabilityResult = ReadabilityResult(object: msg["Value"] as AnyObject?) {
                handleReaderContentParsed(readabilityResult)
            }
        }
    }

    func connectedTabChanged(_ tab: Tab) {
        self.tab = tab
    }

    var defaultTheme: ReaderModeStyle {
        if let defaultValue = Defaults.Keys.readerModeStyle.defaultValue {
            return defaultValue
        } else if UITraitCollection.current.userInterfaceStyle == .dark {
            return ReaderModeStyle(
                theme: .dark, fontType: .sansSerif)
        }

        return ReaderModeStyle(
            theme: .light, fontType: .sansSerif)
    }

    lazy var style: ReaderModeStyle = {
        defaultTheme
    }()
    {
        didSet {
            if state == ReaderModeState.active {
                tab?.webView?.evaluateJavascriptInDefaultContentWorld(
                    "\(ReaderModeNamespace).setStyle(\(style.encode()))"
                ) { _, _ in
                    return
                }
            }
        }
    }
}
