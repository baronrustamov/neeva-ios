// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Apollo
import Combine

public class CreateSpaceRequest: MutationRequest<CreateSpaceMutation> {
    public init(name: String, testMode: Bool = false) {
        super.init(mutation: CreateSpaceMutation(name: name), testMode: testMode)
    }
}

public class DeleteSpaceRequest: MutationRequest<DeleteSpaceMutation> {
    public init(spaceID: String, testMode: Bool = false) {
        super.init(
            mutation: DeleteSpaceMutation(input: DeleteSpaceInput(id: spaceID)), testMode: testMode)
    }
}

public class DeleteGeneratorRequest: MutationRequest<DeleteSpaceGeneratorMutation> {
    public init(spaceID: String, generatorID: String, testMode: Bool = false) {
        super.init(
            mutation: DeleteSpaceGeneratorMutation(
                input: DeleteSpaceGeneratorInput(spaceId: spaceID, generatorId: generatorID)),
            testMode: testMode)
    }
}

public class UnfollowSpaceRequest: MutationRequest<LeaveSpaceMutation> {
    public init(spaceID: String, testMode: Bool = false) {
        super.init(
            mutation: LeaveSpaceMutation(input: LeaveSpaceInput(id: spaceID)), testMode: testMode)
    }
}

public class UpdateSpaceRequest: MutationRequest<UpdateSpaceMutation> {
    public init(
        spaceID: String, title: String,
        description: String? = nil, thumbnail: String? = nil, testMode: Bool = false
    ) {
        super.init(
            mutation: UpdateSpaceMutation(
                input: UpdateSpaceInput(
                    id: spaceID, name: title,
                    description: description, thumbnail: thumbnail)), testMode: testMode)
    }
}

public class ClaimGeneratedItem: MutationRequest<ClaimGeneratedItemMutation> {
    public init(spaceID: String, entityID: String, testMode: Bool = false) {
        super.init(
            mutation: ClaimGeneratedItemMutation(
                input: ClaimGeneratedItemInput(spaceId: spaceID, resultId: entityID)),
            testMode: testMode)
    }
}

public class AddSpaceCommentRequest: MutationRequest<AddSpaceCommentMutation> {
    public init(spaceID: String, comment: String, testMode: Bool = false) {
        super.init(
            mutation: AddSpaceCommentMutation(
                input: AddSpaceCommentInput(spaceId: spaceID, comment: comment)), testMode: testMode
        )
    }
}

public class AddPublicACLRequest: MutationRequest<AddSpacePublicAclMutation> {
    public init(spaceID: String, testMode: Bool = false) {
        super.init(
            mutation: AddSpacePublicAclMutation(input: AddSpacePublicACLInput(id: spaceID)),
            testMode: testMode)
    }
}

public class DeletePublicACLRequest: MutationRequest<DeleteSpacePublicAclMutation> {
    public init(spaceID: String, testMode: Bool = false) {
        super.init(
            mutation: DeleteSpacePublicAclMutation(input: DeleteSpacePublicACLInput(id: spaceID)),
            testMode: testMode)
    }
}

public class AddSoloACLsRequest: MutationRequest<AddSpaceSoloAcLsMutation> {
    public init(
        spaceID: String, emails: [String], acl: SpaceACLLevel, note: String, testMode: Bool = false
    ) {
        super.init(
            mutation: AddSpaceSoloAcLsMutation(
                input: AddSpaceSoloACLsInput(
                    id: spaceID, shareWith: emails.map { SpaceEmailACL(email: $0, acl: acl) },
                    note: note)), testMode: testMode)
    }
}

public class DeleteSpaceItemsRequest: MutationRequest<BatchDeleteSpaceResultMutation> {
    public init(spaceID: String, ids: [String], testMode: Bool = false) {
        super.init(
            mutation: BatchDeleteSpaceResultMutation(
                input: BatchDeleteSpaceResultInput(
                    spaceId: spaceID, resultIDs: ids)), testMode: testMode)
    }
}

public class UpdateSpaceEntityRequest: MutationRequest<UpdateSpaceEntityDisplayDataMutation> {
    public init(
        spaceID: String, entityID: String, title: String, snippet: String?, thumbnail: String?,
        testMode: Bool = false
    ) {
        super.init(
            mutation: UpdateSpaceEntityDisplayDataMutation(
                input: UpdateSpaceEntityDisplayDataInput(
                    spaceId: spaceID, resultId: entityID, title: title, snippet: snippet,
                    thumbnail: thumbnail)), testMode: testMode)
    }
}

public class ReorderSpaceRequest: MutationRequest<SetSpaceDetailPageSortOrderMutation> {
    public init(spaceID: String, ids: [String], testMode: Bool = false) {
        super.init(
            mutation: SetSpaceDetailPageSortOrderMutation(
                input: SetSpaceDetailPageSortOrderInput(
                    spaceId: spaceID, attribute: nil, sortOrderType: .custom,
                    customSortOrder: CustomSortOrderInput(resultIDs: ids))), testMode: testMode)
    }
}

public class AddToSpaceWithURLRequest: MutationRequest<AddToSpaceMutation> {
    public init(
        spaceID: String, url: String, title: String, description: String?, testMode: Bool = false
    ) {
        super.init(
            mutation: AddToSpaceMutation(
                input: AddSpaceResultByURLInput(
                    spaceId: spaceID, url: url, title: title,
                    data: description, mediaType: "text/plain")), testMode: testMode)
    }
}

public class UpdateProfileRequest: MutationRequest<UpdateUserProfileMutation> {
    public init(firstName: String, lastName: String, testMode: Bool = false) {
        super.init(
            mutation: UpdateUserProfileMutation(
                input: UpdateUserProfileInput(firstName: firstName, lastName: lastName)),
            testMode: testMode)
    }
}

public class PinSpaceRequest: MutationRequest<PinSpaceMutation> {
    public init(spaceId: String, isPinned: Bool, testMode: Bool = false) {
        super.init(
            mutation: PinSpaceMutation(input: PinSpaceInput(id: spaceId, isPinned: isPinned)),
            testMode: testMode)
    }
}
