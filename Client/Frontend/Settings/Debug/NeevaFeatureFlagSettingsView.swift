// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

private let log = Logger.browser

struct NeevaFeatureFlagSettingsView: View {
    @State var needsRestart = false
    var body: some View {
        List {
            // TODO: Add support for Float flags to TextFlagView
            Section(header: Text(verbatim: "Bool Flags")) {
                ForEach(NeevaFeatureFlags.BoolFlag.allCases, id: \.rawValue) { flag in
                    HStack {
                        Text(flag.name)
                            .font(.system(.body, design: .monospaced))
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        BoolFlagView(flag: flag, onChange: { needsRestart = true })
                            .fixedSize()
                    }
                }
            }
            Section(header: Text(verbatim: "Int Flags")) {
                ForEach(NeevaFeatureFlags.IntFlag.allCases, id: \.rawValue) { flag in
                    VStack(alignment: .leading) {
                        Text(flag.name)
                            .font(.system(.body, design: .monospaced))
                            .fixedSize(horizontal: false, vertical: true)
                        IntFlagView(flag: flag, onChange: { needsRestart = true })
                    }
                }
            }
            Section(header: Text(verbatim: "String Flags")) {
                ForEach(NeevaFeatureFlags.StringFlag.allCases, id: \.rawValue) { flag in
                    VStack(alignment: .leading) {
                        Text(flag.name)
                            .font(.system(.body, design: .monospaced))
                            .fixedSize(horizontal: false, vertical: true)
                        TextFlagView(flag: flag, onChange: { needsRestart = true })
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .overlay(DebugSettingsRestartPromptView(isVisible: needsRestart), alignment: .bottom)
    }
}

private struct BoolFlagView: View {
    @State private var flagValue: Bool
    @State private var isOverridden: Bool

    private let onChange: () -> Void
    private let flag: NeevaFeatureFlags.BoolFlag

    init(flag: NeevaFeatureFlags.BoolFlag, onChange: @escaping () -> Void) {
        self.flag = flag
        self.onChange = onChange
        self._flagValue = .init(initialValue: NeevaFeatureFlags[flag])
        self._isOverridden = .init(initialValue: NeevaFeatureFlags.isOverridden(flag))
    }

    var body: some View {
        Menu {
            Button {
                NeevaFeatureFlags[flag] = true
                updateState()
            } label: {
                if flagValue && isOverridden {
                    Label(String("True"), systemSymbol: .checkmark)
                } else {
                    Text(verbatim: "True")
                }
            }
            Button {
                NeevaFeatureFlags[flag] = false
                updateState()
            } label: {
                if !flagValue && isOverridden {
                    Label(String("False"), systemSymbol: .checkmark)
                } else {
                    Text(verbatim: "False")
                }
            }
            Button {
                NeevaFeatureFlags.reset(flag)
                updateState()
            } label: {
                if isOverridden {
                    Text(verbatim: "Default")
                } else {
                    Label(String("Default"), systemSymbol: .checkmark)
                }
            }
        } label: {
            HStack {
                Spacer()  // fix layout issues
                Text(String(flagValue)).fontWeight(isOverridden ? .bold : .regular)
                Symbol(decorative: .chevronDown)
            }
        }
    }

    func updateState() {
        self.onChange()
        self.flagValue = NeevaFeatureFlags[flag]
        self.isOverridden = NeevaFeatureFlags.isOverridden(flag)
    }
}

private struct TextFlagView: View {
    @State private var isOverridden: Bool
    @State private var flagValueText: String

    private let onChange: () -> Void
    private let flag: NeevaFeatureFlags.StringFlag

    init(flag: NeevaFeatureFlags.StringFlag, onChange: @escaping () -> Void) {
        self.flag = flag
        self.onChange = onChange
        self._flagValueText = .init(initialValue: String(NeevaFeatureFlags[flag]))
        self._isOverridden = .init(initialValue: NeevaFeatureFlags.isOverridden(flag))
    }

    var body: some View {
        HStack {
            TextField(NeevaFeatureFlags[flag], text: $flagValueText, onEditingChanged: { _ in }) {
                NeevaFeatureFlags[flag] = flagValueText
                updateState()
            }
            .textFieldStyle(.roundedBorder)
            .font(Font.headline.weight(isOverridden ? .bold : .regular))
            Menu {
                Button {
                    NeevaFeatureFlags.reset(flag)
                    updateState()
                } label: {
                    if isOverridden {
                        Text(verbatim: "Restore Default")
                    } else {
                        Label(String("Default"), systemSymbol: .checkmark)
                    }
                }
            } label: {
                HStack {
                    Symbol(decorative: .chevronDown)
                }
            }
        }
    }

    func updateState() {
        self.onChange()
        self.flagValueText = NeevaFeatureFlags[flag]
        self.isOverridden = NeevaFeatureFlags.isOverridden(flag)
    }
}

private struct IntFlagView: View {
    @State private var isOverridden: Bool
    @State private var flagValueText: String

    private let onChange: () -> Void
    private let flag: NeevaFeatureFlags.IntFlag

    init(flag: NeevaFeatureFlags.IntFlag, onChange: @escaping () -> Void) {
        self.flag = flag
        self.onChange = onChange
        self._flagValueText = .init(initialValue: String(NeevaFeatureFlags[flag]))
        self._isOverridden = .init(initialValue: NeevaFeatureFlags.isOverridden(flag))
    }

    var body: some View {
        HStack {
            TextField(
                String(NeevaFeatureFlags[flag]), text: $flagValueText, onEditingChanged: { _ in }
            ) {
                NeevaFeatureFlags[flag] = Int(flagValueText) ?? 0
                updateState()
            }
            .textFieldStyle(.roundedBorder)
            .font(Font.headline.weight(isOverridden ? .bold : .regular))
            Menu {
                Button {
                    NeevaFeatureFlags.reset(flag)
                    updateState()
                } label: {
                    if isOverridden {
                        Text(verbatim: "Restore Default")
                    } else {
                        Label(String("Default"), systemSymbol: .checkmark)
                    }
                }
            } label: {
                HStack {
                    Symbol(decorative: .chevronDown)
                }
            }
        }
    }

    func updateState() {
        self.onChange()
        self.flagValueText = String(NeevaFeatureFlags[flag])
        self.isOverridden = NeevaFeatureFlags.isOverridden(flag)
    }
}

struct NeevaFeatureFlagSettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NeevaFeatureFlagSettingsView()
                .navigationTitle(String("Server Feature Flags"))
                .navigationBarTitleDisplayMode(.inline)
        }.navigationViewStyle(.stack)
    }
}
