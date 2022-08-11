/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import Storage
import XCTest

@testable import Client

open class MockTabQueue: TabQueue {
    open func addToQueue(_ tab: ShareItem) -> Success {
        return succeed()
    }

    open func getQueuedTabs() -> Deferred<Maybe<Cursor<ShareItem>>> {
        return deferMaybe(ArrayCursor<ShareItem>(data: []))
    }

    open func clearQueuedTabs() -> Success {
        return succeed()
    }
}

open class MockPanelDataObservers: PanelDataObservers {
    override init(profile: Client.Profile) {
        super.init(profile: profile)
        self.activityStream = MockActivityStreamDataObserver(profile: profile)
    }
}

open class MockActivityStreamDataObserver: DataObserver {
    public func refreshIfNeeded(forceTopSites topSites: Bool) {
    }

    public var profile: Client.Profile
    public weak var delegate: DataObserverDelegate?

    init(profile: Client.Profile) {
        self.profile = profile
    }
}

class MockFiles: FileAccessor {
    init() {
        let docPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true)[0]
        super.init(rootPath: (docPath as NSString).appendingPathComponent("testing"))
    }
}

open class MockProfile: Client.Profile {
    // Read/Writeable properties for mocking
    public var recommendations: HistoryRecommendations
    public var files: FileAccessor
    public var history: BrowserHistory & ResettableSyncStorage

    fileprivate var legacyPlaces:
        BrowserHistory & Favicons & ResettableSyncStorage & HistoryRecommendations

    public lazy var panelDataObservers: PanelDataObservers = {
        return MockPanelDataObservers(profile: self)
    }()

    var db: BrowserDB
    var readingListDB: BrowserDB

    fileprivate let name: String = "mockaccount"

    init(databasePrefix: String = "mock") {
        files = MockFiles()
        try? files.remove("\(databasePrefix)_logins.db")
        db = BrowserDB(filename: "\(databasePrefix).db", schema: BrowserSchema(), files: files)
        readingListDB = BrowserDB(
            filename: "\(databasePrefix)_ReadingList.db", schema: ReadingListSchema(), files: files)
        legacyPlaces = SQLiteHistory(db: self.db)
        recommendations = legacyPlaces
        history = legacyPlaces
    }

    public func localName() -> String {
        return name
    }

    // swift-format-ignore: NoLeadingUnderscores
    public func _reopen() {
        isShutdown = false

        db.reopenIfClosed()
    }

    // swift-format-ignore: NoLeadingUnderscores
    public func _shutdown() {
        isShutdown = true

        db.forceClose()
        UserDefaults.standard.clearProfilePrefs()
    }

    public var isShutdown: Bool = false

    public var favicons: Favicons {
        return self.legacyPlaces
    }

    lazy public var queue: TabQueue = {
        return MockTabQueue()
    }()

    lazy public var metadata: Metadata = {
        return SQLiteMetadata(db: self.db)
    }()

    lazy public var certStore: CertStore = {
        return CertStore()
    }()

    lazy public var readingList: ReadingList = {
        return SQLiteReadingList(db: self.readingListDB)
    }()

    internal lazy var remoteClientsAndTabs: RemoteClientsAndTabs = {
        return SQLiteRemoteClientsAndTabs(db: self.db)
    }()

    fileprivate lazy var syncCommands: SyncCommands = {
        return SQLiteRemoteClientsAndTabs(db: self.db)
    }()

    public func hasAccount() -> Bool {
        return true
    }

    public func hasSyncableAccount() -> Bool {
        return true
    }

    public func flushAccount() {}

    public func removeAccount() {
    }

    public func getClients() -> Deferred<Maybe<[RemoteClient]>> {
        return deferMaybe([])
    }

    public func getCachedClients() -> Deferred<Maybe<[RemoteClient]>> {
        return deferMaybe([])
    }

    public func getClientsAndTabs() -> Deferred<Maybe<[ClientAndTabs]>> {
        return deferMaybe([])
    }

    public func getCachedClientsAndTabs() -> Deferred<Maybe<[ClientAndTabs]>> {
        return deferMaybe([])
    }

    public func cleanupHistoryIfNeeded() {}

    public func storeTabs(_ tabs: [RemoteTab]) -> Deferred<Maybe<Int>> {
        return deferMaybe(0)
    }

    public func sendItem(_ item: ShareItem, toDevices devices: [RemoteDevice]) -> Success {
        return succeed()
    }

    public func sendQueuedSyncEvents() {}
}
