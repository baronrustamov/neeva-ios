// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import SDWebImageSwiftUI
import Shared
import SwiftUI
import UniformTypeIdentifiers

enum TabLocationViewUX {
    static let height: CGFloat = 42
    static let placeholder = Text("Search or enter address")
    static let textFieldOffset: CGFloat = 75
    static let animation = Animation.spring(response: 0.3)
}

struct OffsetModifier: ViewModifier {
    let x: CGFloat
    func body(content: Content) -> some View {
        content.offset(x: x, y: 0)
    }
}

struct TabLocationView: View {
    let onReload: () -> Void
    let onSubmit: (String) -> Void
    let onShare: (UIView) -> Void
    let onCancel: () -> Void

    @EnvironmentObject private var model: LocationViewModel
    @EnvironmentObject private var chromeModel: TabChromeModel
    @EnvironmentObject private var readerModeModel: ReaderModeModel
    @EnvironmentObject private var web3Model: Web3Model
    @EnvironmentObject private var queryModel: SearchQueryModel
    @EnvironmentObject private var trackingStatsModel: TrackingStatsViewModel

    @State private var isPressed = false

    @EnvironmentObject private var incognitoModel: IncognitoModel
    @Environment(\.colorScheme) private var colorScheme

    @State var token = 0
    @State var showReaderModeSettings: Bool = false

    private var copyAction: Action {
        Action("Copy", icon: .docOnDoc) {
            UIPasteboard.general.url = model.url
        }
    }
    private var pasteAction: Action {
        Action("Paste", icon: .docOnClipboard) {
            UIPasteboard.general.asyncString()
                .uponQueue(.main) {
                    if let query = $0.successValue as? String {
                        queryModel.value = query
                        chromeModel.setEditingLocation(to: true)
                    }
                }
        }
    }
    private var pasteAndGoAction: Action {
        Action("Paste & Go", icon: .docOnClipboardFill) {
            UIPasteboard.general.asyncString()
                .uponQueue(.main) { ($0.successValue as? String).map(onSubmit) }
        }
    }

    var body: some View {
        let backgroundColor: Color =
            incognitoModel.isIncognito
            ? isPressed ? .elevatedDarkBackground : .black
            : isPressed ? .tertiarySystemFill : .systemFill
        HStack(spacing: 11) {
            ZStack {
                Capsule().fill(backgroundColor)

                TabLocationAligner(transitionToEditing: chromeModel.isEditingLocation) {
                    LocationLabel(
                        url: model.url,
                        isSecure: readerModeModel.state == .active
                            ? readerModeModel.isOriginalTabSecure : model.isSecure
                    )
                } labelOverlay: { padding in
                    if !chromeModel.isEditingLocation {
                        LocationViewTouchHandler(
                            margins: padding,
                            isPressed: $isPressed,
                            url: model.url,
                            isSecure: model.isSecure,
                            background: backgroundColor,
                            onTap: {
                                if let query = SearchEngine.current.queryForLocationBar(
                                    from: model.url)
                                {
                                    queryModel.value = query
                                } else {
                                    // TODO: Decode punycode hostname.
                                    queryModel.value = model.url?.absoluteString ?? ""
                                }
                                chromeModel.setEditingLocation(to: true)
                            },
                            copyAction: copyAction,
                            pasteAction: pasteAction,
                            pasteAndGoAction: pasteAndGoAction
                        )
                    }
                } leading: {
                    if model.url?.scheme == "https" || model.url?.scheme == "http" {
                        if trackingStatsModel.numTrackers > 0 {
                            NotificationBadgeOverlay(
                                from: NotificationBadgeLocation.topRight,
                                count: trackingStatsModel.numTrackers,
                                value: trackingStatsModel.numTrackers == 1
                                    ? "1 Tracker Blocked"
                                    : "\(trackingStatsModel.numTrackers) Trackers Blocked",
                                content:
                                    LocationViewTrackingButton(
                                        currentDomain: model.url?.baseDomain ?? "")
                            ).frame(width: 80, alignment: .leading)
                        } else {
                            LocationViewTrackingButton(
                                currentDomain: model.url?.baseDomain ?? "")
                        }
                    }
                } trailing: {
                    Group {
                        if let url = model.url, !InternalURL.isValid(url: url) {
                            #if XYZ
                                if let dAppSession = web3Model.currentSession {
                                    SessionInfoButton(dAppSession: dAppSession)
                                } else if readerModeModel.state != .unavailable {
                                    readerButton
                                }
                            #else
                                if readerModeModel.state != .unavailable {
                                    readerButton
                                }
                            #endif

                            LocationViewShareButton(url: model.url, onTap: onShare)
                        }
                    }.transition(.opacity)
                }
                .opacity(chromeModel.isEditingLocation ? 0 : 1)
                .accessibilityHidden(chromeModel.isEditingLocation)

                HStack(spacing: 0) {
                    if chromeModel.isEditingLocation {
                        LocationTextFieldIcon(currentUrl: model.url)
                            .transition(.opacity)
                            .accessibilityHidden(true)
                        LocationEditView(
                            isEditing: Binding(
                                get: { chromeModel.isEditingLocation },
                                set: chromeModel.setEditingLocation(to:)), onSubmit: onSubmit
                        )
                        // force the view to be recreated each time edit mode is entered
                        .id(token)
                        .transition(
                            .modifier(
                                active: OffsetModifier(x: TabLocationViewUX.textFieldOffset),
                                identity: OffsetModifier(x: 0)
                            ).combined(with: .opacity))
                    }
                }
            }
            .frame(height: TabLocationViewUX.height)
            .colorScheme(incognitoModel.isIncognito ? .dark : colorScheme)
            .onChange(of: chromeModel.isEditingLocation) { isEditing in
                if !isEditing {
                    token += 1
                }
            }

            if chromeModel.isEditingLocation {
                Button {
                    onCancel()
                    chromeModel.setEditingLocation(to: false)
                } label: {
                    Text("Cancel")
                        .withFont(.bodyLarge)
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .accentColor(incognitoModel.isIncognito ? .label : .ui.adaptive.blue)
                .textButtonPointerEffect()
            }
        }
    }

    private var readerButton: some View {
        TabLocationBarButton(label: Symbol(.docPlaintext, label: "Reader Mode")) {
            if readerModeModel.state != .active {
                readerModeModel.enableReadingMode()
            } else {
                showReaderModeSettings = true
            }
        }
        .accessibilityLabel(
            Text(
                readerModeModel.state == .available
                    ? "Reader Mode"
                    : "Reading Mode Settings")
        )
        .foregroundColor(
            readerModeModel.state == .active ? .blue : .label
        )
        .frame(
            width: TabLocationViewUX.height,
            height: TabLocationViewUX.height
        )
        .presentAsPopover(
            isPresented: $showReaderModeSettings,
            dismissOnTransition: true
        ) {
            ReaderModePopover(disableReadingMode: {
                readerModeModel.disableReadingMode()
                showReaderModeSettings = false
            })
            .environmentObject(readerModeModel)
            .environmentObject(BrightnessModel())
            .environmentObject(
                TextSizeModel(
                    tab: readerModeModel.tabManager
                        .selectedTab!))
        }
    }
}

struct TabLocationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TabLocationView(
                onReload: {}, onSubmit: { _ in }, onShare: { _ in },
                onCancel: {}
            )
            .environmentObject(LocationViewModel(previewURL: nil, isSecure: true))
            .previewDisplayName("Placeholder")

            TabLocationView(
                onReload: {}, onSubmit: { _ in }, onShare: { _ in },
                onCancel: {}
            )
            .environmentObject(
                LocationViewModel(
                    previewURL: "http://vviii.verylong.verylong.subdomain.neeva.com", isSecure: true
                )
            )
            .previewDisplayName("Long domain")
            TabLocationView(
                onReload: {}, onSubmit: { _ in }, onShare: { _ in },
                onCancel: {}
            )
            .environmentObject(IncognitoModel(isIncognito: true))
            .environmentObject(
                LocationViewModel(previewURL: "https://neeva.com/asdf", isSecure: nil)
            )
            .previewDisplayName("Incognito")
            TabLocationView(
                onReload: {}, onSubmit: { _ in }, onShare: { _ in },
                onCancel: {}
            )
            .environmentObject(
                LocationViewModel(
                    previewURL: SearchEngine.current.searchURLForQuery(
                        "a long search query with words"), isSecure: true)
            )
            .previewDisplayName("Search")
            TabLocationView(
                onReload: {}, onSubmit: { _ in }, onShare: { _ in },
                onCancel: {}
            )
            .environmentObject(IncognitoModel(isIncognito: true))
            .environmentObject(
                LocationViewModel(previewURL: "ftp://someftpsite.com/dir/file.txt", isSecure: nil)
            )
            .previewDisplayName("Non-HTTP")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
