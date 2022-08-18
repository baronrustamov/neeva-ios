// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine

// Based on https://onmyway133.com/posts/how-to-debounce-textfield-search-in-swiftui/
// Example usage:
// @StateObject var object = DebounceObject()
//
// var body: some View {
//     TextField("Placeholder", text: $object.text)
//         .onChange(of: object.debouncedText) { newValue in
//             // handle change here
//         }
// }
class DebounceObject: ObservableObject {
    @Published var text: String = ""
    @Published var debouncedText: String = ""
    private var subscriptions = Set<AnyCancellable>()

    init() {
        $text
            .removeDuplicates()
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                self?.debouncedText = value
            })
            .store(in: &subscriptions)
    }
}
