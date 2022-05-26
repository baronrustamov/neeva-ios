// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import XCTest

class FileHasherTest: XCTestCase {
    func testMD5() throws {
        let testBundleID = try XCTUnwrap(Bundle.main.bundleIdentifier) + ".SharedTests"
        let testBundle = try XCTUnwrap(Bundle(identifier: testBundleID))
        let filterURL = try XCTUnwrap(testBundle.url(forResource: "reddit", withExtension: "bin"))

        let hash = try FileHasher.md5(forFileAt: filterURL)
        XCTAssertEqual(hash, "70d2143e042de8b27000450144bf2ea1")
    }

    func testSHA256() throws {
        let testBundleID = try XCTUnwrap(Bundle.main.bundleIdentifier) + ".SharedTests"
        let testBundle = try XCTUnwrap(Bundle(identifier: testBundleID))
        let filterURL = try XCTUnwrap(testBundle.url(forResource: "reddit", withExtension: "bin"))

        let hash = try FileHasher.sha256(forFileAt: filterURL)
        XCTAssertEqual(hash, "9b5451084d26e9869a4f372bb3d2ab149d090424b30205658be292794b7ed608")
    }

    func testMultipleHash() throws {
        let testBundleID = try XCTUnwrap(Bundle.main.bundleIdentifier) + ".SharedTests"
        let testBundle = try XCTUnwrap(Bundle(identifier: testBundleID))
        let filterURL = try XCTUnwrap(testBundle.url(forResource: "reddit", withExtension: "bin"))

        let hashes = try FileHasher.computeHashOfFile(at: filterURL, using: Set(HashAlgo.allCases))

        for algo in HashAlgo.allCases {
            let hash = try XCTUnwrap(hashes[algo])
            switch algo {
            case .md5:
                XCTAssertEqual(hash, "70d2143e042de8b27000450144bf2ea1")
            case .sha256:
                XCTAssertEqual(
                    hash, "9b5451084d26e9869a4f372bb3d2ab149d090424b30205658be292794b7ed608")
            }
        }
    }
}
