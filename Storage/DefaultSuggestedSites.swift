/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

open class DefaultSuggestedSites {
    public static let urlMap: [URL: [String: URL]] = [
        "https://www.amazon.com/": [
            "as": "https://www.amazon.in",
            "cy": "https://www.amazon.co.uk",
            "da": "https://www.amazon.co.uk",
            "de": "https://www.amazon.de",
            "dsb": "https://www.amazon.de",
            "en_GB": "https://www.amazon.co.uk",
            "et": "https://www.amazon.co.uk",
            "ff": "https://www.amazon.fr",
            "ga_IE": "https://www.amazon.co.uk",
            "gu_IN": "https://www.amazon.in",
            "hi_IN": "https://www.amazon.in",
            "hr": "https://www.amazon.co.uk",
            "hsb": "https://www.amazon.de",
            "ja": "https://www.amazon.co.jp",
            "kn": "https://www.amazon.in",
            "mr": "https://www.amazon.in",
            "or": "https://www.amazon.in",
            "sq": "https://www.amazon.co.uk",
            "ta": "https://www.amazon.in",
            "te": "https://www.amazon.in",
            "ur": "https://www.amazon.in",
            "en_CA": "https://www.amazon.ca",
            "fr_CA": "https://www.amazon.ca",
        ]
    ]

    public static let sites = [
        "default": [
            SuggestedSiteData(
                url: "https://m.facebook.com/",
                bgColor: "0x385185",
                imageUrl: "asset://suggestedsites_facebook",
                faviconUrl: "asset://defaultFavicon",
                trackingId: 632,
                title: .DefaultSuggestedFacebook
            ),
            SuggestedSiteData(
                url: "https://m.youtube.com/",
                bgColor: "0xcd201f",
                imageUrl: "asset://suggestedsites_youtube",
                faviconUrl: "asset://defaultFavicon",
                trackingId: 631,
                title: .DefaultSuggestedYouTube
            ),
            SuggestedSiteData(
                url: "https://www.amazon.com/",
                bgColor: "0x000000",
                imageUrl: "asset://suggestedsites_amazon",
                faviconUrl: "asset://defaultFavicon",
                trackingId: 630,
                title: .DefaultSuggestedAmazon
            ),
            SuggestedSiteData(
                url: "https://www.wikipedia.org/",
                bgColor: "0x000000",
                imageUrl: "asset://suggestedsites_wikipedia",
                faviconUrl: "asset://defaultFavicon",
                trackingId: 629,
                title: .DefaultSuggestedWikipedia
            ),
            SuggestedSiteData(
                url: "https://mobile.twitter.com/home",
                bgColor: "0x55acee",
                imageUrl: "asset://suggestedsites_twitter",
                faviconUrl: "asset://defaultFavicon",
                trackingId: 628,
                title: .DefaultSuggestedTwitter
            ),
        ],
        "web3": [
            SuggestedSiteData(
                url: "https://app.uniswap.org/",
                bgColor: "0x000000",
                imageUrl: "https://app.uniswap.org/images/192x192_App_Icon.png",
                faviconUrl: "https://app.uniswap.org/images/192x192_App_Icon.png",
                trackingId: 800,
                title: "Uniswap"
            ),
            SuggestedSiteData(
                url: "https://gitcoin.co",
                bgColor: "0x000000",
                imageUrl:
                    "https://s.gitcoin.co/static/v2/images/favicon.ico/apple-touch-icon.486115005c66.png",
                faviconUrl:
                    "https://s.gitcoin.co/static/v2/images/favicon.ico/apple-touch-icon.486115005c66.png",
                trackingId: 801,
                title: "Gitcoin"
            ),
            SuggestedSiteData(
                url: "https://etherscan.io/",
                bgColor: "0x000000",
                imageUrl: "https://etherscan.io/images/brandassets/etherscan-logo-r.jpg",
                faviconUrl: "https://etherscan.io/images/brandassets/etherscan-logo-r.jpg",
                trackingId: 803,
                title: "Etherscan"
            ),
            SuggestedSiteData(
                url: "https://wallet.polygon.technology/",
                bgColor: "0x000000",
                imageUrl: "https://polygon.technology/android-icon-192x192.png",
                faviconUrl: "https://polygon.technology/android-icon-192x192.png",
                trackingId: 804,
                title: "Polygon Wallet"
            ),
            SuggestedSiteData(
                url: "https://gnosis-safe.io",
                bgColor: "0x000000",
                imageUrl: "https://gnosis-safe.io/favicon/apple-touch-icon.png",
                faviconUrl: "https://gnosis-safe.io/favicon/apple-touch-icon.png",
                trackingId: 805,
                title: "Gnosis Safe"
            ),
            SuggestedSiteData(
                url: "https://aave.com",
                bgColor: "0x55acee",
                imageUrl: "https://aave.com/favicon64.png",
                faviconUrl: "https://aave.com/favicon64.png",
                trackingId: 806,
                title: "Aave"
            ),
            SuggestedSiteData(
                url: "https://matcha.xyz",
                bgColor: "0x55acee",
                imageUrl: "https://matcha.xyz/apple-touch-icon.png",
                faviconUrl: "https://matcha.xyz/apple-touch-icon.png",
                trackingId: 807,
                title: "Matcha"
            ),
        ],
        "zh_CN": [
            SuggestedSiteData(
                url: "http://mozilla.com.cn",
                bgColor: "0xbc3326",
                imageUrl: "asset://suggestedsites_mozchina",
                faviconUrl: "asset://mozChinaLogo",
                trackingId: 700,
                title: "火狐社区"
            ),
            SuggestedSiteData(
                url: "https://m.baidu.com/?from=1000969b",
                bgColor: "0x00479d",
                imageUrl: "asset://suggestedsites_baidu",
                faviconUrl: "asset://baiduLogo",
                trackingId: 701,
                title: "百度"
            ),
            SuggestedSiteData(
                url: "http://sina.cn",
                bgColor: "0xe60012",
                imageUrl: "asset://suggestedsites_sina",
                faviconUrl: "asset://sinaLogo",
                trackingId: 702,
                title: "新浪"
            ),
            SuggestedSiteData(
                url: "http://info.3g.qq.com/g/s?aid=index&g_f=23946&g_ut=3",
                bgColor: "0x028cca",
                imageUrl: "asset://suggestedsites_qq",
                faviconUrl: "asset://qqLogo",
                trackingId: 703,
                title: "腾讯"
            ),
            SuggestedSiteData(
                url: "http://m.taobao.com",
                bgColor: "0xee5900",
                imageUrl: "asset://suggestedsites_taobao",
                faviconUrl: "asset://taobaoLogo",
                trackingId: 704,
                title: "淘宝"
            ),
            SuggestedSiteData(
                url:
                    "http://union.click.jd.com/jdc?e=0&p=AyIHVCtaJQMiQwpDBUoyS0IQWlALHE4YDk5ER1xONwdJKVxASgI%2BeDkWfGJ6HEAOUmkbcjUXVyUBEQZRG1IXARQ3VhhaEQETBVweayVkbzcedVolBxIEUBxdFAoQN1UeXRQLGwFXHlsUABs3UisnS0lKWghLWBQCFzdlK2s%3D&t=W1dCFBBFC14NXAAECUte",
                bgColor: "0xc71622",
                imageUrl: "asset://suggestedsites_jd",
                faviconUrl: "asset://jdLogo",
                trackingId: 705,
                title: "京东"
            ),
        ],
    ]
}
