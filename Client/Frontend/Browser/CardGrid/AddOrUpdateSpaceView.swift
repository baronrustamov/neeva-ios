// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SDWebImageSwiftUI
import Shared
import SwiftUI

enum AddOrUpdateSpaceConfig {
    case addSpaceItem
    case updateSpaceItem(String)
    case updateSpace
}

struct AddOrUpdateSpaceContent: View {
    @Environment(\.hideOverlay) private var hideOverlay

    let space: Space
    let config: AddOrUpdateSpaceConfig
    let openMarkdownArticle: ((URL) -> Void)?

    var title: LocalizedStringKey {
        switch config {
        case .addSpaceItem:
            return "Add item"
        case .updateSpaceItem(_):
            return "Edit item"
        case .updateSpace:
            return "Update Space"
        }
    }

    init(space: Space, config: AddOrUpdateSpaceConfig, openMarkdownArticle: ((URL) -> Void)? = nil)
    {
        self.space = space
        self.config = config
        self.openMarkdownArticle = openMarkdownArticle
    }

    var body: some View {
        AddOrUpdateSpaceView(
            space: space, config: config, dismiss: hideOverlay,
            openMarkdownArticle: openMarkdownArticle
        )
        .overlayTitle(title: title)
    }
}

private enum FieldType: String, Hashable {
    case urlField = "URL"
    case titleField = "TITLE"
    case descriptionField = "DESCRIPTION"
}

@available(iOS 15.0, *)
private struct iOS15InputField: View {
    @FocusState private var isFocused: FieldType?

    let title: FieldType
    let bodyText: String
    @Binding var inputText: String

    private func textEditAccentColor(type: FieldType) -> Color {
        if type == isFocused {
            return .ui.adaptive.blue
        } else {
            return .quaternaryLabel
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.rawValue)
                .withFont(.headingXSmall)
                .foregroundColor(.secondaryLabel)

            if case .descriptionField = title {
                TextEditor(text: $inputText)
                    .withFont(unkerned: .bodyLarge)
                    .frame(
                        maxWidth: .infinity, minHeight: 80,
                        maxHeight: isFocused == title ? .infinity : 110
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    .focused($isFocused, equals: title)
                    .animation(.easeInOut)
            } else {
                TextField(bodyText, text: $inputText)
                    .withFont(unkerned: .bodyLarge)
                    .autocapitalization(title == .titleField ? .words : .none)
                    .disableAutocorrection(true)
                    .focused($isFocused, equals: title)
                    .accentColor(textEditAccentColor(type: title))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .roundedOuterBorder(cornerRadius: 12, color: textEditAccentColor(type: title), lineWidth: 1)
    }
}

private struct LegacyInputField: View {
    let title: FieldType
    let bodyText: String
    @Binding var inputText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.rawValue)
                .withFont(.headingXSmall)
                .foregroundColor(.secondaryLabel)

            if case .descriptionField = title {
                TextEditor(text: $inputText)
                    .withFont(unkerned: .bodyLarge)
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 110)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                TextField(bodyText, text: $inputText)
                    .withFont(unkerned: .bodyLarge)
                    .autocapitalization(title == .titleField ? .words : .none)
                    .disableAutocorrection(title != .titleField)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .roundedOuterBorder(cornerRadius: 12, color: .quaternaryLabel, lineWidth: 1)
    }
}

struct AddOrUpdateSpaceView: View {
    let space: Space
    let config: AddOrUpdateSpaceConfig
    let dismiss: () -> Void
    let openMarkdownArticle: () -> Void
    let thumbnailModel = CustomThumbnailModel()

    @EnvironmentObject var spaceModel: SpaceCardModel
    @State var descriptionText: String
    @State var titleText: String
    @State var urlText: String

    var shouldShowURL: Bool {
        guard case .addSpaceItem = config else {
            return false
        }
        return true
    }

    init(
        space: Space, config: AddOrUpdateSpaceConfig, dismiss: @escaping () -> Void,
        openMarkdownArticle: ((URL) -> Void)?
    ) {
        self.space = space
        self.config = config
        self.dismiss = dismiss
        self.openMarkdownArticle = {
            dismiss()
            openMarkdownArticle?(
                URL(
                    string:
                        "https://help.neeva.com/hc/en-us/articles/4412938013203-Markdown-support-in-Spaces"
                )!)
        }

        switch config {
        case .addSpaceItem:
            self.titleText = ""
            self.urlText = ""
            self.descriptionText = ""
        case .updateSpaceItem(let entityID):
            let data = space.contentData?.first(where: { $0.id == entityID })
            self.titleText = data?.title ?? ""
            self.urlText = data?.url?.absoluteString ?? ""
            self.descriptionText = data?.snippet ?? ""
        case .updateSpace:
            self.titleText = space.name
            self.urlText = ""
            self.descriptionText = space.description ?? ""
        }
    }

    private func inputField(title: FieldType, bodyText: String, inputText: Binding<String>)
        -> some View
    {
        Group {
            if #available(iOS 15.0, *) {
                iOS15InputField(title: title, bodyText: bodyText, inputText: inputText)
            } else {
                LegacyInputField(title: title, bodyText: bodyText, inputText: inputText)
            }
        }
    }

    var body: some View {
        ScrollView {
            GroupedStack {
                inputField(
                    title: .titleField, bodyText: "Please provide a title", inputText: $titleText
                ).modifier(TextFieldBackgroundModifier())
                    .accessibilityIdentifier("addOrUpdateSpaceTitle")

                ZStack(alignment: .topTrailing) {
                    inputField(
                        title: .descriptionField,
                        bodyText: "Please provide a description",
                        inputText: $descriptionText
                    )
                    .onAppear {
                        UITextView.appearance().backgroundColor = .systemBackground.elevated
                    }
                    .modifier(TextFieldBackgroundModifier())
                    .accessibilityIdentifier("addOrUpdateSpaceDescription")

                    Button {
                        openMarkdownArticle()
                    } label: {
                        Symbol(decorative: .rectangleAndPencilAndEllipsis)
                            .padding(.horizontal, 5)
                            .padding(.top, 8)
                            .foregroundColor(Color.secondary)
                            .scaleEffect(0.8)
                    }
                }

                if let url = URL(string: urlText),
                    let thumbnails = spaceModel.thumbnailURLCandidates[url],
                    thumbnailModel.showing
                {
                    CustomThumbnailPicker(
                        thumbnails: thumbnails, model: thumbnailModel
                    )
                } else if case .updateSpace = config, let details = spaceModel.detailedSpace {
                    SpaceThumbnailPicker(spaceDetails: details, model: thumbnailModel)
                }
                if shouldShowURL {
                    inputField(
                        title: .urlField, bodyText: "Add a URL to your new item (optional)",
                        inputText: $urlText
                    ).modifier(TextFieldBackgroundModifier())
                        .accessibilityIdentifier("addOrUpdateSpaceUrl")
                }
                Button(
                    action: {
                        switch config {
                        case .addSpaceItem:
                            let data = SpaceEntityData(
                                id: UUID().uuidString,
                                url: URL(string: urlText),
                                title: titleText,
                                snippet: descriptionText,
                                thumbnail: nil,
                                isPinned: false,
                                previewEntity: .webPage)
                            // modify target spaceCardDetail's Data and signal changes
                            space.contentData?.insert(data, at: 0)
                            spaceModel.add(
                                spaceID: space.id.id, url: urlText,
                                title: titleText, description: descriptionText)
                            spaceModel.detailedSpace?.updateDetails()
                        case .updateSpaceItem(let entityID):
                            guard
                                let oldData =
                                    (space.contentData?.first(where: { $0.id == entityID })),
                                let index =
                                    (space.contentData?.firstIndex(where: { $0.id == entityID }))
                            else {
                                return
                            }
                            let newData = SpaceEntityData(
                                id: oldData.id,
                                url: oldData.url,
                                title: titleText,
                                snippet: descriptionText,
                                thumbnail: thumbnailModel.selectedThumbnail?.absoluteString
                                    ?? oldData.thumbnail,
                                isPinned: oldData.isPinned,
                                previewEntity: oldData.previewEntity)
                            space.contentData?.replaceSubrange(
                                index..<(index + 1), with: [newData])
                            spaceModel.detailedSpace?.allDetails.replaceSubrange(
                                index..<(index + 1),
                                with: [SpaceEntityThumbnail(data: newData, spaceID: space.id.id)])
                            spaceModel.updateSpaceEntity(
                                spaceID: space.id.id, entityID: entityID,
                                title: titleText, snippet: descriptionText,
                                thumbnail: thumbnailModel.selectedThumbnail?.absoluteString)
                            thumbnailModel.thumbnailData = []
                            spaceModel.detailedSpace?.updateDetails()
                        case .updateSpace:
                            var thumbnail: String? = nil
                            if let id = thumbnailModel.selectedSpaceThumbnailEntityID {
                                thumbnail =
                                    space.contentData?.first(where: { $0.id == id })?.thumbnail
                            } else if let thumbnailData = thumbnailModel.selectedThumbnail?
                                .absoluteString
                            {
                                thumbnail = thumbnailData
                            }
                            spaceModel.updateSpaceHeader(
                                space: space, title: titleText,
                                description: descriptionText, thumbnail: thumbnail)
                        }
                        dismiss()
                    },
                    label: {
                        Text("Save")
                            .withFont(.labelLarge)
                            .frame(maxWidth: .infinity)
                            .clipShape(Capsule())
                    }
                )
                .buttonStyle(.neeva(.primary))
                .padding(.vertical, 16)
            }.onAppear {
                thumbnailModel.showing = true
            }.onDisappear {
                thumbnailModel.showing = false
            }
        }

    }
}

struct TextFieldBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color(UIColor.systemBackground.elevated))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
