// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import XCTest
import Yams

class BloomFilterTests: XCTestCase {
    func testStripMobile() throws {
        struct Case {
            let input: String
            let output: String
        }
        let cases = [
            Case(input: "https://en.m.wikipedia.org", output: "https://en.wikipedia.org"),
            Case(input: "https://mobile.facebook.com", output: "https://www.facebook.com"),
            Case(input: "https://m.hotnews.ro", output: "https://www.hotnews.ro"),
            Case(input: "https://m.youtube.com", output: "https://www.youtube.com"),
            Case(input: "https://news.ycombinator.com", output: "https://news.ycombinator.com"),
        ]

        for c in cases {
            let input = try XCTUnwrap(URLComponents(string: c.input))
            XCTAssertEqual(
                c.output,
                CanonicalURL.stripMobile(url: input)?.string
            )
        }
    }

    func testCanonicalURL() throws {
        let testBundleID = try XCTUnwrap(Bundle.main.bundleIdentifier) + ".SharedTests"
        let testBundle = try XCTUnwrap(Bundle(identifier: testBundleID))

        let fileURL = try XCTUnwrap(
            testBundle.url(forResource: "canonical_url_v3", withExtension: "yaml")
        )
        let yamlString = try String(contentsOf: fileURL)
        let parsed = try XCTUnwrap(Yams.load(yaml: yamlString) as? [[String: String]])

        for pair in parsed {
            let input = try XCTUnwrap(pair["url"])
            // Input should be canonalized to meet expectation
            var output = try XCTUnwrap(
                CanonicalURL(from: input)?.asString,
                "Unable to construct canonical URL for \(input)")
            let expectedOutput = try XCTUnwrap(pair["out"])
            XCTAssertEqual(output, expectedOutput)
            // Canonical url input should be unchanged
            output = try XCTUnwrap(
                CanonicalURL(from: expectedOutput)?.asString,
                "Unable to construct canonical URL for \(input)"
            )
            XCTAssertEqual(output, expectedOutput)
        }
    }

    // Test Bloom Filter logic on its own
    func testFilter() throws {
        let testURLs = [
            "https://imgur.com/UziCaVU",
            "https://www.macular.org/ultra-violet-and-blue-light",
            "https://osu.ppy.sh/b/1762724",
            "https://cero.bike/cero-one/",
            "https://m4dm4x.com/blf-q8-arrived/",
            "https://docs.microsoft.com/en-us/azure/devops/pipelines/build/triggers?view=azure-devops&tabs=yaml",
            "https://www.nintendo.com/games/detail/pga-tour-2k21-switch",
            "http://www.dartmouth.edu/~chance/course/topics/curveball.html",
            "http://www.virtual-addiction.com",
            "https://aws.amazon.com/blogs/aws/new-ec2-auto-scaling-groups-with-multiple-instance-types-purchase-options/",
            "https://chrome.google.com/webstore/detail/mosh/ooiklbnjmhbcgemelgfhaeaocllobloj",
            "https://islamophobianetwork.com",
            "https://www.youtube.com/watch?v=W171n_v4ZAs",
            "http://moinmo.in",
            "https://launcher.mojang.com/v1/objects/97b1c53df11cb8b973f4b522c8f4963b7e31495e/server.jar",
            "https://www.youtube.com/watch?v=de1M4Q_g2eg",
            "http://en.wikipedia.org/wiki/Genius",
            "https://www.charlottesweb.com/all-charlottes-web-hemp-cbd-supplements",
            "https://www.sbnation.com/nba/2014/6/3/5772796/nba-y2k-series-finale-the-death-of-basketball",
            "https://www.twitch.tv/streamsniper_hs_#stream",
            "https://youtu.be/qzuM2XTnpSA",
            "https://youtu.be/lpwG8f9nt4s",
            "http://bloodborne.wiki.fextralife.com/Anti-Clockwise+Metamorphosis",
            "http://teamfourstar.com/dragon-ball-z-abridged-episode-58-cell-mates/",
            "http://opencritic.com/critic/1496/philip-kollar",
            "http://www.id3.org",
            "https://store.finalfantasyxiv.com/ffxivstore/en-us/product/534",
            "https://store.steampowered.com/app/1073320/Meteorfall_Krumits_Tale/",
            "https://youtu.be/Lu6kQtxQbqU",
            "https://opencritic.com/critic/515/russell-archey",
            "https://pastebin.com/64GuVi2F/04457",
        ]

        let testBundleID = try XCTUnwrap(Bundle.main.bundleIdentifier) + ".SharedTests"
        let testBundle = try XCTUnwrap(Bundle(identifier: testBundleID))

        let fileURL = try XCTUnwrap(
            testBundle.url(forResource: "test_urls_out", withExtension: "bin")
        )
        let filter = try loadFilter(from: fileURL, timeout: 10)

        for url in testURLs {
            XCTAssertTrue(filter.mayContain(key: url), "URL \(url) missed!")
        }
    }

    /// Integration test with Canonalize + Bloom Filter
    func testRedditFilter() throws {
        let testBundleID = try XCTUnwrap(Bundle.main.bundleIdentifier) + ".SharedTests"
        let testBundle = try XCTUnwrap(Bundle(identifier: testBundleID))

        // load filter
        let filterURL = try XCTUnwrap(testBundle.url(forResource: "reddit", withExtension: "bin"))
        let filter = try loadFilter(from: filterURL)

        // load test URLs
        let testFileURL = try XCTUnwrap(
            testBundle.url(forResource: "reddit_test", withExtension: "txt")
        )
        let testFileData = try String(contentsOf: testFileURL)
        let testURLs: [String] = testFileData.components(separatedBy: .newlines).filter {
            !$0.isEmpty
        }

        let knownErrors: Set<String> = [
            // Backend upper case these percent encodings
            "https://en.wikipedia.org/wiki/%c5%8ckuma_shigenobu",
            // URLComponents percent encodes ; in path
            "https://en.wikipedia.org/wiki/steins;gate",
            "https://steins-gate.fandom.com/wiki/Steins;Gate_Elite_Walkthrough",
            "https://steins-gate.fandom.com/wiki/Steins;Gate_100%25_Completion_Walkthrough",
        ]

        for url in testURLs {
            guard !knownErrors.contains(url) else {
                return
            }
            let canonURL = try XCTUnwrap(
                CanonicalURL(from: url)?.asString, "Unable to construct canonical URL for \(url)"
            )
            XCTAssertTrue(filter.mayContain(key: canonURL), "URL \(canonURL) missed!")
        }
    }

    func loadFilter(
        from url: URL,
        on qos: DispatchQoS.QoSClass = .utility,
        timeout: TimeInterval = 3.0
    ) throws -> BloomFilter {
        var filter: BloomFilter?

        let expectation = XCTestExpectation(description: #function)

        DispatchQueue.global(qos: qos).async {
            do {
                filter = try BloomFilter.load(from: url)
                expectation.fulfill()
            } catch {
                XCTAssertTrue(false, "failed to load filter: \(error)")
            }
        }

        wait(for: [expectation], timeout: timeout)
        return try XCTUnwrap(filter, "No filter loaded")
    }
}
