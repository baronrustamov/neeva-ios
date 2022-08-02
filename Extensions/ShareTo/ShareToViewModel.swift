// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Kanna
import Shared
import Storage

private enum MetaTag: String {
    case description
    case title
    case image

    init?(_ rawValue: String) {
        switch rawValue {
        case "description", "og:description":
            self = .description
        case "title", "og:title":
            self = .title
        case "image", "og:image":
            self = .image
        default:
            return nil
        }
    }
}

class ShareToViewModel: NSObject, ObservableObject {

    @Published var shareItem = ShareItem(url: "", title: nil, description: nil, favicon: nil)
    @Published var loading = true

    private var type: SocialInfoType? {
        guard let url = URL(string: shareItem.url) else { return nil }
        return SocialInfoType.allCases.first(where: {
            url.domainURL.absoluteString.contains($0.rawValue)
        })
    }

    func getMetadata(with urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return
        }
        if type == .twitter {
            updateShareItemForTwitter(with: urlString)
            loading = false
            return
        }
        makeRequest(to: url)
    }

    private func makeRequest(to url: URL) {
        var request = URLRequest(url: url)
        request.addValue(UserAgent.desktopUserAgent(), forHTTPHeaderField: "User-Agent")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.loading = false
                }
                return
            }
            DispatchQueue.main.async {
                do {
                    if let string = String(data: data, encoding: .utf8) {
                        let doc = try Kanna.HTML(html: string, encoding: .utf8)
                        self.shareItem.title = doc.title
                        for meta in doc.xpath("//meta") {
                            self.processsMetatag(meta)
                        }
                        self.loading = false
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.loading = false
                    }
                }

            }
        }.resume()
    }

    private func processsMetatag(_ xmlElement: XMLElement) {
        guard let property = xmlElement["property"],
            let metaTag = MetaTag(property)
        else {
            return
        }
        let content = xmlElement["content"]
        switch metaTag {
        case .description:
            guard type != .instagram else { return }
            shareItem.description = content
        case .title:
            let ogTitle = content
            if type == .instagram, let ogTitle = ogTitle {
                updateShareItemForInstagram(with: ogTitle)
                return
            }
            shareItem.title = ogTitle
        case .image:
            if let urlString = content, let url = URL(string: urlString) {
                shareItem.favicon = Favicon(url: url)
            }
        }
    }
}

extension ShareToViewModel {
    private func updateShareItemForInstagram(with ogTitle: String) {
        let index = ogTitle.firstIndex(of: ":")
        shareItem.title = String(ogTitle.prefix(upTo: index ?? ogTitle.endIndex))
        shareItem.description =
            index == nil
            ? ""
            : String(
                ogTitle.suffix(from: ogTitle.index(after: index ?? ogTitle.startIndex))
                    .dropFirst(2).dropLast())
    }

    private func updateShareItemForTwitter(with urlString: String) {
        guard let url = URL(string: urlString), url.pathComponents.count > 2,
            url.pathComponents[2] == "status"
        else {
            shareItem.title = "Twitter"
            return
        }
        let username = url.pathComponents[1]
        shareItem.title = "\(username) on Twitter"
    }
}
