// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared

struct TrackingData {
    let numTrackers: Int
    let numDomains: Int
    let trackingEntities: [TrackingEntity]
    let numAdBlocked: Int
}

enum TrackingEntity: String {
    case Google = "Google"
    case Facebook = "Facebook"
    case Twitter = "Twitter"
    case Amazon = "Amazon"
    case Outbrain = "Outbrain"
    case Criteo = "Criteo"
    case Adobe = "Adobe"
    case Oracle = "Oracle"
    case WarnerMedia = "WarnerMedia"
    case IAS = "IAS"
    case Pinterest = "Pinterest"
    case VerizonMedia = "VerizonMedia"

    static func getTrackingDataForCurrentTab(stats: TPPageStats?) -> TrackingData {
        let domainsCollapsedAcrossCategories = stats?.domains ?? [String]()
        let numTrackers = domainsCollapsedAcrossCategories.count
        let numDomains =
            domainsCollapsedAcrossCategories
            .reduce(into: [String: Int]()) { dict, domain in
                dict[domain] = (dict[domain] ?? 0) + 1
            }.count
        let numAdBlocked = stats?.numAdBlocked ?? 0
        let trackingEntities = domainsCollapsedAcrossCategories.map { (domain) -> TrackingEntity? in
            for element in trackingEntityMap {
                guard let baseDomain = URL(string: "https://" + domain)?.baseDomain else {
                    return nil
                }
                if element.value.contains(baseDomain) {
                    return element.key
                }
            }
            return nil
        }.compactMap { $0 }
        return TrackingData(
            numTrackers: numTrackers,
            numDomains: numDomains,
            trackingEntities: trackingEntities,
            numAdBlocked: numAdBlocked)
    }
}

let trackingEntityMap =
    [
        TrackingEntity.Google: [
            "1emn.com",
            "2mdn.net",
            "admeld.com",
            "admob.com",
            "app-measurement.com",
            "apture.com",
            "asp-cc.com",
            "blogger.com",
            "cc-dt.com",
            "crashlytics.com",
            "dartsearch.net",
            "dmtry.com",
            "doubleclick.com",
            "doubleclick.net",
            "firebaseio.com",
            "gmodules.com",
            "google-analytics.com",
            "googleadservices.com",
            "googleadsserving.cn",
            "googlegroups.com",
            "googlesyndication.com",
            "googletagmanager.com",
            "googletagservices.com",
            "googleusercontent.com",
            "gstatic.com",
            "invitemedia.com",
            "page.link",
            "urchin.com",
            "waze.com",
            "youtube.com",
        ],
        TrackingEntity.Facebook: [
            "accountkit.com",
            "atdmt.com",
            "atlassbx.com",
            "atlassolutions.com",
            "facebook.com",
            "fbsbx.com",
            "liverail.com",
            "whatsapp.net",
        ],
        TrackingEntity.Twitter: [
            "ads-twitter.com",
            "mopub.com",
            "twitter.com",
            "twttr.com",
        ],
        TrackingEntity.Amazon: [
            "alexa.com",
            "alexametrics.com",
            "amazon-adsystem.com",
            "assoc-amazon.com",
            "assoc-amazon.jp",
            "graphiq.com",
            "media-imdb.com",
            "peer39.com",
            "peer39.net",
            "serving-sys.com",
            "sizmek.com",
            "twitch.tv",
            "wfm.com",
        ],
        TrackingEntity.Outbrain: [
            "ligatus.com",
            "outbrain.com",
            "veeseo.com",
            "zemanta.com",
        ],
        TrackingEntity.Criteo: [
            "criteo.com",
            "criteo.net",
            "emailretargeting.com",
            "hlserve.com",
            "manage.com",
        ],
        TrackingEntity.Adobe: [
            "2o7.net",
            "adobe.com",
            "adobetag.com",
            "auditude.com",
            "bizible.com",
            "businesscatalyst.com",
            "demdex.net",
            "everestads.net",
            "everestjs.net",
            "everesttech.net",
            "fyre.co",
            "hitbox.com",
            "livefyre.com",
            "marketo.com",
            "marketo.net",
            "mktoresp.com",
            "nedstat.net",
            "omniture.com",
            "omtrdc.net",
            "sitestat.com",
            "tubemogul.com",
        ],
        TrackingEntity.Oracle: [
            "sekindo.com",
            "addthis.com",
            "addthiscdn.com",
            "addthisedge.com",
            "atgsvcs.com",
            "bkrtx.com",
            "bluekai.com",
            "bm23.com",
            "compendium.com",
            "en25.com",
            "grapeshot.co.uk",
            "maxymiser.net",
            "moat.com",
            "moatads.com",
            "moatpixel.com",
            "nexac.com",
            "responsys.net",
        ],
        TrackingEntity.WarnerMedia: [
            "247realmedia.com",
            "adnxs.com",
            "adultswim.com",
            "cartoonnetwork.com",
            "cnn.com",
            "ncaa.com",
            "realmedia.com",
            "tbs.com",
            "tmz.com",
            "trutv.com",
            "turner.com",
            "ugdturner.com",
            "warnerbros.com",
            "yieldoptimizer.com",
        ],
        TrackingEntity.IAS: [
            "adsafeprotected.com",
            "iasds01.com",
        ],
        TrackingEntity.Pinterest: [
            "pinterest.com"
        ],
        TrackingEntity.VerizonMedia: [
            "adap.tv",
            "adsonar.com",
            "adtech.de",
            "adtechjp.com",
            "adtechus.com",
            "advertising.com",
            "aol.co.uk",
            "aol.com",
            "aol.fr",
            "aolp.jp",
            "atwola.com",
            "bluelithium.com",
            "brightroll.com",
            "btrll.com",
            "convertro.com",
            "engadget.com",
            "flurry.com",
            "hostingprod.com",
            "lexity.com",
            "mybloglog.com",
            "nexage.com",
            "overture.com",
            "pictela.net",
            "pulsemgr.com",
            "rmxads.com",
            "vidible.tv",
            "wretch.cc",
            "yahoo.com",
            "yahoo.net",
            "yahoodns.net",
            "yieldmanager.com",
            "yieldmanager.net",
            "yimg.com",
        ],
    ]
