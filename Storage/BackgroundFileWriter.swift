// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared

private let log = Logger.storage

private class WriteDataTask: Task {
    private let data: Data
    private let writer: (Data) -> Void

    init(data: Data, writer: @escaping (Data) -> Void) {
        self.data = data
        self.writer = writer
    }

    func isDuplicate(of otherTask: Task) -> Bool {
        return data == (otherTask as! WriteDataTask).data
    }

    func run() {
        writer(data)
    }
}

private class WriteDataProviderTask: Task {
    private let dataProvider: () -> Data?
    private let writer: (Data) -> Void

    init(dataProvider: @escaping () -> Data?, writer: @escaping (Data) -> Void) {
        self.dataProvider = dataProvider
        self.writer = writer
    }

    func isDuplicate(of otherTask: Task) -> Bool {
        false
    }

    func run() {
        if let data = dataProvider() {
            writer(data)
        }
    }
}

open class BackgroundFileWriter {
    private let processor: BackgroundTaskProcessor
    private let path: String

    public init(label: String, path: String) {
        self.processor = .init(label: label)
        self.path = path
    }

    /// Schedule `data` to be written out asynchronously on a background thread.
    /// Avoids writing out duplicate data if there are multiple back-to-back
    /// calls to `writeData` that pass identical values of `data`.
    public func writeData(data: Data) {
        processor.performTask(
            task: WriteDataTask(data: data, writer: writeDataSynchronously(data:)))
    }

    /// Alternative form of `writeData` that allows the `Data`, which will be written
    /// out, to be generated lazily. NOTE: This means the `dataProvider` callback will
    /// run on a background thread and needs to be thread-safe.
    public func writeData(from dataProvider: @escaping () -> Data?) {
        processor.performTask(
            task: WriteDataProviderTask(
                dataProvider: dataProvider, writer: writeDataSynchronously(data:)))
    }

    private func writeDataSynchronously(data: Data) {
        do {
            try data.write(to: URL(fileURLWithPath: path), options: .atomic)
            log.info("\(processor.label) data succesfully saved")
        } catch {
            log.error("\(processor.label) data failed to save: \(error.localizedDescription)")
        }
    }
}

#if DEBUG  // Exposed for testing
    extension BackgroundFileWriter {
        public var serialQueueForTesting: DispatchQueue {
            processor.serialQueue
        }
    }
#endif
