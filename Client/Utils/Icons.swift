// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

extension Image {
    /// Create an image with the provided icon name (as returned from the `suggest` GraphQL endpoint)
    init?(neevaIcon name: String) {
        if let imageName = iconMapping[name] {
            self.init(imageName)
        } else {
            return nil
        }
    }

    /// Create an image with the provided icon set (as returned from the `suggest` GraphQL endpoint)
    /// - Parameters:
    ///   - icons: a list of icon names. The first valid icon name will be used.
    init?(icons: [String]) {
        if let name = icons.first(where: { iconMapping[$0] != nil }) {
            self.init(neevaIcon: name)!
        } else {
            return nil
        }
    }
}

/// The icon used for space suggestions
struct SpaceIconView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.spaceIconBackground)
                .frame(width: 20, height: 20)
            Text("S")
                .font(.system(size: 12))
                .foregroundColor(Color.white)
                .fontWeight(.semibold)
        }
    }
}

struct SpaceIconView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SpaceIconView()
        }.previewLayout(.sizeThatFits)
    }
}

// extracted from `icon-library.ts`
let iconMapping = [
    "gsuite-app": "google",
    "slack-app": "slack",
    "twitter-app": "twitter",
    "dropbox-app": "dropbox",
    "dropbox-paper-app": "dropbox-paper",
    "gcontacts-app": "google-contact",
    "github-app": "github",
    "gdrive-app": "google-drive",
    "gmail-app": "google-mail",
    "gcalendar-app": "google-calendar",
    "office365-app": "o365",
    "o365-calendar-app": "o365-calendar",
    "o365-contacts-app": "o365-contacts",
    "o365-onedrive-app": "o365-onedrive",
    "o365-outlook-app": "o365-outlook",
    "apple-app": "apple",
    "document": "google-doc",
    "event": "google-calendar",
    "file": "google-file",
    "contact": "google-contact",
    "issue": "github-issue-opened",
    "mail": "google-mail",
    "message": "slack",
    "web": "bing",
    "gdrive-archive": "google-zip",
    "gdrive-audio": "google-audio",
    "gdrive-code": "google-code",
    "gdrive-doc": "google-doc",
    "gdrive-drawing": "google-drawing",
    "gdrive-exe": "google-exe",
    "gdrive-event": "google-calendar",
    "gdrive-file": "google-file",
    "gdrive-folder": "google-folder",
    "gdrive-form": "google-forms",
    "gdrive-fusiontable": "google-fusiontable",
    "gdrive-image": "google-image",
    "gdrive-pdf": "google-pdf",
    "gdrive-sheet": "google-sheet",
    "gdrive-slides": "google-slide",
    "gdrive-text": "google-doc",
    "gdrive-video": "google-video",
    "github-archive": "github-zip",
    "github-audio": "github-file",
    "github-code": "github-code",
    "github-doc": "github-text",
    "github-event": "github-file",
    "github-exe": "github-exe",
    "github-file": "github-file",
    "github-folder": "github-folder",
    "github-image": "github-image",
    "github-pdf": "github-pdf",
    "github-sheet": "github-file",
    "github-slides": "github-file",
    "github-text": "github-text",
    "github-video": "github-file",
    "dropbox-archive": "dropbox-zip",
    "dropbox-audio": "dropbox-audio",
    "dropbox-code": "dropbox-code",
    "dropbox-doc": "dropbox-text",
    "dropbox-event": "dropbox-file",
    "dropbox-exe": "dropbox-exe",
    "dropbox-file": "dropbox-file",
    "dropbox-folder": "dropbox-folder",
    "dropbox-image": "dropbox-image",
    "dropbox-pdf": "dropbox-pdf",
    "dropbox-sheet": "dropbox-spreadsheet",
    "dropbox-text": "dropbox-text",
    "dropbox-video": "dropbox-video",
    "onedrive-ai": "onedrive-ai",
    "onedrive-archive": "onedrive-zip",
    "onedrive-audio": "onedrive-audio",
    "onedrive-code": "onedrive-code",
    "onedrive-doc": "onedrive-word",
    "onedrive-exe": "onedrive-exe",
    "onedrive-file": "onedrive-file",
    "onedrive-folder": "onedrive-folder",
    "onedrive-folder-shared": "onedrive-folder.shared",
    "onedrive-font": "onedrive-font",
    "onedrive-image": "onedrive-image",
    "onedrive-keynote": "onedrive-keynote",
    "onedrive-markup": "onedrive-markup",
    "onedrive-numbers": "onedrive-numbers",
    "onedrive-pages": "onedrive-pages",
    "onedrive-pdf": "onedrive-pdf",
    "onedrive-psd": "onedrive-psd",
    "onedrive-sketch": "onedrive-sketch",
    "onedrive-sheet": "onedrive-spreadsheet",
    "onedrive-slides": "onedrive-presentation",
    "onedrive-text": "onedrive-text",
    "onedrive-video": "onedrive-video",
    "slack-archive": "slack-zip",
    "slack-audio": "slack-audio",
    "slack-code": "slack-code",
    "slack-doc": "slack-text",
    "slack-event": "slack-file",
    "slack-exe": "slack-exe",
    "slack-file": "slack-file",
    "slack-folder": "slack-folder",
    "slack-image": "slack-image",
    "slack-pdf": "slack-pdf",
    "slack-sheet": "slack-spreadsheet",
    "slack-text": "slack-text",
    "slack-video": "slack-video",
    "github": "github",
    "github_issue": "github-issue-opened",
    "github_issue-opened": "github-issue-opened",
    "github_issue-closed": "github-issue-closed",
    "github_issue-reopened": "github-issue-reopened",
    "github_pr": "github-pr",
    "github_pr-closed": "github-pr-closed",
    "github_pr-merged": "github-pr-merged",
    "github_pr-unchecked": "github-pr-unchecked",
    "google-calendar": "google-calendar",
    "google-event-01": "google-calendar-1",
    "google-event-02": "google-calendar-2",
    "google-event-03": "google-calendar-3",
    "google-event-04": "google-calendar-4",
    "google-event-05": "google-calendar-5",
    "google-event-06": "google-calendar-6",
    "google-event-07": "google-calendar-7",
    "google-event-08": "google-calendar-8",
    "google-event-09": "google-calendar-9",
    "google-event-10": "google-calendar-10",
    "google-event-11": "google-calendar-11",
    "google-event-12": "google-calendar-12",
    "google-event-13": "google-calendar-13",
    "google-event-14": "google-calendar-14",
    "google-event-15": "google-calendar-15",
    "google-event-16": "google-calendar-16",
    "google-event-17": "google-calendar-17",
    "google-event-18": "google-calendar-18",
    "google-event-19": "google-calendar-19",
    "google-event-20": "google-calendar-20",
    "google-event-21": "google-calendar-21",
    "google-event-22": "google-calendar-22",
    "google-event-23": "google-calendar-23",
    "google-event-24": "google-calendar-24",
    "google-event-25": "google-calendar-25",
    "google-event-26": "google-calendar-26",
    "google-event-27": "google-calendar-27",
    "google-event-28": "google-calendar-28",
    "google-event-29": "google-calendar-29",
    "google-event-30": "google-calendar-30",
    "google-event-31": "google-calendar-31",
    "google-contact": "google-contact",
    "google-email": "google-mail",
    "o365-contact": "o365-contact",
    "o365-email": "o365-mail",
    "o365-calendar": "o365-calendar",
    "o365-event-01": "o365-calendar-1",
    "o365-event-02": "o365-calendar-2",
    "o365-event-03": "o365-calendar-3",
    "o365-event-04": "o365-calendar-4",
    "o365-event-05": "o365-calendar-5",
    "o365-event-06": "o365-calendar-6",
    "o365-event-07": "o365-calendar-7",
    "o365-event-08": "o365-calendar-8",
    "o365-event-09": "o365-calendar-9",
    "o365-event-10": "o365-calendar-10",
    "o365-event-11": "o365-calendar-11",
    "o365-event-12": "o365-calendar-12",
    "o365-event-13": "o365-calendar-13",
    "o365-event-14": "o365-calendar-14",
    "o365-event-15": "o365-calendar-15",
    "o365-event-16": "o365-calendar-16",
    "o365-event-17": "o365-calendar-17",
    "o365-event-18": "o365-calendar-18",
    "o365-event-19": "o365-calendar-19",
    "o365-event-20": "o365-calendar-20",
    "o365-event-21": "o365-calendar-21",
    "o365-event-22": "o365-calendar-22",
    "o365-event-23": "o365-calendar-23",
    "o365-event-24": "o365-calendar-24",
    "o365-event-25": "o365-calendar-25",
    "o365-event-26": "o365-calendar-26",
    "o365-event-27": "o365-calendar-27",
    "o365-event-28": "o365-calendar-28",
    "o365-event-29": "o365-calendar-29",
    "o365-event-30": "o365-calendar-30",
    "o365-event-31": "o365-calendar-31",
    "slack": "slack",
    "bing": "bing",
    "play-video": "play",
    "twitter-verified": "twitter-verified",
    "retweeted": "twitter-retweeted",
]
