// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Reachability

/// Provides information about whether the network is reachable
class NetworkReachability: ObservableObject {
    /// Since network reachability is global, use `@ObservedObject var reachability = NetworkReachability.shared`
    static var shared = NetworkReachability()

    /// `true` if the device is connected to the Internet, `false` if the device is not connected
    /// and `nil` if the reachability check is ongoing
    @Published var isOnline: Bool?
    /// The best connection (WiFi, cellular, or none) to the Internet that this device has
    @Published var connection: Reachability.Connection?

    private let reachability = try! Reachability()

    private init() {
        reachability.whenReachable = { reachability in
            self.isOnline = true
            self.connection = reachability.connection
        }
        reachability.whenUnreachable = { _ in
            self.isOnline = false
            self.connection = nil
        }
        try! reachability.startNotifier()
    }

    deinit {
        reachability.stopNotifier()
    }
}
