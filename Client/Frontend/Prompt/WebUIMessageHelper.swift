import Defaults
import Shared
import WebKit

let messageHandlerName = "webui"

private enum WebUIMessageName: String {
    case showSignUp
    case unknown
}

private struct WebUIMessage {
    let id: String
    let name: WebUIMessageName
    let data: [String: Any]

    init(id: String, name: String, data: [String: Any]) {
        self.id = id
        self.name = .init(rawValue: name) ?? .unknown
        self.data = data
    }
}

class WebUIMessageHelper: TabContentScript {
    fileprivate weak var tab: Tab?
    fileprivate weak var webView: WKWebView?
    fileprivate weak var tabManager: TabManager?

    init(tab: Tab, webView: WKWebView, tabManager: TabManager) {
        self.tab = tab
        self.webView = webView
        self.tabManager = tabManager
    }

    static func name() -> String {
        return messageHandlerName
    }

    func scriptMessageHandlerName() -> String? {
        return messageHandlerName
    }

    func userContentController(didReceiveScriptMessage message: WKScriptMessage) {
        let frameOrigin = message.frameInfo.securityOrigin

        if frameOrigin.host != NeevaConstants.appHost {
            return
        }

        guard let result = message.body as? [String: Any],
            let id = result["id"] as? String,
            let name = result["name"] as? String,
            let data = result["data"] as? [String: Any]
        else { return }

        let tourStep = TourStep(rawValue: name) ?? .unknown
        // only show notification permission prompt after user went through the first run flow
        if (tourStep == .skipTour || tourStep == .completeTour) && Defaults[.introSeen] {
            handleShouldShowNotificationPrompt(id: id, tourStep: tourStep)
        }

        let webuiMessage = WebUIMessage(id: id, name: name, data: data)

        handleWebUIMessage(webuiMessage)
    }

    fileprivate func handleWebUIMessage(_ message: WebUIMessage) {
        let bvc = SceneDelegate.getBVC(with: tabManager?.scene)

        switch message.name {
        case .showSignUp:
            if let source = message.data["source"] as? String {
                switch source {
                case "previewPreferredProvider":
                    ClientLogger.shared.logCounter(
                        .PreviewPreferredProviderSignIn,
                        attributes: EnvironmentHelper.shared.getFirstRunAttributes())
                default:
                    break
                }
            }

            bvc.presentIntroViewController(true)
        default:
            break
        }
    }

    func handleShouldShowNotificationPrompt(id: String, tourStep: TourStep) {
        let bvc = SceneDelegate.getBVC(with: tabManager?.scene)
        NotificationPermissionHelper.shared.didAlreadyRequestPermission { requested in
            if requested {
                return
            }
            ClientLogger.shared.logCounter(
                .ShowNotificationPrompt,
                attributes: [
                    ClientLogCounterAttribute(
                        key: LogConfig.NotificationAttribute.notificationPromptCallSite,
                        value: tourStep.rawValue)
                ]
            )

            bvc.overlayManager.showAsModalOverlaySheet(
                style: OverlayStyle(
                    showTitle: false,
                    backgroundColor: .systemBackground)
            ) {
                NotificationPromptViewOverlayContent()
            } onDismiss: {
                ClientLogger.shared.logCounter(.NotificationPromptSkip)
            }
        }
    }

    func connectedTabChanged(_ tab: Tab) {
        self.tab = tab
    }
}
