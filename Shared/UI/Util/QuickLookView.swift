// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import QuickLook
import SwiftUI

/// A subclass of `QLPreviewController` that forces a “Revert” button into the toolbar, replacing the share button.
class CustomPreviewController: QLPreviewController {
    var didReset: (() -> Void)!

    override var toolbarItems: [UIBarButtonItem]? {
        get {
            [
                .flexibleSpace(),
                UIBarButtonItem(title: "Revert", style: .plain) { item in
                    // title from the Photos app Revert button
                    let confirmation = UIAlertController(
                        title:
                            "Revert to original will remove all edits made to this screenshot. This action cannot be undone.",
                        message: nil, preferredStyle: .actionSheet)
                    confirmation.addAction(
                        UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    confirmation.addAction(
                        UIAlertAction(
                            title: "Revert to Original", style: .destructive,
                            handler: { _ in
                                self.didReset()
                                self.reloadData()
                            }))
                    confirmation.popoverPresentationController?.barButtonItem = item
                    self.navigationController!.present(
                        confirmation, animated: true, completion: nil)
                },
            ]
        }
        set { /* your attempts to force a share button into the toolbar have been thwarted */  }
    }
}

struct QuickLookView: ViewControllerWrapper {
    /// The image to display. The binding will be modified whenever the user edits the image.
    @Binding var image: UIImage
    /// The original image to revert to when requested.
    let original: UIImage

    init(image: Binding<UIImage>, original: UIImage) {
        self._image = image
        self.original = original
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(image: $image)
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = CustomPreviewController()
        vc.didReset = { image = original }
        vc.dataSource = context.coordinator
        vc.delegate = context.coordinator
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            closure: { _ in
                vc.dismiss(animated: true, completion: nil)
            })
        let nav = UINavigationController(rootViewController: vc)
        return nav
    }

    func updateUIViewController(_ vc: UINavigationController, context: Context) {
        context.coordinator.image = $image
        (vc.viewControllers.first! as! QLPreviewController).reloadData()
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
        @Environment(\.onOpenURL) var onOpenURL
        var image: Binding<UIImage>

        fileprivate init(image: Binding<UIImage>) {
            self.image = image
        }

        // MARK: - QLPreviewControllerDataSource

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int)
            -> QLPreviewItem
        {
            image.wrappedValue
        }

        // MARK: - QLPreviewControllerDelegate

        func previewController(
            _ controller: QLPreviewController, shouldOpen url: URL, for item: QLPreviewItem
        ) -> Bool {
            onOpenURL(url)
            return false
        }
        func previewController(
            _ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem
        ) -> QLPreviewItemEditingMode {
            .createCopy
        }
        func previewController(
            _ controller: QLPreviewController, didSaveEditedCopyOf previewItem: QLPreviewItem,
            at url: URL
        ) {
            if let data = try? Data(contentsOf: url),
                let image = UIImage(data: data)
            {
                self.image.wrappedValue = image
            }
        }
    }
}

extension UIImage: QLPreviewItem {
    /// saves the image to a temporary directory so it can be edited.
    public var previewItemURL: URL? {
        guard
            let tempDir = try? FileManager.default.url(
                for: .itemReplacementDirectory,
                in: .userDomainMask,
                appropriateFor: Bundle.main.bundleURL,
                create: true
            )
        else { return nil }
        let result = tempDir.appendingPathComponent("image.png")
        if let _ = try? self.pngData()?.write(to: result) {
            return result
        }
        return nil
    }
    public var previewItemTitle: String? {
        ""
    }
}
