import WebKit

public struct Step {
    var id: String
    var stepName: TourStep
}

public enum NextAction: String {
    case stopAction = "stopAction"
    case resumeAction = "resumeAction"
}

public enum TapTarget: String {
    case neevaMenu = "neevaMenu"
    case spaceMenu = "spaceMenu"
    case settingMenu = "settingMenu"
    case feedbackMenu = "feedbackMenu"
    case connectedApps = "connectedApps"
}

public enum TourStep: String {
    case promptSpaceInNeevaMenu = "create_space"
    case promptFeedbackInNeevaMenu = "send_feedback"
    case promptSettingsInNeevaMenu = "connect_personal_account"
    case openFeedbackPanelWithInputFieldHighlight = "open_feedback_panel_with_input_field_highlight"
    case earlyExit = "early_exit"
    case skipTour = "skip_tour"
    case completeTour = "complete_tour"
    case unknown = ""

    func getSubSteps() -> [TapTarget] {
        switch self {
        case .promptSpaceInNeevaMenu:
            return [.neevaMenu, .spaceMenu]
        case .promptFeedbackInNeevaMenu:
            return [.neevaMenu, .feedbackMenu]
        case .promptSettingsInNeevaMenu:
            return [.neevaMenu, .settingMenu, .connectedApps]
        default:
            return []
        }
    }
}

public class TourManager {
    public static let shared = TourManager()

    public var activeStep: Step?
    public var lastTap: TapTarget?
    public var subStepIdx: Int = 0
    private var webView: WKWebView?

    public func setActiveStep(id: String, stepName: TourStep, webView: WKWebView?) {
        self.activeStep = Step(id: id, stepName: stepName)
        self.webView = webView
    }

    public func hasActiveStep() -> Bool {
        if self.activeStep != nil {
            return true
        }
        return false
    }

    public func getActiveStepID() -> String {
        return activeStep?.id ?? ""
    }

    public func getActiveStepName() -> TourStep {
        activeStep?.stepName ?? .unknown
    }

    public func isCurrentStep(with step: TourStep) -> Bool {
        activeStep?.stepName == step
    }

    public func reset() {
        activeStep = nil
        subStepIdx = 0
        lastTap = nil
    }

    public func nextSubStep() {
        subStepIdx += 1
    }

    public func setLastTap(_ tap: TapTarget) {
        lastTap = tap
    }

    public func isLastTapAtTarget() -> Bool {
        if self.activeStep == nil || lastTap == nil {
            return false
        }

        let subSteps = activeStep?.stepName.getSubSteps()
        let subStepsLength = subSteps?.count ?? Int.max

        if subSteps == nil || subStepsLength == 0 || (subStepIdx > subStepsLength - 1) {
            return false
        }

        if subSteps?[subStepIdx] == lastTap {
            subStepIdx += 1
            return true
        }
        return false
    }

    public func responseMessage(for activeStepName: TourStep, exit: Bool = false) {
        if isCurrentStep(with: activeStepName) {
            let data = exit ? "exit" : "received"
            self.webView?.evaluateJavaScript(
                "window.__neevaNativeBridge.messaging.reply('\(getActiveStepID())', {'name':{ 'data': '\(data)' }})"
            ) { (_, error) in
                if error != nil {
                    print("evaluateJavaScript Error : \(String(describing: error))")
                }
            }
            reset()
        }
    }

    public func notifyCurrentViewClose() {
        if !isLastTapAtTarget() {
            responseMessage(for: getActiveStepName(), exit: true)
        }
    }

    @discardableResult public func userReachedStep(
        step stepName: TourStep? = nil, tapTarget tap: TapTarget? = nil
    ) -> NextAction {
        if !hasActiveStep() {
            return .resumeAction
        }

        if let currentTap = tap {
            setLastTap(currentTap)

            if stepName == nil {
                return .resumeAction
            }
        }

        if let currentStep = stepName, isCurrentStep(with: currentStep) {
            responseMessage(for: currentStep)
            return .stopAction
        } else {
            return .resumeAction
        }
    }
}
