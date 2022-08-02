/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import UIKit
import XCGLogger

private var log = Logger.storage

/// File-backed key-value image store. Images are considered immutable and uniquely
/// identified by the given keys. This class does not support updating the contents
/// of an existing image.
///
/// Use `updateAll` to specify the full set of images that should be saved, and use
/// `get` to fetch a single image at a time.
open class DiskImageStore {
    private let processor = BackgroundTaskProcessor(label: "DiskImageStore")
    private let files: FileAccessor
    private let filesDir: String
    private let quality: CGFloat
    private var keys: Set<String>

    required public init(files: FileAccessor, namespace: String, quality: Float) {
        self.files = files
        self.filesDir = try! files.getAndEnsureDirectory(namespace)
        self.quality = CGFloat(quality)

        // Build an in-memory set of keys from the existing images on disk.
        var keys = [String]()
        if let fileEnumerator = FileManager.default.enumerator(atPath: filesDir) {
            for file in fileEnumerator {
                keys.append(file as! String)
            }
        }
        self.keys = Set(keys)
    }

    /// Gets an image for the given key if it is in the store.
    open func get(_ key: String, completion: @escaping (UIImage?) -> Void) {
        processor.serialQueue.async {
            var result: UIImage? = nil
            var error: String? = nil

            if self.keys.contains(key) {
                let imagePath = URL(fileURLWithPath: self.filesDir).appendingPathComponent(key)
                if let data = try? Data(contentsOf: imagePath) {
                    if let image = UIImage.imageFromDataThreadSafe(data) {
                        result = image
                    } else {
                        error = "Invalid image data"
                    }
                } else {
                    error = "Could not read file"
                }
            } else {
                error = "Image not found"
            }

            if let error = error {
                log.error("\(error), for key: \(key)")
            }

            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    public struct Entry {
        let key: String
        let image: UIImage

        public init(key: String, image: UIImage) {
            self.key = key
            self.image = image
        }
    }

    /// Updates the store with the full set of entries that should be saved. Any
    /// entry that already exists (identified by `key`) will be skipped over w/o
    /// writing to the saved file, and any existing entries not referenced by
    /// `entries` will be deleted. Other new entries will be added.
    open func updateAll(_ entries: [Entry], extraKeysToKeep: Set<String> = []) {
        processor.performTask {
            var keysToKeep = extraKeysToKeep

            for entry in entries {
                keysToKeep.insert(entry.key)
                self.updateOne(key: entry.key, image: entry.image)
            }

            // Remove any files that are no longer referenced.
            self.clearExcluding(keysToKeep)
        }
    }

    /// Stores a single image.
    open func updateOne(key: String, image: UIImage) {
        // If the key is already known, then we assume the image file exists and
        // there is no need to do anymore work.
        if keys.contains(key) {
            return
        }

        let imageURL = URL(fileURLWithPath: filesDir).appendingPathComponent(key)
        if let data = image.jpegData(compressionQuality: quality)
            ?? image.writeJpegDataViaCGImage(compressionQuality: self.quality)
        {
            do {
                try data.write(to: imageURL, options: .noFileProtection)
                keys.insert(key)
            } catch {
                log.error("Unable to write image to disk: \(error), for key: \(key)")
            }
        } else {
            log.error("Unable to generate jpeg data, for key: \(key)")
        }
    }

    /// Clears all images from the store, excluding the given set of keys.
    private func clearExcluding(_ keysToKeep: Set<String>) {
        let keysToDelete = self.keys.subtracting(keysToKeep)

        for key in keysToDelete {
            let url = URL(fileURLWithPath: filesDir).appendingPathComponent(key)
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                log.warning(
                    "Failed to remove DiskImageStore item at \(url.absoluteString): \(error)")
            }
        }

        self.keys = self.keys.intersection(keysToKeep)
    }
}
