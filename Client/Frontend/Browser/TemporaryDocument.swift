/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared

private let temporaryDocumentOperationQueue = OperationQueue()

// This class downloads an URL to a local temp file that is kept around for the
// lifetime of the object.
class TemporaryDocument: NSObject {
    fileprivate let request: URLRequest
    fileprivate let filename: String
    let mimeType: String?

    fileprivate var session: URLSession?

    fileprivate var downloadTask: URLSessionDownloadTask?
    fileprivate var localFileURL: URL?
    fileprivate var pendingResult: Deferred<URL>?

    init(preflightResponse: URLResponse, request: URLRequest) {
        self.request = request
        self.filename = preflightResponse.suggestedFilename ?? "unknown"
        self.mimeType = preflightResponse.mimeType

        super.init()

        self.session = URLSession(
            configuration: .default, delegate: self, delegateQueue: temporaryDocumentOperationQueue)
    }

    deinit {
        // Delete the temp file.
        if let url = localFileURL {
            try? FileManager.default.removeItem(at: url)
        }
    }

    func getURL() -> Deferred<URL> {
        if let url = localFileURL {
            let result = Deferred<URL>()
            result.fill(url)
            return result
        }

        if let result = pendingResult {
            return result
        }

        let result = Deferred<URL>()
        pendingResult = result

        downloadTask = session?.downloadTask(with: request)
        downloadTask?.resume()

        return result
    }
}

extension TemporaryDocument: URLSessionTaskDelegate, URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    {
        // If we encounter an error downloading the temp file, just return with the
        // original remote URL so it can still be shared as a web URL.
        if error != nil, let remoteURL = request.url {
            pendingResult?.fill(remoteURL)
            pendingResult = nil
        }
    }

    func urlSession(
        _ session: URLSession, downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(
            "TempDocs")
        let url = tempDirectory.appendingPathComponent(filename)

        try? FileManager.default.createDirectory(
            at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.removeItem(at: url)

        do {
            try FileManager.default.moveItem(at: location, to: url)
            localFileURL = url
            pendingResult?.fill(url)
            pendingResult = nil
        } catch {
            // If we encounter an error downloading the temp file, just return with the
            // original remote URL so it can still be shared as a web URL.
            if let remoteURL = request.url {
                pendingResult?.fill(remoteURL)
                pendingResult = nil
            }
        }
    }
}
