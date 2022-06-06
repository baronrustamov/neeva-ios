/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import Storage
import UIKit
import ViewInspector
import XCTest

@testable import Client

extension TabContainerContent: Inspectable {}
extension WebViewContainer: Inspectable {}
extension ZeroQueryContent: Inspectable {}
extension SuggestionsContent: Inspectable {}
extension ZeroQueryView: Inspectable {}
class ZeroQueryTests: XCTestCase {
    var profile: MockProfile!
    var zQM: ZeroQueryModel!
    var ssm = SuggestedSearchesModel()
    var sQM = SearchQueryModel()
    var suggestionsModel: SuggestionModel!
    var tabManager: TabManager!
    var tabContainerModel: TabContainerModel!
    var tabContainerHost: TabContainerHost!

    override func setUp() {
        super.setUp()
        let bvc = SceneDelegate.getBVC(for: nil)
        self.profile = MockProfile()
        self.suggestionsModel = SuggestionModel(bvc: bvc, profile: profile, queryModel: sQM)
        self.zQM = bvc.zeroQueryModel
        self.tabManager = TabManager(profile: profile, imageStore: nil)
        self.tabContainerModel = TabContainerModel(bvc: bvc)
        self.tabContainerHost = TabContainerHost(model: self.tabContainerModel, bvc: bvc)
    }

    override func tearDown() {
        self.profile._shutdown()
        super.tearDown()
    }

    func testZeroQueryInsideContentHost() throws {
        try skipTest(issue: 2522, "fails with new content layout, disabling until that stabilizes")
        let tab = tabManager.addTab()
        tab.loadRequest(URLRequest(url: .aboutBlank))
        tabManager.selectTab(tab, notify: true)
        waitForCondition(condition: {
            switch tabContainerModel.currentContentUI {
            case .webPage:
                return true
            default:
                return false
            }
        })
        try assertTabContentOnlyContainsWebContainer()

        tabContainerModel.updateContent(
            .showZeroQuery(isIncognito: false, isLazyTab: true, .tabTray))
        try assertTabContentOnlyContainsZeroQuery()

        tabContainerModel.updateContent(.hideZeroQuery)
        try assertTabContentOnlyContainsWebContainer()
    }

    func testLazyTabCancel() throws {
        try skipTest(issue: 2522, "fails with new content layout, disabling until that stabilizes")
        let tab = tabManager.addTab()
        tab.loadRequest(URLRequest(url: .aboutBlank))
        tabManager.selectTab(tab, notify: true)
        waitForCondition(condition: {
            switch tabContainerModel.currentContentUI {
            case .webPage:
                return true
            default:
                return false
            }
        })
        try assertTabContentOnlyContainsWebContainer()

        tabContainerModel.updateContent(
            .showZeroQuery(isIncognito: false, isLazyTab: true, .tabTray))
        try assertTabContentOnlyContainsZeroQuery()

        tabContainerModel.updateContent(.hideZeroQuery)
        try assertTabContentOnlyContainsWebContainer()
    }

    func testSuggestionUI() throws {
        try skipTest(issue: 2522, "fails with new content layout, disabling until that stabilizes")
        let tab = tabManager.addTab()
        tab.loadRequest(URLRequest(url: .aboutBlank))
        tabManager.selectTab(tab, notify: true)
        waitForCondition(condition: {
            switch tabContainerModel.currentContentUI {
            case .webPage:
                return true
            default:
                return false
            }
        })
        try assertTabContentOnlyContainsWebContainer()

        tabContainerModel.updateContent(.showSuggestions)
        try assertTabContentOnlyContainsWebContainer()

        tabContainerModel.updateContent(
            .showZeroQuery(isIncognito: false, isLazyTab: true, .tabTray))
        try assertTabContentOnlyContainsZeroQuery()

        tabContainerModel.updateContent(.showSuggestions)
        try assertTabContentOnlyContainsSuggestions()

        tabContainerModel.updateContent(.hideSuggestions)
        try assertTabContentOnlyContainsZeroQuery()

        tabContainerModel.updateContent(.hideZeroQuery)
        try assertTabContentOnlyContainsWebContainer()
    }

    func assertTabContentOnlyContainsZeroQuery() throws {
        let group = try tabContainerHost.rootView.inspect().find(ViewType.Group.self)
        let content = try group.view(ZeroQueryContent.self, 0).actualView()
        XCTAssertNotNil(content)
        XCTAssertEqual(group.count, 1)
    }

    func assertTabContentOnlyContainsSuggestions() throws {
        let group = try tabContainerHost.rootView.inspect().find(ViewType.Group.self)
        let content = try group.view(SuggestionsContent.self, 0).actualView()
        XCTAssertNotNil(content)
        XCTAssertEqual(group.count, 1)
    }

    func assertTabContentOnlyContainsWebContainer() throws {
        let group = try tabContainerHost.rootView.inspect().find(ViewType.Group.self)
        XCTAssertEqual(group.count, 1)
    }

    func testDeletionOfAllDefaultSites() {
        let defaultSites = TopSitesHandler.defaultTopSites()
        defaultSites.forEach({
            zQM.hideURLFromTopSites($0)
        })

        let newSites = TopSitesHandler.defaultTopSites()
        XCTAssertTrue(newSites.isEmpty)
    }

    func testZeroQueryModelSuggestedSite() {
        let getSitesExpectation = expectation(description: "reload profile")

        let mostFrecentSite =
            Site(
                url: "https://www.neeva.com/search?q=mostFrecentSite&src=nvobar",
                title: "mostFrecentSite")
        let mostFrecentSiteVisit1 = SiteVisit(
            site: mostFrecentSite,
            date: Date.nowMicroseconds() + 1000,
            type: VisitType.link)
        let mostFrecentSiteVisit2 = SiteVisit(
            site: mostFrecentSite,
            date: Date.nowMicroseconds() + 2000,
            type: VisitType.link)
        let mostFrecentSiteVisit3 = SiteVisit(
            site: mostFrecentSite,
            date: Date.nowMicroseconds() + 3000,
            type: VisitType.link)

        let mostRecentSite =
            Site(
                url: "https://www.neeva.com/search?q=mostRecentSite&src=nvobar",
                title: "mostRecentSite")
        let mostRecentSiteVisit = SiteVisit(
            site: mostRecentSite,
            date: Date.nowMicroseconds() + 6000,
            type: VisitType.link)

        let secondMostRecentSite =
            Site(
                url: "https://www.neeva.com/search?q=secondMostRecentSite&src=nvobar",
                title: "secondMostRecentSite")
        let secondMostRecentSiteVisit = SiteVisit(
            site: secondMostRecentSite,
            date: Date.nowMicroseconds() + 5000,
            type: VisitType.link)

        let thirdMostRecentSite =
            Site(
                url: "https://www.neeva.com/search?q=thirdMostRecentSite&src=nvobar",
                title: "thirdMostRecentSite")
        let thirdMostRecentSiteVisit = SiteVisit(
            site: thirdMostRecentSite,
            date: Date.nowMicroseconds() + 4000,
            type: VisitType.link)

        let thirdMostRecentSiteDuplicate =
            Site(
                url: "https://www.neeva.com/search?q=thirdMostRecentSite&src=nvobar2",
                title: "thirdMostRecentSite")
        let thirdMostRecentSiteDuplicateVisit = SiteVisit(
            site: thirdMostRecentSiteDuplicate,
            date: Date.nowMicroseconds() + 3500,
            type: VisitType.link)

        let expectation = self.expectation(description: "First.")
        func done() -> Success {
            expectation.fulfill()
            return succeed()
        }
        profile.history.clearHistory()
            >>> { self.profile.history.addLocalVisit(secondMostRecentSiteVisit) }
            >>> { self.profile.history.addLocalVisit(mostRecentSiteVisit) }
            >>> { self.profile.history.addLocalVisit(mostFrecentSiteVisit1) }
            >>> { self.profile.history.addLocalVisit(thirdMostRecentSiteVisit) }
            >>> { self.profile.history.addLocalVisit(mostFrecentSiteVisit2) }
            >>> { self.profile.history.addLocalVisit(mostFrecentSiteVisit3) }
            >>> { self.profile.history.addLocalVisit(thirdMostRecentSiteDuplicateVisit) }
            >>> { done() }

        let _ = XCTWaiter().wait(for: [expectation], timeout: 100)

        ssm.reload(from: profile) {
            XCTAssertEqual(self.ssm.suggestions.count, 7)  // 3 at the end are example queries
            XCTAssertEqual(
                self.ssm.suggestions[0].site.url.absoluteURL,
                mostFrecentSite.url.absoluteURL)
            XCTAssertEqual(
                self.ssm.suggestions[1].site.url.absoluteURL,
                mostRecentSite.url.absoluteURL)
            XCTAssertEqual(
                self.ssm.suggestions[2].site.url.absoluteURL,
                secondMostRecentSite.url.absoluteURL)
            XCTAssertEqual(
                self.ssm.suggestions[3].site.url.absoluteURL,
                thirdMostRecentSite.url.absoluteURL)
            getSitesExpectation.fulfill()
        }

        let _ = XCTWaiter().wait(for: [getSitesExpectation], timeout: 100)
    }
}

private class MockTopSitesHistory: MockableHistory {
    let mockTopSites: [Site]

    init(sites: [Site]) {
        mockTopSites = sites
    }

    override func getTopSitesWithLimit(_ limit: Int) -> Deferred<Maybe<Cursor<Site?>>> {
        return deferMaybe(ArrayCursor(data: mockTopSites))
    }

    override func getPinnedTopSites() -> Deferred<Maybe<Cursor<Site?>>> {
        return deferMaybe(ArrayCursor(data: []))
    }

    override func updateTopSitesCacheIfInvalidated() -> Deferred<Maybe<Bool>> {
        return deferMaybe(true)
    }
}
