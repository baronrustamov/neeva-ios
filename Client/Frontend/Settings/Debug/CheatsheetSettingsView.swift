// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct CheatsheetSettingsView: View {
    @Default(.seenCheatsheetIntro) var seenCheatsheetIntro
    @Default(.showTryCheatsheetPopover) var showTryCheatsheetPopover
    @Default(.seenTryCheatsheetPopoverOnRecipe) var seenTryCheatsheetPopoverOnRecipe
    @Default(.tryCheatsheetPopoverCount) var tryCheatsheetPopoverCount
    @Default(.cheatsheetDebugQuery) var cheatsheetDebugQuery
    @Default(.useCheatsheetBloomFilters) var useCheatsheetBloomFilters

    var body: some View {
        Section(header: Text(verbatim: "Cheatsheet")) {
            Toggle(String("cheatsheetIntroSeen"), isOn: $seenCheatsheetIntro)
            Toggle(String("showTryCheatsheetPopover"), isOn: $showTryCheatsheetPopover)
            Toggle(
                String("seenTryCheatsheetPopoverOnRecipe"),
                isOn: $seenTryCheatsheetPopoverOnRecipe
            )
            NumberField(
                String("tryCheatsheetPopoverCount"),
                number: $tryCheatsheetPopoverCount
            )
            Toggle(String("cheatsheetDebugQuery"), isOn: $cheatsheetDebugQuery)
            Toggle(String("useCheatsheetBloomFilters"), isOn: $useCheatsheetBloomFilters)

            makeNavigationLink(title: "Bloom Filter Settings") {
                BloomFilterSettingsView()
            }
        }
    }
}

struct BloomFilterSettingsView: View {
    struct FileItem: Hashable, Identifiable, CustomStringConvertible {
        var id: Self { self }
        var name: String?
        var description: String {
            guard let name = name else {
                return "No file here"
            }
            return "\(name)"
        }

        static let empty = FileItem(name: nil)
    }

    enum LoadingState {
        case loading, success, failed
    }

    var saveToDir: URL? {
        BloomFilterManager.getSaveToDirectory()
    }
    var filterDirFiles: [FileItem] {
        guard let dirURL = saveToDir,
            let fileList = try? FileManager.default.contentsOfDirectory(
                at: dirURL, includingPropertiesForKeys: nil)
        else {
            return [.empty]
        }
        return fileList.map { FileItem(name: $0.lastPathComponent) }
    }

    @State var deletingState: LoadingState?

    var body: some View {
        List {
            Section(header: Text(verbatim: "Local Filter")) {
                VStack(alignment: .leading) {
                    Text(verbatim: "Local filter save dir")
                        .font(.body)
                    Text(String(describing: saveToDir?.absoluteString))
                        .foregroundColor(.secondaryLabel)
                        .font(.caption)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading) {
                    Text(verbatim: "Files in dir")
                        .font(.body)
                    ForEach(filterDirFiles) { file in
                        Text(file.description)
                            .foregroundColor(.secondaryLabel)
                            .font(.caption)
                    }
                }

                Button(
                    action: {
                        deletingState = .loading
                        DispatchQueue.global(qos: .userInteractive).async {
                            let success = BloomFilterManager.clearSaveToDirectory()
                            DispatchQueue.main.async {
                                deletingState = success ? .success : .failed
                            }
                        }
                    },
                    label: {
                        HStack {
                            Text("Delete this file directory")
                                .foregroundColor(.red)
                            Spacer()
                            if let state = deletingState {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .opacity(state == .loading ? 1 : 0)
                            }
                        }
                    })
            }
        }
        .font(.system(.footnote, design: .monospaced))
        .minimumScaleFactor(0.75)
        .listStyle(.insetGrouped)
        .applyToggleStyle()
    }
}

struct CheatsheetSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CheatsheetSettingsView()
    }
}
