// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Storage
import XCTest

class BackgroundFileWriterTests: XCTestCase {
    private var testFiles: MockFiles!
    private var testDir: String!

    override func setUp() {
        testFiles = MockFiles()
        testDir = try! testFiles.getAndEnsureDirectory()
        try! testFiles.removeFilesInDirectory()
    }

    private func assert(file: String, contains data: Data) {
        XCTAssertTrue(FileManager.default.fileExists(atPath: file))
        let contents = try! Data(contentsOf: URL(fileURLWithPath: file))
        XCTAssertEqual(data, contents)
    }

    func testBasic() {
        let data = "hello world".data(using: .utf8)!

        let relativePath = "testfile"
        let testFile = URL(fileURLWithPath: testDir).appendingPathComponent(relativePath).path

        let writer = BackgroundFileWriter(label: "testBasic", path: testFile)
        writer.writeData(data: data)

        writer.serialQueueForTesting.sync {}  // Ensure data has been written

        assert(file: testFile, contains: data)
    }

    func testRedundantData() {
        let data = "hello world".data(using: .utf8)!

        let relativePath = "testfile"
        let testFile = URL(fileURLWithPath: testDir).appendingPathComponent(relativePath).path

        let writer = BackgroundFileWriter(label: "testBasic", path: testFile)

        // To encourage overlap of the two writeData calls.
        writer.serialQueueForTesting.async { Thread.sleep(forTimeInterval: 0.1) }

        writer.writeData(data: data)
        writer.writeData(data: data)

        writer.serialQueueForTesting.sync {}  // Ensure data has been written

        assert(file: testFile, contains: data)
    }

    func testDifferentData() {
        let data1 = "hello world".data(using: .utf8)!
        let data2 = "foo bar".data(using: .utf8)!

        let relativePath = "testfile"
        let testFile = URL(fileURLWithPath: testDir).appendingPathComponent(relativePath).path

        let writer = BackgroundFileWriter(label: "testBasic", path: testFile)

        // To encourage overlap of the two writeData calls.
        writer.serialQueueForTesting.async { Thread.sleep(forTimeInterval: 0.1) }

        writer.writeData(data: data1)
        writer.writeData(data: data2)

        writer.serialQueueForTesting.sync {}  // Ensure data has been written

        assert(file: testFile, contains: data2)
    }

    func testDataProvider() {
        let data = "hello world".data(using: .utf8)!

        let relativePath = "testfile"
        let testFile = URL(fileURLWithPath: testDir).appendingPathComponent(relativePath).path

        let writer = BackgroundFileWriter(label: "testBasic", path: testFile)
        writer.writeData(from: { data })

        writer.serialQueueForTesting.sync {}  // Ensure data has been written

        assert(file: testFile, contains: data)
    }
}
