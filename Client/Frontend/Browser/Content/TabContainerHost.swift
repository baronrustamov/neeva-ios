// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import Shared
import Storage
import SwiftUI

enum ContentUIType: Equatable {
    case webPage(WKWebView)
    case zeroQuery
    case suggestions
    case blank
}

enum ContentUIVisibilityEvent {
    case showZeroQuery(isIncognito: Bool, isLazyTab: Bool, ZeroQueryOpenedLocation?)
    case hideZeroQuery
    case showSuggestions
    case hideSuggestions
}

class TabContainerModel: ObservableObject {
    /// Holds the current webpage's WebView, so that when the state changes to be other content, we don't lose it.
    @Published private(set) var webContainerType: ContentUIType {
        didSet {
            switch currentContentUI {
            case .webPage:
                currentContentUI = webContainerType
            case .blank:
                currentContentUI = webContainerType
            default:
                return
            }
        }
    }
    /// Current content UI that is showing
    @Published private(set) var currentContentUI: ContentUIType

    private var subscription: AnyCancellable? = nil

    private let zeroQueryModel: ZeroQueryModel
    let tabCardModel: TabCardModel
    private let overlayManager: OverlayManager

    init(bvc: BrowserViewController) {
        let tabManager = bvc.tabManager
        let webView = tabManager.selectedTab?.webView
        let type = webView.map(ContentUIType.webPage) ?? Self.defaultType

        self.webContainerType = type
        self.currentContentUI = type
        self.zeroQueryModel = bvc.zeroQueryModel
        self.tabCardModel = bvc.tabCardModel
        self.overlayManager = bvc.overlayManager

        self.subscription = tabManager.selectedTabWebViewPublisher.sink { [weak self] webView in
            guard let self = self else { return }
            guard let webView = webView else {
                self.webContainerType = .blank
                return
            }

            self.webContainerType = .webPage(webView)
        }
    }

    static var defaultType: ContentUIType {
        // TODO(darin): We should get rid of the notion of .blank. We should be showing the empty
        // card grid in this case instead.
        !Defaults[.didFirstNavigation] && NeevaConstants.currentTarget != .xyz
            ? .zeroQuery : .blank
    }

    func updateContent(_ event: ContentUIVisibilityEvent) {
        switch event {
        case .showZeroQuery(let isIncognito, let isLazyTab, let openedFrom):
            currentContentUI = .zeroQuery
            zeroQueryModel.isIncognito = isIncognito
            zeroQueryModel.isLazyTab = isLazyTab
            zeroQueryModel.openedFrom = openedFrom

            overlayManager.hideCurrentOverlay(ofPriorities: [.modal, .fullScreen])

            if openedFrom == .newTabButton {
                zeroQueryModel.targetTab = .newTab
            }
        case .showSuggestions:
            overlayManager.hideCurrentOverlay(ofPriorities: [.modal, .fullScreen])

            if case .zeroQuery = currentContentUI {
                currentContentUI = .suggestions
            }
        case .hideSuggestions:
            if case .suggestions = currentContentUI {
                currentContentUI = .zeroQuery
                zeroQueryModel.targetTab = .defaultValue
            }
        case .hideZeroQuery:
            currentContentUI = webContainerType
        }
    }
}

struct TabContainerContent: View {
    @ObservedObject var model: TabContainerModel
    let bvc: BrowserViewController
    let zeroQueryModel: ZeroQueryModel
    let suggestionModel: SuggestionModel
    let spaceContentSheetModel: SpaceContentSheetModel?

    @EnvironmentObject private var chromeModel: TabChromeModel
    @EnvironmentObject private var incognitoModel: IncognitoModel
    @EnvironmentObject private var scrollingControlModel: ScrollingControlModel
    @EnvironmentObject private var simulatedSwipeModel: SimulatedSwipeModel

    var yOffset: CGFloat {
        return scrollingControlModel.footerBottomOffset
    }

    var webViewOffsetY: CGFloat {
        var offsetY = scrollingControlModel.headerTopOffset
        // Workaround a SwiftUI quirk. When the offset and padding negate one another
        // exactly, the container view will appear to snap up by an amount equal to
        // the padding. To avoid this, we apply the following hack :-/
        if offsetY <= -scrollingControlModel.headerHeight {
            offsetY = -scrollingControlModel.headerHeight + 0.1
        }
        return offsetY
    }

    var webViewBottomPadding: CGFloat {
        var padding = scrollingControlModel.headerTopOffset
        if !chromeModel.inlineToolbar {
            padding -= scrollingControlModel.footerBottomOffset
        }
        return padding
    }

    var body: some View {
        ZStack {
            // MARK: Page Content
            switch model.currentContentUI {
            case .webPage(let currentWebView):
                ZStack {
                    WebViewContainer(webView: currentWebView)
                        .ignoresSafeArea(.container)
                        .onTapGesture {
                            UIMenuController.shared.hideMenu()
                        }
                        .offset(x: simulatedSwipeModel.contentOffset / 2.5, y: webViewOffsetY)
                        .padding(.bottom, webViewBottomPadding)

                    GeometryReader { geom in
                        SimulatedSwipeViewRepresentable(
                            model: simulatedSwipeModel, superview: bvc.view.superview
                        )
                        .padding(.bottom, webViewBottomPadding)
                        .opacity(!simulatedSwipeModel.hidden ? 1 : 0)
                        .frame(width: geom.size.width + SwipeUX.EdgeWidth)
                        // When in landscape mode, the SimulatedSwipeView would clip
                        // some of the content. This was caused by the SafeArea pushing the view
                        // over the content. Subtracting the horizontal SafeArea from the
                        // offset would prevent this, but would overshoot, stopping users from being able
                        // to swipe back on the view. Diving one of the edges by 4 seemed to create a goldilocks
                        // amount of less offset but just enough to still be interactable.
                        .offset(
                            x: -geom.size.width - geom.safeAreaInsets.leading
                                - (geom.safeAreaInsets.trailing / 4)
                                + simulatedSwipeModel.overlayOffset,
                            y: webViewOffsetY
                        )
                    }

                    if FeatureFlag[.cardStrip] && !FeatureFlag[.topCardStrip]
                        && UIDevice.current.useTabletInterface
                    {
                        GeometryReader { geo in
                            VStack {
                                Spacer()
                                CardStripContent(bvc: bvc, width: geo.size.width)
                            }
                        }
                    }

                    if FeatureFlag[.spaceComments] {
                        SpaceContentSheet(
                            model: spaceContentSheetModel!,
                            yOffset: yOffset,
                            footerHeight: scrollingControlModel.footerHeight
                        )
                        .environment(
                            \.onOpenURLForSpace,
                            { bvc.tabManager.createOrSwitchToTabForSpace(for: $0, spaceID: $1) }
                        )
                    }
                }
            case .blank:
                ZeroQueryContent(model: zeroQueryModel)
            default:
                Color.clear
            }

            // MARK: Overlays
            if model.currentContentUI == .zeroQuery || model.currentContentUI == .suggestions {
                ZStack {
                    switch model.currentContentUI {
                    case .zeroQuery:
                        ZeroQueryContent(model: zeroQueryModel)
                            .transition(.identity)
                    case .suggestions:
                        SuggestionsContent(suggestionModel: suggestionModel)
                            .transition(.identity)
                            .environment(\.onOpenURL) { url in
                                let bvc = zeroQueryModel.bvc
                                guard let tab = bvc.tabManager.selectedTab else { return }
                                bvc.finishEditingAndSubmit(
                                    url, visitType: VisitType.typed, forTab: tab)
                            }.environment(\.setSearchInput) { suggestion in
                                suggestionModel.queryModel.value = suggestion
                            }.environment(\.onSigninOrJoinNeeva) {
                                ClientLogger.shared.logCounter(
                                    .SuggestionErrorSigninOrJoinNeeva,
                                    attributes: EnvironmentHelper.shared.getFirstRunAttributes())
                                let bvc = zeroQueryModel.bvc
                                bvc.chromeModel.setEditingLocation(to: false)
                                bvc.presentIntroViewController(
                                    true,
                                    onDismiss: {
                                        bvc.hideCardGrid(withAnimation: true)
                                    }
                                )
                            }
                    default:
                        EmptyView()
                    }
                }
                .transition(.pageOverlay)
            }
        }.useEffect(deps: model.currentContentUI) { _ in
            zeroQueryModel.profile.panelDataObservers.activityStream.refreshIfNeeded(
                forceTopSites: true)
            self.zeroQueryModel.updateSuggestedSites()
        }.animation(.spring(), value: model.currentContentUI)
    }
}

// TODO: This class is only used by tests. We should be able to remove it.
class TabContainerHost: UIHostingController<TabContainerContent> {
    init(model: TabContainerModel, bvc: BrowserViewController) {
        super.init(
            rootView: TabContainerContent(
                model: model,
                bvc: bvc,
                zeroQueryModel: bvc.zeroQueryModel,
                suggestionModel: bvc.suggestionModel,
                spaceContentSheetModel: FeatureFlag[.spaceComments]
                    ? SpaceContentSheetModel(
                        tabManager: bvc.tabManager,
                        spaceModel: bvc.gridModel.spaceCardModel) : nil)
        )
    }

    @objc required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
