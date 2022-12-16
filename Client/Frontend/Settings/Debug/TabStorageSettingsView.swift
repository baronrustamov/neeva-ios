// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import SwiftUI
import UniformTypeIdentifiers
import ZIPFoundation

struct TabStorageSettingsView: View {
    @Default(.profileLocalName) var profileLocalName
    @State var currentProfileName: String = ""
    @State var currentProfilePath: String = ""

    @State var error: String? = nil

    @State var exportedFileReady: Bool = false
    private var profileURL: URL {
        if #available(iOS 16, *) {
            return URL(filePath: currentProfilePath)
        } else {
            return URL(fileURLWithPath: currentProfilePath)
        }
    }
    private var profileZipDestURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(
            currentProfileName + ".zip", conformingTo: .archive
        )
    }

    /// The directory that is one level above to currentProfilePath
    private var currentProfileDir: URL {
        if #available(iOS 16, *) {
            return URL(filePath: currentProfilePath).deletingLastPathComponent()
        } else {
            return URL(fileURLWithPath: currentProfilePath).deletingLastPathComponent()
        }
    }

    var body: some View {
        List {
            Section(String("Warning")) {
                HStack(alignment: .top) {
                    Image(systemSymbol: .exclamationmarkTriangle)
                        .foregroundColor(.yellow)
                    VStack(alignment: .leading) {
                        Text(verbatim: "Intended for debug use only")
                            .font(.headline)
                        Divider()
                        Text(verbatim: "You may lose your data as a result of using these tools.")
                    }
                }
            }

            if let error = error {
                Text(verbatim: error)
                    .italic()
                    .foregroundColor(.red)
            }

            Section(String("Current Browser Profile")) {
                if #available(iOS 16, *) {
                    LabeledContent(String("Current Profile Name")) {
                        Text(verbatim: currentProfileName)
                    }
                } else {
                    HStack {
                        Text(verbatim: "Current Profile Name")
                            .layoutPriority(1)
                        Spacer()
                        Text(verbatim: currentProfileName)
                            .font(.caption)
                    }
                }
                VStack(alignment: .leading) {
                    Text(verbatim: "Current Profile Path")
                    Text(verbatim: currentProfilePath)
                        .foregroundColor(.secondaryLabel)
                    NavigationLink(
                        destination: {
                            FileListView(rootPath: currentProfilePath)
                        },
                        label: {
                            Text(verbatim: "Browse")
                                .foregroundColor(.accentColor)
                        }
                    )
                    .disabled(currentProfilePath.isEmpty)
                }
                Button(String("Export")) {
                    Task {
                        let fileManager = FileManager.default
                        do {
                            try fileManager.removeItemIfExists(at: profileZipDestURL)
                            try fileManager.zipItem(
                                at: profileURL, to: profileZipDestURL, shouldKeepParent: false)
                            self.exportedFileReady = true
                        } catch {
                            self.error = error.localizedDescription
                        }
                    }
                }
                .fileMover(isPresented: $exportedFileReady, file: profileZipDestURL) { result in
                    if case .failure(let failure) = result {
                        print(failure)
                    }
                    guard case .success = result else {
                        do {
                            try FileManager.default.removeItem(at: profileZipDestURL)
                        } catch {
                            self.error = error.localizedDescription
                        }
                        return
                    }
                }
            }
            .disabled(currentProfilePath.isEmpty)
            .task {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
                else {
                    self.error = "No app delegate"
                    return
                }

                let profile = appDelegate.profile
                currentProfileName = profile.localName()
                currentProfilePath = profile.files.rootPath
            }

            Section(String("Archive Debug Utils")) {
                if profileLocalName != currentProfileName {
                    Label {
                        Text(
                            verbatim:
                                "Selected profile is different from the current active profile. Relaunch the app to switch to the selected profile"
                        )
                        .italic()
                    } icon: {
                        Image(systemSymbol: .exclamationmarkTriangle)
                            .foregroundColor(.yellow)
                    }
                }

                if #available(iOS 16, *) {
                    LabeledContent(String("profileLocalName")) {
                        Text(verbatim: profileLocalName)
                    }
                } else {
                    HStack {
                        Text(verbatim: "profileLocalName")
                            .layoutPriority(1)
                        Spacer()
                        Text(verbatim: profileLocalName)
                            .font(.caption)
                    }
                }

                NavigationLink {
                    ProfilePicker(
                        currentProfileName: currentProfileName,
                        rootDirURL: currentProfileDir
                    ) { file in
                        profileLocalName = file.profileName!
                    }
                    .navigationTitle(String("Select Profile"))
                } label: {
                    Text(verbatim: "Select Profile")
                }

                NavigationLink {
                    ArchiveImportView(importDestDir: currentProfileDir)
                        .navigationTitle(String("Import Profile"))
                } label: {
                    Text(verbatim: "Import New Profile from Files")
                }
            }
        }
    }
}

private struct ArchiveImportView: View {
    @State var busy: Bool = false
    @State var showImporter: Bool = false
    @State var importFileURL: URL?
    @State var unpackedFileURL: URL?
    @State var importedProfileName: String = ""
    @State var error: String?

    @Environment(\.presentationMode) var presentation

    let importDestDir: URL

    var tmpDirectory: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(
            "ArchiveImport", conformingTo: .folder
        )
    }

    var body: some View {
        List {
            if let error = error {
                Text(verbatim: error)
                    .foregroundColor(.red)
            }
            Section(String("Source File")) {
                Group {
                    if #available(iOS 16, *) {
                        Text(verbatim: importFileURL?.path() ?? "No file provided")
                    } else {
                        Text(verbatim: importFileURL?.path ?? "No file provided")
                    }
                }
                .foregroundColor(.secondaryLabel)

                Button(String("Select Zip File")) {
                    showImporter = true
                    importFileURL = nil
                    unpackedFileURL = nil
                    importedProfileName = ""
                }
                .disabled(self.busy)
                .fileImporter(
                    isPresented: $showImporter,
                    allowedContentTypes: [.archive],
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case .success(let success):
                        importFileURL = success.first
                    case .failure(let failure):
                        self.error = (failure as Error).localizedDescription
                    }
                }
                .task(id: importFileURL, priority: .utility) {
                    // We need access
                    guard let url = importFileURL,
                        url.startAccessingSecurityScopedResource()
                    else {
                        return
                    }

                    busy = true

                    defer {
                        url.stopAccessingSecurityScopedResource()
                        // set this state to nil so that the next selection also trigger a task
                        busy = false
                    }

                    var error: NSError? = nil

                    NSFileCoordinator().coordinate(readingItemAt: url, error: &error) { url in
                        let fileManager = FileManager.default
                        do {
                            // Clean tmp directory
                            if (try? tmpDirectory.checkResourceIsReachable()) ?? false {
                                try fileManager.removeItem(at: tmpDirectory)
                            }
                            try fileManager.createDirectory(
                                at: tmpDirectory, withIntermediateDirectories: true)

                            // unzip file to tmp directory
                            let profileName = url.deletingPathExtension().lastPathComponent
                            let unzipDestURL = tmpDirectory.appendingPathComponent(
                                "profile." + profileName)
                            try fileManager.unzipItem(at: url, to: unzipDestURL)

                            unpackedFileURL = unzipDestURL
                            importedProfileName = profileName
                        } catch {
                            self.error = error.localizedDescription
                        }
                    }

                    if let error = error {
                        self.error = error.localizedDescription
                    }
                }
            }

            Section(String("Import As")) {
                TextField(String("Import Profile Name"), text: $importedProfileName)
                    .disabled(unpackedFileURL == nil)
            }

            Section {
                Button(String("Save to App Storage")) {
                    Task {
                        busy = true
                        defer { busy = false }

                        guard let unpackedFileURL = unpackedFileURL else {
                            self.error = "No unpacked profile to import"
                            return
                        }

                        let destURL = importDestDir.appendingPathComponent(
                            "profile." + importedProfileName)

                        do {
                            try FileManager.default.moveItem(
                                at: unpackedFileURL,
                                to: destURL
                            )
                            presentation.wrappedValue.dismiss()
                        } catch {
                            self.error = error.localizedDescription
                        }
                    }
                }
                .disabled(unpackedFileURL == nil || busy)
            }
        }
    }
}

private struct File: Identifiable {
    var url: URL
    var lastComponent: String {
        url.lastPathComponent
    }

    var isDirectory: Bool {
        url.isDirectory
    }

    var isProfile: Bool {
        lastComponent.hasPrefix("profile.")
    }

    var profileName: String? {
        guard isProfile else {
            return nil
        }

        return String(lastComponent.dropFirst("profile.".count))
    }

    var id: URL {
        return url
    }
}

extension URL {
    fileprivate var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}

private class FileListViewModel: ObservableObject {
    let fileManager = FileManager.default

    // only for debugging
    private(set) var rootDirURL: URL = URL(fileURLWithPath: "")

    @Published var files: [File] = []
    @Published var error: Error? = nil

    func updateRootDir(_ url: URL) async {
        await MainActor.run {
            self.files = []
            self.rootDirURL = url
            self.error = nil
        }

        do {
            let urls = try fileManager.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.contentTypeKey, .isDirectoryKey]
            )
            await MainActor.run {
                self.files = urls.map {
                    File(url: $0)
                }
            }
        } catch {
            await MainActor.run {
                self.error = error
            }
        }
    }
}

private struct FileListView: View {
    @StateObject var model = FileListViewModel()

    let rootDirURL: URL

    init(rootDirURL: URL) {
        self.rootDirURL = rootDirURL
    }

    init(rootPath: String) {
        if #available(iOS 16, *) {
            self.rootDirURL = URL(filePath: rootPath)
        } else {
            self.rootDirURL = URL(fileURLWithPath: rootPath)
        }
    }

    var body: some View {
        List(model.files) { file in
            if file.isDirectory {
                NavigationLink {
                    FileListView(rootDirURL: file.url)
                } label: {
                    Label(
                        file.lastComponent,
                        systemSymbol: .folder
                    )
                }

            } else {
                Label(
                    file.lastComponent,
                    systemSymbol: .doc
                )
            }
        }
        .navigationTitle(String(rootDirURL.lastPathComponent))
        .task(priority: .userInitiated) {
            await model.updateRootDir(rootDirURL)
        }
    }
}

private struct FileEditListView: View {
    @StateObject var listModel = FileListViewModel()

    let rootDirURL: URL

    var body: some View {
        List(listModel.files) { file in
            if file.isDirectory {
                NavigationLink {
                    if #available(iOS 16, *) {
                        FileListView(rootPath: file.url.path())
                    } else {
                        FileListView(rootPath: file.url.path)
                    }
                } label: {
                    Label(
                        file.lastComponent,
                        systemSymbol: .folder
                    )
                }

            } else {
                Label(
                    file.lastComponent,
                    systemSymbol: .doc
                )
            }
        }
        .toolbar { EditButton() }
        .navigationTitle(String(rootDirURL.lastPathComponent))
        .task(priority: .userInitiated) {
            await listModel.updateRootDir(rootDirURL)
        }
    }
}

private struct ProfilePicker: View {
    @Environment(\.presentationMode) var presentation

    @StateObject var listModel = FileListViewModel()

    let currentProfileName: String
    let rootDirURL: URL
    let onSelected: (File) -> Void

    var rootPath: String {
        if #available(iOS 16, *) {
            return rootDirURL.path()
        } else {
            return rootDirURL.path
        }
    }

    var body: some View {
        List {
            Section {
                ForEach(listModel.files) { file in
                    Button {
                        onSelected(file)
                        presentation.wrappedValue.dismiss()
                    } label: {
                        Label(file.lastComponent, systemSymbol: file.isProfile ? .archivebox : .doc)
                    }
                    .disabled(!file.isProfile)
                    .deleteDisabled(!file.isProfile || file.profileName == currentProfileName)
                }
                .onDelete { indexSet in
                    Task {
                        // delete one by one only
                        guard let fileIdx = indexSet.first,
                            let file = listModel.files[safeIndex: fileIdx]
                        else {
                            return
                        }
                        try? FileManager.default.removeItem(at: file.url)
                        await listModel.updateRootDir(rootDirURL)
                    }
                }
            } footer: {
                Text(verbatim: rootPath)
            }
        }
        .toolbar { EditButton() }
        .task(priority: .userInitiated) {
            await listModel.updateRootDir(rootDirURL)
        }
    }
}

extension FileManager {
    fileprivate func removeItemIfExists(at fileURL: URL) throws {
        var path: String
        if #available(iOS 16, *) {
            path = fileURL.path()
        } else {
            path = fileURL.path
        }

        if self.fileExists(atPath: path) {
            try self.removeItem(at: fileURL)
        }
    }
}
