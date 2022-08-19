// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared

struct TrackingPreventionUtils {
    private static func readDomains() -> String? {
        if let filepath = Bundle.main.path(forResource: "trackerDomains", ofType: "json") {
            do {
                let contents = try String(contentsOfFile: filepath)
                return contents
            } catch {
                // Handle!
            }
        } else {
            // Handle!
        }
        return nil
    }

    static let maxDomainsPerRule = 20
    static let maxRulesAllowedInContentBlocker = 50000

    private static func buildRegex(domains: [String]) -> String {
        // This regex language have limited power
        // Check https://developer.apple.com/documentation/safariservices/creating_a_content_blocker
        let regex =
            "^(https?)?(wss?)?:[/][/](.+\\.)?("
            + domains.map { (domain) -> String in
                return "(" + NSRegularExpression.escapedPattern(for: domain) + ")?"
            }.joined(separator: "") + ")" + "[/]" + ".*"
        return regex
    }

    private static func blockingRule(domains: [String], actionType: String)
        -> TrackingPreventionRule
    {

        return TrackingPreventionRule(
            trigger: TrackingPreventionTrigger(
                urlFilter: buildRegex(domains: domains), urlFilterIsCaseSensitive: false,
                ifDomain: nil, unlessDomain: nil, resourceType: nil, loadType: [ThirdParty]),
            action: TrackingPreventionAction(
                type: actionType
            )
        )
    }

    private static func blockingRules(domains: [String]) -> [TrackingPreventionRule] {
        var rules: [TrackingPreventionRule] = []
        var actionType: String?

        if Defaults[.blockThirdPartyTrackingRequests] {
            actionType = Block
        } else if Defaults[.blockThirdPartyTrackingCookies] {
            actionType = BlockCookies
        }

        if actionType != nil {
            var groupedDomains: [String] = []
            var dcount = 0
            for (_, domain) in domains.enumerated() {
                groupedDomains.append(domain)
                dcount += 1
                if dcount == maxDomainsPerRule {
                    rules.append(blockingRule(domains: groupedDomains, actionType: actionType!))
                    dcount = 0
                    groupedDomains = []
                }
            }
            if groupedDomains.count > 0 {
                rules.append(blockingRule(domains: groupedDomains, actionType: actionType!))
            }
        }
        return rules
    }

    private static func upgradeAllToHTTPSRule() -> [TrackingPreventionRule] {
        var rules: [TrackingPreventionRule] = []

        if Defaults[.upgradeAllToHttps] {
            rules.append(
                TrackingPreventionRule(
                    trigger: TrackingPreventionTrigger(urlFilter: ".*"),
                    action: TrackingPreventionAction(type: MakeHTTPS)))
        }
        return rules
    }

    private static func unblockedRule(domains: [String]) -> TrackingPreventionRule {
        return TrackingPreventionRule(
            trigger: TrackingPreventionTrigger(
                urlFilter: ".*", urlFilterIsCaseSensitive: false, ifDomain: domains,
                unlessDomain: nil, resourceType: nil, loadType: nil, ifTopUrl: nil),
            action: TrackingPreventionAction(
                type: IgnorePreviousRules
            )
        )
    }

    private static func unblockedRules() -> [TrackingPreventionRule] {
        var rules: [TrackingPreventionRule] = []
        let domains = Defaults[.unblockedDomains]

        NSLog("unblockedRules domains:", domains.count, domains)
        var groupedPatterns: [String] = []
        var dcount = 0
        for (_, domain) in domains.enumerated() {
            groupedPatterns.append("*" + domain)
            dcount += 1
            if dcount == maxDomainsPerRule {
                rules.append(unblockedRule(domains: groupedPatterns))
                dcount = 0
                groupedPatterns = []
            }
        }
        if groupedPatterns.count > 0 {
            rules.append(unblockedRule(domains: groupedPatterns))
        }
        return rules
    }
}
