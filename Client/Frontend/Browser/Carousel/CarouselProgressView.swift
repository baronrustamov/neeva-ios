// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

class CarouselProgressModel: ObservableObject {
    @Published var urls: [URL]
    @Published var index: Int

    init(urls: [URL], index: Int) {
        self.urls = urls
        self.index = index
    }
}

private struct CarouselProgressUX {
    static let SelectedSize: CGFloat = 18
    static let RegularSize: CGFloat = 12
    static let Padding: CGFloat = 4
    static let MinHeight: CGFloat = {
        SelectedSize + 2 * Padding
    }()
}

struct CarouselProgressView: View {
    @ObservedObject var model: CarouselProgressModel

    var body: some View {
        HStack(alignment: .center) {
            ForEach(Array(model.urls.enumerated()), id: \.0) { i, url in
                let size: CGFloat =
                    i == model.index
                    ? CarouselProgressUX.SelectedSize : CarouselProgressUX.RegularSize
                FaviconView(forSiteUrl: url)
                    .frame(width: size, height: size).clipShape(Circle())
                    .shadow(radius: 2).animation(model.index == -1 ? nil : .spring())
            }
        }.padding(CarouselProgressUX.Padding)
            .frame(minHeight: CarouselProgressUX.MinHeight)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.brand.pistachio,
                        Color.brand.blue,
                        Color.brand.pistachio,
                    ]),
                    startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(Capsule()).shadow(radius: 3).padding()
    }
}

struct CarouselProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CarouselProgressView(
            model: CarouselProgressModel(
                urls: [
                    "http://facebook.com", "http://facebook.com", "http://google.com",
                    "http://facebook.com", "http://theverge.com", "http://facebook.com",
                    "http://google.com", "http://facebook.com", "http://facebook.com",
                    "http://facebook.com", "http://linkedin.com", "http://facebook.com",
                    "http://google.com", "http://facebook.com", "http://hp.com",
                ], index: 0))
    }
}
