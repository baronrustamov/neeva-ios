// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import Storage
import SwiftUI

struct SpaceListContentView: View {

    @Default(.showDescriptions) var showDescriptions
    @State private var isPressed: Bool = false
    @EnvironmentObject var spaceCardModel: SpaceCardModel
    let details: SpaceEntityThumbnail
    let editSpaceItem: () -> Void
    let onSelected: () -> Void

    var shouldHighlightAsUpdated: Bool {
        guard details.manager.id.id == SpaceStore.promotionalSpaceId else {
            return false
        }
        return spaceCardModel.updatedItemIDs.contains(details.id)
    }

    var titleToDisplay: String {
        switch details.data.previewEntity {
        case .richEntity(let richEntity):
            return richEntity.title
        case .retailProduct(let product):
            return product.title
        case .techDoc(let doc):
            return doc.title
        case .newsItem(let newsItem):
            return newsItem.title
        case .recipe(let recipe):
            return recipe.title
        case .webPage, .spaceLink:
            return details.title
        }
    }

    var snippetToDisplay: String? {
        switch details.data.previewEntity {
        case .richEntity(let richEntity):
            return richEntity.description
        case .retailProduct(let product):
            return details.description ?? product.description.first
        case .newsItem(let newsItem):
            return newsItem.formattedDatePublished.capitalized + " - " + newsItem.snippet
        case .recipe(_):
            return details.description
        case .techDoc(let doc):
            return doc.body?.string
        default:
            let searchPrefix = "](@"
            if let description = details.description, description.contains(searchPrefix) {
                let index = description.firstIndex(of: "@")
                var substring = description.suffix(from: index!)
                guard let endIndex = substring.firstIndex(of: ")") else {
                    return description
                }
                substring = substring[..<endIndex]
                return description.replacingOccurrences(
                    of: substring,
                    with: SearchEngine.current.searchURLForQuery(String(substring))!.absoluteString)
            }

            return details.description
        }
    }

    var socialURL: URL? {
        guard SocialInfoType(rawValue: details.data.url?.baseDomain ?? "") != nil else {
            return nil
        }

        return details.data.url
    }

    private func getLogCounterAttributesForSpaceEntities(details: SpaceEntityThumbnail?)
        -> [ClientLogCounterAttribute]
    {
        var attributes = EnvironmentHelper.shared.getAttributes()
        attributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SpacesAttribute.isPublic,
                value: String(details?.manager.isPublic ?? false)))
        if details?.isSharedPublic == true {
            attributes.append(
                ClientLogCounterAttribute(
                    key: LogConfig.SpacesAttribute.spaceID,
                    value: String(details?.spaceID ?? "")))
            attributes.append(
                ClientLogCounterAttribute(
                    key: LogConfig.SpacesAttribute.spaceEntityID,
                    value: String(details?.id ?? "")))
        }
        attributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SpacesAttribute.isShared,
                value: String(details?.manager.isShared ?? false)))
        attributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SpacesAttribute.numberOfSpaceEntities,
                value: String(details?.manager.contentData?.count ?? 1)
            )

        )
        return attributes
    }

    var body: some View {
        Button {
            onSelected()
            ClientLogger.shared.logCounter(
                .SpacesDetailEntityClicked,
                attributes: getLogCounterAttributesForSpaceEntities(details: details))
        } label: {
            if details.isImage, let url = details.data.url {
                SpaceImageEntityView(
                    url: url,
                    details: details
                )
            } else {
                VStack(spacing: SpaceViewUX.ItemPadding) {
                    HStack(alignment: .top, spacing: SpaceViewUX.ItemPadding) {
                        SpaceEntityThumbnailView(
                            details: details
                        )
                        SpaceEntitySummaryView(
                            title: titleToDisplay,
                            snippetToDisplay: snippetToDisplay,
                            previewEntity: details.data.previewEntity,
                            url: details.data.url,
                            socialURL: socialURL,
                            details: details
                        )
                    }
                    SpaceEntityDescriptionView(
                        canEdit: details.manager.ACL >= .edit,
                        previewEntity: details.data.previewEntity,
                        snippetToDisplay: snippetToDisplay,
                        onEditSpaceItem: editSpaceItem
                    )
                }
            }
        }
        .buttonStyle(.reportsPresses(to: $isPressed))
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            shouldHighlightAsUpdated
                ? Color.ui.adaptive.blue.opacity(0.1) : Color.DefaultBackground)
        Spacer(minLength: 0)
    }

}
