// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation

struct SpaceLinkData {
    let title: String
    let url: URL
}

public enum SpaceImportDomain: String {
    case linkinbio = "linkin.bio"
    case linktree = "linktr.ee"
    case likeshop = "likeshop.me"
    case lnkbio = "lnk.bio"

    public var script: String {
        switch self {
        case .linkinbio:
            return
                "Array.prototype.map.call(document.querySelectorAll('a.o--card'), function links(element) {var image=element.querySelector('img'); return [image ? image['alt'].substring(0, image['alt'].indexOf('.')+1) : '', element['href']]})"
        case .linktree:
            return
                "Array.prototype.map.call(document.querySelectorAll('a[data-testid=LinkButton]'), element => [element.querySelector('p').innerHTML, element['href']])"
        case .likeshop:
            return
                "Array.prototype.map.call(document.querySelectorAll('a.media-link'), element => [element.querySelector('img') ? element.querySelector('img')['alt'] : '', element['href']])"
        case .lnkbio:
            return
                "Array.prototype.map.call(document.querySelectorAll('a[class*=pb-linktitle]'), element => [element.innerHTML, unescape(element['href'].substring(21))])"
        }
    }
}

public class SpaceImportHandler {
    public static let descriptionImageScript = """
                [[document.querySelector('meta[name=\"description\"]') ?
                    document.querySelector('meta[name=\"description\"]').content : ''],
                Array.prototype.map.call(document.querySelectorAll('div img'),
                    function links(element) {return [element['width']
                    ? element['width'] : element['style']['width'], element['src']]})
                .filter(pair => pair[0] != '')
                .sort((a, b) => b[0] - a[0])
                .map(pair => pair[1])
                .slice(0,10),
                [document.querySelector('meta[property=\"og:title\"]') ?
                    document.querySelector('meta[property=\"og:title\"]')["content"] : "",
                document.querySelector('meta[property=\"og:description\"]') ?
                    document.querySelector('meta[property=\"og:description\"]')["content"] : "",
                document.querySelector('meta[property=\"og:image\"]') ?
                    document.querySelector('meta[property=\"og:image\"]')["content"] : ""]]
        """
    let title: String
    var data: [SpaceLinkData]
    private var completion: (() -> Void)?
    public var spaceURL: URL {
        guard let id = spaceID else {
            return NeevaConstants.appSpacesURL
        }

        return NeevaConstants.appSpacesURL / id
    }

    private var cancellable: Cancellable?
    private var spaceID: String?

    public init(title: String, data: [[String]]) {
        self.data = data.map {
            assert($0.count == 2)
            return SpaceLinkData(title: $0[0], url: URL(string: $0[1])!)
        }
        self.title = title
    }

    func importToNewSpace(completion: @escaping () -> Void) {
        self.completion = completion
        createSpace()
    }

    private func createSpace() {
        self.cancellable = GraphQLAPI.shared.perform(
            mutation: CreateSpaceMutation(name: title)
        ) { result in
            self.cancellable = nil
            switch result {
            case .success(let data):
                self.spaceID = data.createSpace
                self.addNext()
            case .failure:
                self.completion?()
            }
        }
    }

    private func addNext() {
        guard let linkData = data.popLast() else {
            completion?()
            return
        }
        self.cancellable = SpaceServiceProvider.shared.addToSpaceMutation(
            spaceId: spaceID!,
            url: linkData.url.absoluteString,
            title: linkData.title.isEmpty ? title : linkData.title,
            data: "",
            mediaType: "text/plain",
            isBase64: false
        ) { result in
            self.cancellable = nil
            switch result {
            case .failure:
                self.completion?()
                break
            case .success:
                self.addNext()
            }
        }
    }
}
