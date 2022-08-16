// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Need this wrapper because Popover from SwiftUI will display as an
// overlay sheet on mobile, it will only display the arrow popover style
// on larger screen(tablet)
//
// See also:
// https://stackoverflow.com/questions/58834809/change-popover-size-in-swiftui/60077135#60077135

import Foundation
import SwiftUI

// To make signatures clean, this needs to be outside of the generic type WithPopover
enum WithPopoverColorMode {
    case staticBackground(UIColor)
    case dyanmicBackground(UIColor, UIColor)

    static let defaultStatic: Self = .staticBackground(.Tour.Background.lightVariant)
    static let defaultDynamic: Self = .dyanmicBackground(
        .Tour.Background.lightVariant, .Tour.Background.darkVariant)
}

struct WithPopover<Content: View, PopoverContent: View>: View {

    @Binding var showPopover: Bool
    var popoverSize: CGSize?
    let content: () -> Content
    let popoverContent: () -> PopoverContent
    let backgroundMode: WithPopoverColorMode

    init(
        showPopover: Binding<Bool>,
        popoverSize: CGSize? = nil,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder popoverContent: @escaping () -> PopoverContent,
        backgroundMode: WithPopoverColorMode
    ) {
        self._showPopover = showPopover
        self.popoverSize = popoverSize
        self.content = content
        self.popoverContent = popoverContent
        self.backgroundMode = backgroundMode
    }

    init(
        showPopover: Binding<Bool>,
        popoverSize: CGSize? = nil,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder popoverContent: @escaping () -> PopoverContent,
        staticColorMode: Bool
    ) {
        self._showPopover = showPopover
        self.popoverSize = popoverSize
        self.content = content
        self.popoverContent = popoverContent
        self.backgroundMode = staticColorMode ? .defaultStatic : .defaultDynamic
    }

    var body: some View {
        content()
            .if(showPopover) { view in
                view
                    .background(
                        Wrapper(
                            showPopover: $showPopover, popoverSize: popoverSize,
                            popoverContent: popoverContent, backgroundMode: backgroundMode
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    )
            }
    }

    struct Wrapper<PopoverContent: View>: UIViewControllerRepresentable {

        @Binding var showPopover: Bool
        let popoverSize: CGSize?
        let popoverContent: () -> PopoverContent
        let backgroundMode: WithPopoverColorMode

        func makeUIViewController(
            context: UIViewControllerRepresentableContext<Wrapper<PopoverContent>>
        ) -> WrapperViewController<PopoverContent> {
            return WrapperViewController(
                popoverSize: popoverSize,
                popoverContent: popoverContent,
                backgroundMode: self.backgroundMode
            ) {
                self.showPopover = false
            }
        }

        func updateUIViewController(
            _ uiViewController: WrapperViewController<PopoverContent>,
            context: UIViewControllerRepresentableContext<Wrapper<PopoverContent>>
        ) {
            uiViewController.updateSize(popoverSize)

            if showPopover {
                uiViewController.showPopover()
            } else {
                uiViewController.hidePopover()
            }
        }
    }

    class WrapperViewController<PopoverContent: View>: UIViewController,
        UIPopoverPresentationControllerDelegate
    {

        var popoverSize: CGSize?
        let popoverContent: () -> PopoverContent
        let onDismiss: () -> Void
        let backgroundMode: WithPopoverColorMode
        var popoverVC: UIViewController?

        var isDarkMode: Bool {
            self.traitCollection.userInterfaceStyle == .dark
        }

        required init?(coder: NSCoder) { fatalError("") }
        init(
            popoverSize: CGSize?,
            popoverContent: @escaping () -> PopoverContent,
            backgroundMode: WithPopoverColorMode,
            onDismiss: @escaping () -> Void
        ) {
            self.popoverSize = popoverSize
            self.popoverContent = popoverContent
            self.onDismiss = onDismiss
            self.backgroundMode = backgroundMode
            super.init(nibName: nil, bundle: nil)
        }

        override func viewDidLoad() {
            super.viewDidLoad()
        }

        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)

            setColors(vc: popoverVC)
        }

        func showPopover() {
            guard popoverVC == nil else { return }
            let vc = UIHostingController(rootView: popoverContent())
            if let size = popoverSize { vc.preferredContentSize = size }
            vc.modalPresentationStyle = UIModalPresentationStyle.popover
            setColors(vc: vc)
            if let popover = vc.popoverPresentationController {
                popover.sourceView = view
                popover.delegate = self
            }
            popoverVC = vc

            // when in landscape mode, menu is shown using a popover
            // delay tour popover being shown to prevent view is not in the window hierarchy complain
            let delay = SceneDelegate.getBVC(for: view).chromeModel.inlineToolbar ? 0.5 : 0

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.present(vc, animated: true, completion: nil)
            }
        }

        func hidePopover() {
            guard let vc = popoverVC, !vc.isBeingDismissed else { return }
            vc.dismiss(animated: true, completion: nil)
            popoverVC = nil
        }

        func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
            popoverVC = nil
            self.onDismiss()
        }

        func updateSize(_ size: CGSize?) {
            self.popoverSize = size
            if let vc = popoverVC, let size = size {
                vc.preferredContentSize = size
            }
        }

        func adaptivePresentationStyle(for controller: UIPresentationController)
            -> UIModalPresentationStyle
        {
            return .none
        }

        func setColors(vc: UIViewController?) {
            guard let vc = vc else {
                return
            }
            switch backgroundMode {
            case .staticBackground(let color):
                vc.view.backgroundColor = color
            case .dyanmicBackground(let light, let dark):
                vc.view.backgroundColor = isDarkMode ? dark : light
            }
        }
    }
}
