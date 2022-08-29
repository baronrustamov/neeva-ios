// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared

extension NavigationPath {
    enum SearchPathType {
        case google
        case search
        case empty
        case searchTouch
        case s
        case web

        private static let googleDomains = [
            "www.google.com",
            "www.google.ad",
            "www.google.ae",
            "www.google.com.af",
            "www.google.com.ag",
            "www.google.com.ai",
            "www.google.al",
            "www.google.am",
            "www.google.co.ao",
            "www.google.com.ar",
            "www.google.as",
            "www.google.at",
            "www.google.com.au",
            "www.google.az",
            "www.google.ba",
            "www.google.com.bd",
            "www.google.be",
            "www.google.bf",
            "www.google.bg",
            "www.google.com.bh",
            "www.google.bi",
            "www.google.bj",
            "www.google.com.bn",
            "www.google.com.bo",
            "www.google.com.br",
            "www.google.bs",
            "www.google.bt",
            "www.google.co.bw",
            "www.google.by",
            "www.google.com.bz",
            "www.google.ca",
            "www.google.cd",
            "www.google.cf",
            "www.google.cg",
            "www.google.ch",
            "www.google.ci",
            "www.google.co.ck",
            "www.google.cl",
            "www.google.cm",
            "www.google.cn",
            "www.google.com.co",
            "www.google.co.cr",
            "www.google.com.cu",
            "www.google.cv",
            "www.google.com.cy",
            "www.google.cz",
            "www.google.de",
            "www.google.dj",
            "www.google.dk",
            "www.google.dm",
            "www.google.com.do",
            "www.google.dz",
            "www.google.com.ec",
            "www.google.ee",
            "www.google.com.eg",
            "www.google.es",
            "www.google.com.et",
            "www.google.fi",
            "www.google.com.fj",
            "www.google.fm",
            "www.google.fr",
            "www.google.ga",
            "www.google.ge",
            "www.google.gg",
            "www.google.com.gh",
            "www.google.com.gi",
            "www.google.gl",
            "www.google.gm",
            "www.google.gr",
            "www.google.com.gt",
            "www.google.gy",
            "www.google.com.hk",
            "www.google.hn",
            "www.google.hr",
            "www.google.ht",
            "www.google.hu",
            "www.google.co.id",
            "www.google.ie",
            "www.google.co.il",
            "www.google.im",
            "www.google.co.in",
            "www.google.iq",
            "www.google.is",
            "www.google.it",
            "www.google.je",
            "www.google.com.jm",
            "www.google.jo",
            "www.google.co.jp",
            "www.google.co.ke",
            "www.google.com.kh",
            "www.google.ki",
            "www.google.kg",
            "www.google.co.kr",
            "www.google.com.kw",
            "www.google.kz",
            "www.google.la",
            "www.google.com.lb",
            "www.google.li",
            "www.google.lk",
            "www.google.co.ls",
            "www.google.lt",
            "www.google.lu",
            "www.google.lv",
            "www.google.com.ly",
            "www.google.co.ma",
            "www.google.md",
            "www.google.me",
            "www.google.mg",
            "www.google.mk",
            "www.google.ml",
            "www.google.com.mm",
            "www.google.mn",
            "www.google.ms",
            "www.google.com.mt",
            "www.google.mu",
            "www.google.mv",
            "www.google.mw",
            "www.google.com.mx",
            "www.google.com.my",
            "www.google.co.mz",
            "www.google.com.na",
            "www.google.com.ng",
            "www.google.com.ni",
            "www.google.ne",
            "www.google.nl",
            "www.google.no",
            "www.google.com.np",
            "www.google.nr",
            "www.google.nu",
            "www.google.co.nz",
            "www.google.com.om",
            "www.google.com.pa",
            "www.google.com.pe",
            "www.google.com.pg",
            "www.google.com.ph",
            "www.google.com.pk",
            "www.google.pl",
            "www.google.pn",
            "www.google.com.pr",
            "www.google.ps",
            "www.google.pt",
            "www.google.com.py",
            "www.google.com.qa",
            "www.google.ro",
            "www.google.ru",
            "www.google.rw",
            "www.google.com.sa",
            "www.google.com.sb",
            "www.google.sc",
            "www.google.se",
            "www.google.com.sg",
            "www.google.sh",
            "www.google.si",
            "www.google.sk",
            "www.google.com.sl",
            "www.google.sn",
            "www.google.so",
            "www.google.sm",
            "www.google.sr",
            "www.google.st",
            "www.google.com.sv",
            "www.google.td",
            "www.google.tg",
            "www.google.co.th",
            "www.google.com.tj",
            "www.google.tl",
            "www.google.tm",
            "www.google.tn",
            "www.google.to",
            "www.google.com.tr",
            "www.google.tt",
            "www.google.com.tw",
            "www.google.co.tz",
            "www.google.com.ua",
            "www.google.co.ug",
            "www.google.co.uk",
            "www.google.com.uy",
            "www.google.co.uz",
            "www.google.com.vc",
            "www.google.co.ve",
            "www.google.vg",
            "www.google.co.vi",
            "www.google.com.vn",
            "www.google.vu",
            "www.google.ws",
            "www.google.rs",
            "www.google.co.za",
            "www.google.co.zm",
            "www.google.co.zw",
            "www.google.cat",
        ]
        private static let searchDomains = [
            "www.bing.com", "www.ecosia.org", "search.yahoo.com",
        ]
        private static let noneDomains = ["duckduckgo.com"]
        private static let searchTouchDomains = ["yandex.com"]
        private static let sDomains = ["www.baidu.com", "www.so.com", "m.so.com"]
        private static let webDomains = ["www.sogou.com", "wap.sogou.com"]

        static var map: [String: Self] = {
            let allDomains =
                Self.googleDomains + Self.searchDomains + Self.noneDomains + Self.searchTouchDomains
                + Self.sDomains + Self.webDomains
            let labelsPartA: [Self] =
                Array(repeating: .google, count: Self.googleDomains.count)
                + Array(repeating: .search, count: Self.searchDomains.count)
                + Array(repeating: .empty, count: Self.noneDomains.count)
            let labelsPartB: [Self] =
                Array(repeating: .searchTouch, count: Self.searchTouchDomains.count)
                + Array(repeating: .s, count: Self.sDomains.count)
                + Array(repeating: .web, count: Self.webDomains.count)

            return Dictionary(
                uniqueKeysWithValues: zip(allDomains, labelsPartA + labelsPartB)
            )
        }()

        private func isPathAMatch(path: String) -> Bool {
            switch self {
            case .google, .search:
                // yahoo path starts with /search
                return path.starts(with: "/search")
            case .empty:
                return true
            case .searchTouch:
                return path == "/search/touch/"
            case .s:
                // baidu path may start with /from
                return path.contains("/s")
            case .web:
                // sogou path contains /searchList
                return path.starts(with: "/web")
            }
        }

        static func getQueryValue(components: URLComponents) -> String? {
            // Example of what components looks like:
            //    - scheme : "https"
            //    - host : "www.google.com"
            //    - path : "/search"
            //    ▿ queryItems : 5 elements
            //      ▿ 0 : q=foo+bar
            //        - name : "q"
            //        ▿ value : Optional<String>
            //          - some : "foo+bar"
            //      ▿ 1 : ie=UTF-8
            //        - name : "ie"
            //        ▿ value : Optional<String>
            //          - some : "UTF-8"
            //      ▿ 2 : oe=UTF-8
            //        - name : "oe"
            //        ▿ value : Optional<String>
            //          - some : "UTF-8"
            //      ▿ 3 : hl=en
            //        - name : "hl"
            //        ▿ value : Optional<String>
            //          - some : "en"
            //      ▿ 4 : client=safari
            //        - name : "client"
            //        ▿ value : Optional<String>
            //          - some : "safari"
            guard let host = components.host,
                let pathType = Self.map[host],
                pathType.isPathAMatch(path: components.path),
                let queryItems = components.percentEncodedQueryItems
            else { return nil }
            switch pathType {
            case .google, .search:
                // yahoo uses p for the search query name instead of q
                let queryName = (host == "search.yahoo.com") ? "p" : "q"
                return queryItems.first(where: { $0.name == queryName })?.value
            case .empty:
                return queryItems.first(where: { $0.name == "q" })?.value
            case .searchTouch:
                return queryItems.first(where: { $0.name == "text" })?.value
            case .s:
                let queryName = (host == "www.baidu.com") ? "word" : "q"
                return queryItems.first(where: { $0.name == queryName })?.value
            case .web:
                return queryItems.first(where: { $0.name == "keyword" })?.value
            }
        }
    }

    public static func maybeRewriteURL(_ url: URL, _ components: URLComponents) -> URL? {
        // Intercept and rewrite search queries incoming from e.g. SpotLight.
        if let value = SearchPathType.getQueryValue(components: components),
            let sanitizedValue = value.replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding,
            let newURL = SearchEngine.current.searchURLForQuery(sanitizedValue)
        {
            return newURL
        } else {
            return nil
        }
    }
}
