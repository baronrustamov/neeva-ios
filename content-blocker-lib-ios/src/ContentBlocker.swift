/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Defaults
import Foundation
import Shared
import StoreKit
import WebKit
import XCGLogger

private let log = Logger.browser

enum BlocklistCategory: CaseIterable {
    case easyPrivacy
    case easyPrivacyStrict
    case easyListAdBlock

    static func fromFile(_ file: BlocklistFileName) -> BlocklistCategory {
        switch file {
        case .easyPrivacy:
            return .easyPrivacy
        case .easyPrivacyStrict:
            return .easyPrivacyStrict
        case .easyListAdBlock:
            return .easyListAdBlock
        }
    }
}

enum BlocklistFileName: CaseIterable {
    case easyPrivacy
    case easyPrivacyStrict
    case easyListAdBlock

    static let easyListCountryMap = [
        "DEU": "german",
        "FRA": "french",
    ]

    var filename: String {
        switch self {
        case .easyPrivacy:
            return "easy_privacy"
        case .easyPrivacyStrict:
            return "easy_privacy_strict"
        case .easyListAdBlock:
            var suffix = ""
            if let countryCode = SKPaymentQueue.default().storefront?.countryCode,
                let language = Self.easyListCountryMap[countryCode]
            {
                suffix = "_\(language)"
            }
            let easylistAdBlockFilename = "easy_list" + suffix
            log.debug("ad blocker rule filename: \(easylistAdBlockFilename)")
            return easylistAdBlockFilename
        }
    }

    static var easyPrivacyStrength: [BlocklistFileName] { return [.easyPrivacy] }

    static func listsForMode(strength: BlockingStrength) -> [BlocklistFileName] {
        var fileList = [BlocklistFileName]()
        switch strength {
        case .easyPrivacy:
            fileList.append(.easyPrivacy)
        case .easyPrivacyStrict:
            fileList.append(.easyPrivacy)
            fileList.append(.easyPrivacyStrict)
            if Defaults[.adBlockEnabled] {
                fileList.append(.easyListAdBlock)
            }
        }
        return fileList
    }

    static func statsListsForMode(strength: BlockingStrength) -> [BlocklistFileName] {
        var blockListFiles = BlocklistFileName.listsForMode(
            strength: BlockingStrength(rawValue: Defaults[.contentBlockingStrength]) ?? .easyPrivacy
        )

        // easyPrivacy should cover easyPrivacyStrict rules for stats collection purpose
        if blockListFiles.contains(.easyPrivacy) {
            blockListFiles.removeAll { file in
                return file == .easyPrivacyStrict
            }
        }
        return blockListFiles
    }
}

class ContentBlocker {
    let ruleStore: WKContentRuleListStore = WKContentRuleListStore.default()
    var setupCompleted = false

    static let shared = ContentBlocker()

    private init() {
        TPStatsBlocklistChecker.shared.startup()

        removeOldListsByDateFromStore {
            self.removeOldListsByNameFromStore {
                self.compileListsNotInStore {
                    self.setupCompleted = true
                    NotificationCenter.default.post(
                        name: .contentBlockerTabSetupRequired, object: nil)
                }
            }
        }
        Defaults.observe(
            keys: .cookieCutterEnabled, .contentBlockingStrength, .adBlockEnabled, options: []
        ) { [weak self] in
            guard let self = self else { return }
            self.prefsChanged()
        }.tieToLifetime(of: self)
    }

    private func prefsChanged() {
        // This class func needs to notify all the active instances of ContentBlocker to update.
        NotificationCenter.default.post(name: .contentBlockerTabSetupRequired, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // Function to install or remove TP for a tab
    func setupTrackingProtection(
        forTab tab: ContentBlockerTab, isEnabled: Bool, rules: [BlocklistFileName]
    ) {
        removeTrackingProtection(forTab: tab)

        if !isEnabled {
            return
        }

        for list in rules {
            let name = list.filename
            ruleStore.lookUpContentRuleList(forIdentifier: name) { rule, error in
                guard let rule = rule else {
                    let msg =
                        "lookUpContentRuleList for \(name): \(error?.localizedDescription ?? "empty rules")"
                    print("Content blocker error: \(msg)")
                    return
                }
                self.add(contentRuleList: rule, toTab: tab)
            }
        }
    }

    private func removeTrackingProtection(forTab tab: ContentBlockerTab) {
        tab.currentWebView()?.configuration.userContentController.removeAllContentRuleLists()
    }

    private func add(contentRuleList: WKContentRuleList, toTab tab: ContentBlockerTab) {
        tab.currentWebView()?.configuration.userContentController.add(contentRuleList)
    }
}

// MARK: Initialization code
// The rule store can compile JSON rule files into a private format which is cached on disk.
// On app boot, we need to check if the ruleStore's data is out-of-date, or if the names of the rule files
// no longer match. Finally, any JSON rule files that aren't in the ruleStore need to be compiled and stored in the
// ruleStore.
extension ContentBlocker {
    private func loadJsonFromBundle(
        forResource file: String, completion: @escaping (_ jsonString: String) -> Void
    ) {
        DispatchQueue.global().async {
            guard let path = Bundle.main.path(forResource: file, ofType: "json"),
                let source = try? String(contentsOfFile: path, encoding: .utf8)
            else {
                assert(false)
                return
            }

            DispatchQueue.main.async {
                completion(source)
            }
        }
    }

    private func lastModifiedSince1970(forFileAtPath path: String) -> Date? {
        do {
            let url = URL(fileURLWithPath: path)
            let attr = try FileManager.default.attributesOfItem(atPath: url.path)
            guard let date = attr[FileAttributeKey.modificationDate] as? Date else { return nil }
            return date
        } catch {
            return nil
        }
    }

    private func dateOfMostRecentBlockerFile() -> Date? {
        let blocklists = BlocklistFileName.allCases

        return blocklists.reduce(Date(timeIntervalSince1970: 0)) { result, list in
            guard let path = Bundle.main.path(forResource: list.filename, ofType: "json") else {
                return result
            }
            if let date = lastModifiedSince1970(forFileAtPath: path) {
                return date > result ? date : result
            }
            return result
        }
    }

    func removeAllRulesInStore(completion: @escaping () -> Void) {
        ruleStore.getAvailableContentRuleListIdentifiers { available in
            guard let available = available else {
                completion()
                return
            }
            let deferreds: [Deferred<Void>] = available.map { filename in
                let result = Deferred<Void>()
                self.ruleStore.removeContentRuleList(forIdentifier: filename) { _ in
                    result.fill(())
                }
                return result
            }
            all(deferreds).uponQueue(.main) { _ in
                completion()
            }
        }
    }

    // If any blocker files are newer than the date saved in prefs,
    // remove all the content blockers and reload them.
    func removeOldListsByDateFromStore(completion: @escaping () -> Void) {

        guard let fileDate = dateOfMostRecentBlockerFile() else {
            completion()
            return
        }

        guard
            let prefsNewestDate = UserDefaults.standard.object(forKey: "blocker-file-date") as? Date
        else {
            UserDefaults.standard.set(fileDate, forKey: "blocker-file-date")
            completion()
            return
        }

        if fileDate <= prefsNewestDate {
            completion()
            return
        }

        UserDefaults.standard.set(fileDate, forKey: "blocker-file-date")

        removeAllRulesInStore {
            completion()
        }
    }

    func removeOldListsByNameFromStore(completion: @escaping () -> Void) {
        var noMatchingIdentifierFoundForRule = false

        ruleStore.getAvailableContentRuleListIdentifiers { available in
            guard let available = available else {
                completion()
                return
            }

            let blocklists = BlocklistFileName.allCases.map { $0.filename }
            for listOnDisk in blocklists {
                // If any file from the list on disk is not installed, remove all the rules and re-install them
                if !available.contains(where: { $0 == listOnDisk }) {
                    noMatchingIdentifierFoundForRule = true
                    break
                }
            }
            if !noMatchingIdentifierFoundForRule {
                completion()
                return
            }

            self.removeAllRulesInStore {
                completion()
            }
        }
    }

    func compileListsNotInStore(completion: @escaping () -> Void) {
        var blocklists = [String]()
        blocklists = BlocklistFileName.allCases.map { $0.filename }

        let deferreds: [Deferred<Void>] = blocklists.map { filename in
            let result = Deferred<Void>()
            ruleStore.lookUpContentRuleList(forIdentifier: filename) { contentRuleList, error in
                if contentRuleList != nil {
                    result.fill(())
                    return
                }
                self.loadJsonFromBundle(forResource: filename) { jsonString in
                    var str = jsonString
                    guard let range = str.range(of: "]", options: String.CompareOptions.backwards)
                    else { return }
                    str = str.replacingCharacters(in: range, with: self.safelistAsJSON() + "]")
                    self.ruleStore.compileContentRuleList(
                        forIdentifier: filename, encodedContentRuleList: str
                    ) { rule, error in
                        if let error = error {
                            print("Content blocker error: \(error)")
                            assert(false)
                        }
                        assert(rule != nil)
                        result.fill(())
                    }
                }
            }
            return result
        }

        all(deferreds).uponQueue(.main) { _ in
            completion()
        }
    }
}
