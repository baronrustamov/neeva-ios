// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Apollo
import Combine

public class CreateSpaceRequest: MutationRequest<CreateSpaceMutation> {
    public init(name: String) {
        super.init(mutation: CreateSpaceMutation(name: name))
    }
}

public class DeleteSpaceRequest: MutationRequest<DeleteSpaceMutation> {
    public init(spaceID: String) {
        super.init(mutation: DeleteSpaceMutation(input: DeleteSpaceInput(id: spaceID)))
    }
}

public class DeleteGeneratorRequest: MutationRequest<DeleteSpaceGeneratorMutation> {
    public init(spaceID: String, generatorID: String) {
        super.init(
            mutation: DeleteSpaceGeneratorMutation(
                input: DeleteSpaceGeneratorInput(spaceId: spaceID, generatorId: generatorID)))
    }
}

public class UnfollowSpaceRequest: MutationRequest<LeaveSpaceMutation> {
    public init(spaceID: String) {
        super.init(mutation: LeaveSpaceMutation(input: LeaveSpaceInput(id: spaceID)))
    }
}

public class UpdateSpaceRequest: MutationRequest<UpdateSpaceMutation> {
    public init(
        spaceID: String, title: String,
        description: String? = nil, thumbnail: String? = nil
    ) {
        super.init(
            mutation: UpdateSpaceMutation(
                input: UpdateSpaceInput(
                    id: spaceID, name: title,
                    description: description, thumbnail: thumbnail)))
    }
}

public class ClaimGeneratedItem: MutationRequest<ClaimGeneratedItemMutation> {
    public init(spaceID: String, entityID: String) {
        super.init(
            mutation: ClaimGeneratedItemMutation(
                input: ClaimGeneratedItemInput(spaceId: spaceID, resultId: entityID)))
    }
}

public class AddSpaceCommentRequest: MutationRequest<AddSpaceCommentMutation> {
    public init(spaceID: String, comment: String) {
        super.init(
            mutation: AddSpaceCommentMutation(
                input: AddSpaceCommentInput(spaceId: spaceID, comment: comment)))
    }
}

public class AddPublicACLRequest: MutationRequest<AddSpacePublicAclMutation> {
    public init(spaceID: String) {
        super.init(mutation: AddSpacePublicAclMutation(input: AddSpacePublicACLInput(id: spaceID)))
    }
}

public class DeletePublicACLRequest: MutationRequest<DeleteSpacePublicAclMutation> {
    public init(spaceID: String) {
        super.init(
            mutation: DeleteSpacePublicAclMutation(input: DeleteSpacePublicACLInput(id: spaceID)))
    }
}

public class AddSoloACLsRequest: MutationRequest<AddSpaceSoloAcLsMutation> {
    public init(spaceID: String, emails: [String], acl: SpaceACLLevel, note: String) {
        super.init(
            mutation: AddSpaceSoloAcLsMutation(
                input: AddSpaceSoloACLsInput(
                    id: spaceID, shareWith: emails.map { SpaceEmailACL(email: $0, acl: acl) },
                    note: note)))
    }
}

public class DeleteSpaceItemsRequest: MutationRequest<BatchDeleteSpaceResultMutation> {
    public init(spaceID: String, ids: [String]) {
        super.init(
            mutation: BatchDeleteSpaceResultMutation(
                input: BatchDeleteSpaceResultInput(
                    spaceId: spaceID, resultIDs: ids)))
    }
}

public class UpdateSpaceEntityRequest: MutationRequest<UpdateSpaceEntityDisplayDataMutation> {
    public init(
        spaceID: String, entityID: String, title: String, snippet: String?, thumbnail: String?
    ) {
        super.init(
            mutation: UpdateSpaceEntityDisplayDataMutation(
                input: UpdateSpaceEntityDisplayDataInput(
                    spaceId: spaceID, resultId: entityID, title: title, snippet: snippet,
                    thumbnail: thumbnail)))
    }
}

public class ReorderSpaceRequest: MutationRequest<SetSpaceDetailPageSortOrderMutation> {
    public init(spaceID: String, ids: [String]) {
        super.init(
            mutation: SetSpaceDetailPageSortOrderMutation(
                input: SetSpaceDetailPageSortOrderInput(
                    spaceId: spaceID, attribute: nil, sortOrderType: .custom,
                    customSortOrder: CustomSortOrderInput(resultIDs: ids))))
    }
}

public class AddToSpaceWithURLRequest: MutationRequest<AddToSpaceMutation> {
    public init(spaceID: String, url: String, title: String, description: String?) {
        super.init(
            mutation: AddToSpaceMutation(
                input: AddSpaceResultByURLInput(
                    spaceId: spaceID, url: url, title: title,
                    data: description, mediaType: "text/plain")))
    }
}

public class UpdateProfileRequest: MutationRequest<UpdateUserProfileMutation> {
    public init(firstName: String, lastName: String) {
        super.init(
            mutation: UpdateUserProfileMutation(
                input: UpdateUserProfileInput(firstName: firstName, lastName: lastName)))
    }
}
