// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// UserFlagStore represents a set of flags stored on the server.
/// Flags are booleans. If present, then they are considered set,
/// which evaluate to true. Otherwise they are considered un-set,
/// which evaluate to false.
///
/// Flags are fetched when the app started, but can be updated
/// for the lifetime of the app
public class UserFlagStore: ObservableObject {
    public static var shared = UserFlagStore()

    public enum State {
        case unset
        case ready
        case refreshing
        case sending
    }

    public enum UserFlag: String, CaseIterable {
        case dismissedRatingPromo = "DismissedRatingPromo"
    }

    @Published public private(set) var state: State = .unset
    @Published public private(set) var userFlags: Set<UserFlag>

    public init(userFlags: Set<UserFlag> = []) {
        self.userFlags = userFlags
    }

    // refetching all user flags
    public func refresh() {
        if case .refreshing = state { return }
        state = .refreshing
        UserInfoProvider.shared.fetch { result in
            switch result {
            case .success(let userInfo):
                self.onUpdateUserFlags(userInfo.userFlags)
            default:
                print("Error fetching UserInfo")
                self.reset()
            }
        }
    }

    // setting user flags
    public func onUpdateUserFlags(_ flags: [String]) {
        for flag in UserFlag.allCases {
            if flags.contains(flag.rawValue) {
                self.userFlags.insert(flag)
            }
        }
        self.state = .ready
    }

    // check if user has flag set to true
    public func hasFlag(_ flag: UserFlag) -> Bool {
        assert(state == .ready)
        return self.userFlags.contains(flag)
    }

    // update flag value to true on server
    public func setFlag(_ flag: UserFlag, action: (() -> Void)?) {
        if case .sending = state { return }

        self.state = .sending

        GraphQLAPI.shared.perform(
            mutation: UpdateUserFlagMutation(
                input: .init(flagId: flag.rawValue, flagValue: true)
            )
        ) { result in
            self.state = .ready
            switch result {
            case .success:
                self.userFlags.insert(flag)
                if let callback = action {
                    callback()
                }
            case .failure(let error):
                self.reset()
                print(error)
            }
        }
    }

    // reset user flags
    private func reset() {
        self.userFlags = []
        self.state = .unset
    }
}
