// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Storage
import SwiftUI

struct AddToSpaceView: View {
    let onDismiss: (_ didComplete: Bool) -> Void

    @StateObject private var request: AddToSpaceRequest

    init(item: ShareItem, onDismiss: @escaping (Bool) -> Void) {
        _request = .init(
            wrappedValue: AddToSpaceRequest(
                title: item.title ?? item.url,
                description: item.description,
                url: item.url.asURL!
            ))
        self.onDismiss = onDismiss
    }

    var body: some View {
        let isCreating = request.mode == .saveToNewSpace
        VStack {
            switch request.state {
            case .initial:
                ScrollView(showsIndicators: false) {
                    Shared.AddToSpaceView(request: request)
                }

                if isCreating {
                    Spacer()
                }
            case .creatingSpace, .savingToSpace:
                LoadingView("Saving...")
            case .deletingFromSpace:
                LoadingView("Deleting...")
            case .savedToSpace, .deletedFromSpace:
                Color.clear.onAppear { onDismiss(true) }
            case .failed:
                ErrorView(request.error!, viewName: "ShareTo.AddToSpaceView")
            }
        }
        .navigationTitle(request.mode.title)
        .navigationBarBackButtonHidden(isCreating)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if isCreating {
                    Button("Cancel") {
                        request.mode = .saveToExistingSpace
                    }
                }
            }
        }
    }
}
