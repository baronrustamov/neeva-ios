// Copyright Neeva. All rights reserved.

import Apollo
import Combine
import Foundation

public struct SpaceID: Hashable, Identifiable {
    let value: String

    public var id: String { value }
}

public struct SpaceCommentData {
    public typealias Profile = GetSpacesDataQuery.Data.GetSpace.Space.Space.Comment.Profile
    public let id: String
    public let profile: Profile
    public let createdTs: String
    public let comment: String

    public init(id: String, profile: Profile, createdTs: String, comment: String) {
        self.id = id
        self.profile = profile
        self.createdTs = createdTs
        self.comment = comment
    }

    public var formattedRelativeTime: String {
        let originalDateFormatter = DateFormatter()
        originalDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        originalDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let convertedDate = originalDateFormatter.date(from: createdTs)
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        let relativeDate = formatter.localizedString(for: convertedDate!, relativeTo: Date())
        return relativeDate
    }
}

public struct SpaceEntityData {
    typealias SpaceEntity = GetSpacesDataQuery.Data.GetSpace.Space.Space.Entity.SpaceEntity
    typealias EntityRecipe = GetSpacesDataQuery.Data.GetSpace.Space.Space.Entity.SpaceEntity.Content
        .TypeSpecific.AsWeb.Web.Recipe
    typealias EntityRichEntity = GetSpacesDataQuery.Data.GetSpace.Space
        .Space.Entity.SpaceEntity.Content.TypeSpecific.AsRichEntity.RichEntity
    typealias EntityRetailProduct = GetSpacesDataQuery.Data.GetSpace.Space
        .Space.Entity.SpaceEntity.Content.TypeSpecific.AsWeb.Web.RetailerProduct
    typealias EntityProductRating = GetSpacesDataQuery.Data.GetSpace.Space
        .Space.Entity.SpaceEntity.Content.TypeSpecific.AsWeb.Web.RetailerProduct.Review
        .RatingSummary
    typealias EntityTechDoc = GetSpacesDataQuery.Data.GetSpace.Space
        .Space.Entity.SpaceEntity.Content.TypeSpecific.AsTechDoc.TechDoc
    typealias EntityNewsItem = GetSpacesDataQuery.Data.GetSpace.Space
        .Space.Entity.SpaceEntity.Content.TypeSpecific.AsNewsItem.NewsItem

    public let id: String
    public let url: URL?
    public let title: String?
    public let snippet: String?
    public let thumbnail: String?
    public let previewEntity: PreviewEntity

    public init(
        id: String, url: URL?, title: String?, snippet: String?,
        thumbnail: String?, previewEntity: PreviewEntity
    ) {
        self.id = id
        self.url = url
        self.title = title
        self.snippet = snippet
        self.thumbnail = thumbnail
        self.previewEntity = previewEntity
    }

    static func previewEntity(from entity: SpaceEntity) -> PreviewEntity {
        if let recipe = recipe(from: entity.content?.typeSpecific?.asWeb?.web?.recipes?.first) {
            return PreviewEntity.recipe(recipe)
        } else if let richEntity = richEntity(
            from: entity.content?.typeSpecific?.asRichEntity?.richEntity, with: entity.content?.id)
        {
            return PreviewEntity.richEntity(richEntity)
        } else if let retailProduct = retailProduct(
            from: entity.content?.typeSpecific?.asWeb?.web?.retailerProduct,
            with: entity.content?.actionUrl.addingPercentEncoding(
                withAllowedCharacters: .urlHostAllowed))
        {
            return PreviewEntity.retailProduct(retailProduct)
        } else if let techDoc = techDoc(
            from: entity.content?.typeSpecific?.asTechDoc?.techDoc,
            with: entity.content?.actionUrl.addingPercentEncoding(
                withAllowedCharacters: .urlHostAllowed))
        {
            return PreviewEntity.techDoc(techDoc)
        } else if let newsItem = newsItem(
            from: entity.content?.typeSpecific?.asNewsItem?.newsItem
        ) {
            return PreviewEntity.newsItem(newsItem)
        } else {
            return PreviewEntity.webPage
        }
    }

    private static func newsItem(from entity: EntityNewsItem?) -> NewsItem? {
        guard let entity = entity, let url = URL(string: entity.url) else {
            return nil
        }

        return NewsItem(
            title: entity.title, snippet: entity.snippet, url: url,
            thumbnailURL: URL(string: entity.thumbnailImage.url),
            providerName: entity.providerName, datePublished: entity.datePublished,
            faviconURL: URL(string: entity.favIconUrl ?? ""),
            domain: entity.domain)
    }

    private static func recipe(from entity: EntityRecipe?) -> Recipe? {
        guard let entity = entity, let title = entity.title, let imageURL = entity.imageUrl else {
            return nil
        }

        return Recipe(
            title: title, imageURL: imageURL, totalTime: entity.totalTime, prepTime: nil,
            yield: nil, ingredients: nil, instructions: nil,
            recipeRating: RecipeRating(
                maxStars: 0, recipeStars: entity.recipeRating?.recipeStars ?? 0,
                numReviews: entity.recipeRating?.numReviews ?? 0), reviews: nil,
            preference: .noPreference)
    }

    private static func richEntity(from entity: EntityRichEntity?, with id: String?) -> RichEntity?
    {
        guard let id = id, let entity = entity, let title = entity.title,
            let subtitle = entity.subTitle,
            let imageURL = URL(string: entity.images?.first?.thumbnailUrl ?? "")
        else {
            return nil
        }

        return RichEntity(id: id, title: title, description: subtitle, imageURL: imageURL)
    }

    private static func retailProduct(from entity: EntityRetailProduct?, with id: String?)
        -> RetailProduct?
    {
        guard let id = id, let entity = entity, let url = URL(string: entity.url ?? ""),
            let title = entity.name,
            let price = entity.priceHistory?.currentPrice
        else {
            return nil
        }

        return RetailProduct(
            id: id,
            url: url, title: title, description: entity.description ?? [], currentPrice: price,
            ratingSummary: productRating(from: entity.reviews?.ratingSummary))
    }

    private static func techDoc(from entity: EntityTechDoc?, with id: String?) -> TechDoc? {
        guard let id = id, let entity = entity, let title = entity.name else {
            return nil
        }

        let data = entity.sections?.first?.body?.data(using: String.Encoding.utf8)

        var attributedString = NSMutableAttributedString(string: "")
        if let data = data {
            do {
                attributedString = try NSMutableAttributedString(
                    data: data,
                    options: [
                        NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString
                            .DocumentType.html,
                        NSAttributedString.DocumentReadingOptionKey.characterEncoding: NSNumber(
                            value: String.Encoding.utf8.rawValue),
                    ], documentAttributes: nil)
            } catch let _ as NSError {
                Logger.browser.info("Already initialized to blank. Ignoring...")
            }
        }

        return TechDoc(id: id, title: title, body: attributedString)
    }

    private static func productRating(from rating: EntityProductRating?) -> ProductRating? {
        guard let rating = rating, let productStars = rating.rating?.productStars else {
            return nil
        }

        return ProductRating(numReviews: rating.numReviews, productStars: productStars)
    }
}

public class Space: Hashable, Identifiable {
    public typealias Acl = ListSpacesQuery.Data.ListSpace.Space.Space.Acl
    public let id: SpaceID
    public var name: String
    public var description: String?
    public var followers: Int?
    public let lastModifiedTs: String
    public let thumbnail: String?
    public let resultCount: Int
    public let isDefaultSpace: Bool
    public var isShared: Bool
    public var isPublic: Bool
    public let userACL: SpaceACLLevel
    public let acls: [Acl]

    init(
        id: SpaceID, name: String, description: String? = nil, followers: Int? = nil,
        lastModifiedTs: String, thumbnail: String?,
        resultCount: Int, isDefaultSpace: Bool, isShared: Bool, isPublic: Bool,
        userACL: SpaceACLLevel, acls: [Acl] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.followers = followers
        self.lastModifiedTs = lastModifiedTs
        self.thumbnail = thumbnail
        self.resultCount = resultCount
        self.isDefaultSpace = isDefaultSpace
        self.isShared = isShared
        self.isPublic = isPublic
        self.userACL = userACL
        self.acls = acls
    }

    public var url: URL {
        NeevaConstants.appSpacesURL / id.value
    }

    public var urlWithAddedItem: URL {
        url.withQueryParam("hid", value: contentData?.first?.id ?? "")
    }

    public var contentURLs: Set<URL>?
    public var contentData: [SpaceEntityData]?
    public var comments: [SpaceCommentData]?

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(lastModifiedTs)
    }
    public static func == (lhs: Space, rhs: Space) -> Bool {
        lhs.id == rhs.id && lhs.lastModifiedTs == rhs.lastModifiedTs
    }
}

// A store of all spaces data available to the client. Hides details of how the
// data is stored and fetched.
public class SpaceStore: ObservableObject {
    public static var shared = SpaceStore()
    public static var suggested = SpaceStore(
        suggestedIDs: [
            // From neeva.com/community
            "AvTLrA0-XxVpTsesZx_gRcDBxl4SE9tY6pgF9eNh",
            "XYJHMw5ptIlAot-1yln1MdLgSOoRsGzn1-b2C3GE",
            "gT01MM6Hkv7N7XkvQrUx2N44x-zjfkbzXlR44uX5",
            "Ok-XsoNeDNzu0uV6ziFFJ-XxH0oGAquIyxPhaweF",
            "WiF8e6LomHAnUNTudwzpCZ0i3dHsTtiaP14F6FcA",
            "v8JNVLpV2V_tRshYe87ZXoF2NfkVaMyDKaQImveS",
            "bG6jT2pnzrmdINzh9vY77wacBjawGfnUlc_V6D1P",
            "VSg5lqugMVgpyXiCDoQsuEBXbqrwYydDJkOMVSy9",
            "MwC3dgk3bbVSmB_AGPL0RHMkt-_Ejn5yjOV3sLTF",
            "Zt0o4Sj_7va3Uakw2V-n6MZ5YY6sVdLSRNcQkNSq",
            "wb6aqCBubAs9GHAZuq6ycBdzK38DdxpU5PAP9wWC",
            "brt5oi5afuen3lbh1ij0",
            "qyAaEMBS-1AZE_3RI-jnlAao6OvbbtT4e294zDM5",
            "zxrsTxErt66ZvoTG5FBEKG8yHiqiCpfpA4XWybrn",
            "P18WZHuqEJDnf7llLgmyOIhiLpwF-gLl3OlhT6sh",
            "B-ZzfqeytWS-n3YHKRi77h6Ore1kQ7EuojJIm4b7",
            "brogg3ipmtasecqj230g",
        ])

    private static var subscription: AnyCancellable? = nil

    private var suggestedSpaceIDs: [String]? = nil

    public init(suggestedIDs: [String]? = nil) {
        self.suggestedSpaceIDs = suggestedIDs
    }

    public static func createMock(_ spaces: [Space]) -> SpaceStore {
        let mock = SpaceStore()
        mock.allSpaces = spaces
        mock.disableRefresh = true
        return mock
    }

    public enum State {
        case ready
        case refreshing
        case failed(Error)
    }

    /// The current state of the `SpaceStore`.
    @Published public private(set) var state: State = .ready

    /// The current set of spaces.
    @Published public private(set) var allSpaces: [Space] = []
    /// The current set of editable spaces.
    public var editableSpaces: [Space] {
        allSpaces.filter { $0.userACL >= .edit }
    }

    private var disableRefresh = false

    private var urlToSpacesMap: [URL: [Space]] = [:]

    private var queuedRefresh = false
    public private(set) var updatedSpacesFromLastRefresh = [Space]()

    /// Use to query the set of spaces containing the given URL.
    func urlToSpaces(_ url: URL) -> [Space] {
        return urlToSpacesMap[url] ?? []
    }

    /// Use to query if `url` is part of the space specified by `spaceId`
    func urlInSpace(_ url: URL, spaceId: SpaceID) -> Bool {
        return urlToSpaces(url).contains { $0.id == spaceId }
    }

    public func urlInASpace(_ url: URL) -> Bool {
        return !urlToSpaces(url).isEmpty
    }

    /// Call to refresh the SpaceStore's copy of spaces data. Ignored if already refreshing.
    public func refresh() {
        if case .refreshing = state { return }
        if disableRefresh { return }
        state = .refreshing
        if let _ = suggestedSpaceIDs {
            fetchSuggestedSpaces()
            return
        }
        SpaceListController.getSpaces { result in
            switch result {
            case .success(let spaces):
                self.onUpdateSpaces(spaces)
            case .failure(let error):
                self.state = .failed(error)
            }
        }
    }

    public func refreshSpace(spaceID: String) {
        guard let space = allSpaces.first(where: { $0.id.id == spaceID }),
            let index = allSpaces.firstIndex(where: { $0.id.id == spaceID })
        else {
            return
        }
        if case .refreshing = state {
            queuedRefresh = true
            return
        }
        if disableRefresh { return }
        state = .refreshing
        fetch(spaces: [space])

        let indexSet: IndexSet = [index]
        allSpaces.move(fromOffsets: indexSet, toOffset: 0)
    }

    private func fetchSuggestedSpaces() {
        guard let ids = suggestedSpaceIDs else {
            return
        }

        GraphQLAPI.shared.isAnonymous = true
        SuggestedSpacesQueryController.getSpacesTitleInfo(spaceIds: ids) { result in
            switch result {
            case .success(let spaces):
                for space in spaces {
                    let fetchedSpace = Space(
                        id: SpaceID(value: space.id), name: space.name, lastModifiedTs: "",
                        thumbnail: space.thumbnail, resultCount: 1, isDefaultSpace: false,
                        isShared: false, isPublic: true, userACL: .publicView)
                    self.allSpaces.append(fetchedSpace)
                }
                self.state = .ready
            case .failure(let error):
                self.state = .failed(error)
            }
        }
        GraphQLAPI.shared.isAnonymous = false
    }

    public static func onRecommendedSpaceSelected(space: Space) {
        shared.allSpaces.append(space)
        SpacesDataQueryController.getSpacesData(spaceIds: [space.id.id]) { result in
            switch result {
            case .success:
                Logger.browser.info("Space followed")
            case .failure(let error):
                Logger.browser.error(error.localizedDescription)
            }
        }
    }

    public static func openSpace(spaceId: String, completion: @escaping () -> Void) {
        SpacesDataQueryController.getSpacesData(spaceIds: [spaceId]) { result in
            switch result {
            case .success:
                Logger.browser.info("Space followed")
                shared.refresh()
                subscription = SpaceStore.shared.$state.sink {
                    state in
                    if case .ready = state {
                        completion()
                        subscription?.cancel()
                    }
                }
            case .failure(let error):
                Logger.browser.error(error.localizedDescription)
            }
        }
    }

    private func onUpdateSpaces(_ spaces: [SpaceListController.Space]) {
        let oldSpaceMap: [SpaceID: Space] = Dictionary(
            uniqueKeysWithValues: allSpaces.map { ($0.id, $0) })

        // Clear to avoid holding stale data. Will be rebuilt below.
        urlToSpacesMap = [:]

        var spacesToFetch: [Space] = []

        var allSpaces = [Space]()
        // Build the set of spaces:
        for space in spaces {
            if let pageId = space.pageMetadata?.pageId,
                let space = space.space,
                let name = space.name,
                let lastModifiedTs = space.lastModifiedTs,
                let userAcl = space.userAcl?.acl
            {
                let spaceId = SpaceID(value: pageId)
                let newSpace = Space(
                    id: spaceId,
                    name: name,
                    lastModifiedTs: lastModifiedTs,
                    thumbnail: space.thumbnail ?? nil,
                    resultCount: space.resultCount ?? 0,
                    isDefaultSpace: space.isDefaultSpace ?? false,
                    isShared:
                        !(space.acl?.map(\.userId).filter { $0 != NeevaUserInfo.shared.id }.isEmpty
                        ?? true),
                    isPublic: space.hasPublicAcl ?? false,
                    userACL: userAcl,
                    acls: space.acl ?? []
                )

                /// Note, we avoid parsing `lastModifiedTs` here and instead just use it as
                /// an opaque identifier. If the value we have stored from last fetch differs
                /// from the current value, then we'll just refetch the URLs for the space.
                /// Otherwise, we can use our cached data.
                if let oldSpace = oldSpaceMap[spaceId],
                    let contentURLs = oldSpace.contentURLs,
                    let contentData = oldSpace.contentData,
                    let comments = oldSpace.comments,
                    space.lastModifiedTs == oldSpace.lastModifiedTs
                {
                    self.onUpdateSpaceURLs(
                        space: newSpace,
                        description: oldSpace.description,
                        followers: oldSpace.followers,
                        urls: contentURLs,
                        data: contentData,
                        comments: comments)
                } else {
                    spacesToFetch.append(newSpace)
                }

                allSpaces.append(newSpace)
            }
        }
        self.allSpaces = allSpaces

        if spacesToFetch.count > 0 {
            fetch(spaces: spacesToFetch)
        } else {
            self.updatedSpacesFromLastRefresh = []
            self.state = .ready
        }
    }

    private func fetch(spaces spacesToFetch: [Space]) {
        SpacesDataQueryController.getSpacesData(spaceIds: spacesToFetch.map(\.id.value)) {
            result in
            switch result {
            case .success(let spaces):
                for space in spaces {
                    /// Note, we could update the `lastModifiedTs` field here but that's
                    /// likely an unnecessary optimization. The window between now and
                    /// when ListSpaces returned is short, and the downside of having a
                    /// stale `lastModifiedTs` stored in our cache is minor.

                    self.onUpdateSpaceURLs(
                        space: spacesToFetch.first { $0.id.value == space.id }!,
                        description: space.description,
                        followers: space.followers,
                        urls: Set(
                            space.entities.filter { $0.url != nil }.reduce(into: [URL]()) {
                                $0.append($1.url!)
                            }),
                        data: space.entities,
                        comments: space.comments)
                }
                self.updatedSpacesFromLastRefresh = spacesToFetch
                self.state = .ready
                if self.queuedRefresh {
                    self.refresh()
                    self.queuedRefresh = false
                }
            case .failure(let error):
                self.state = .failed(error)
            }
        }
    }

    private func onUpdateSpaceURLs(
        space: Space, description: String?, followers: Int?,
        urls: Set<URL>, data: [SpaceEntityData], comments: [SpaceCommentData]
    ) {
        space.contentURLs = urls
        space.contentData = data
        space.comments = comments
        space.description = description
        space.followers = followers
        for url in urls {
            var spaces = urlToSpacesMap[url] ?? []
            spaces.append(space)
            urlToSpacesMap[url] = spaces
        }
    }
}
