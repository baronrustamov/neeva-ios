// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct AppearanceSettingsSection: View {
    @State var selectedTheme = Defaults[.customizeTheme] ?? .system
    @State var selectedIcon = Defaults[.customizeIcon] ?? .system
    @State var showingThemeDetails = false
    @State var showingIconDetails = false

    var body: some View {
        themeNavLink
        iconNavLink
    }

    var themeNavLink: some View {
        NavigationLink(
            destination:
                List {
                    Picker(selection: $selectedTheme, label: EmptyView()) {
                        ForEach(AppearanceThemeOption.allCases, id: \.self) { option in
                            Text(option.localizedName)
                                .tag(option)
                        }
                    }
                    .pickerStyle(.inline)
                }
                .onChange(of: selectedTheme) { option in
                    Defaults[.customizeTheme] = option
                    showingThemeDetails.toggle()
                    SceneDelegate.handleThemePreference(for: option)
                }
                .onAppear {
                    ClientLogger.shared.logCounter(
                        .SettingTheme, attributes: EnvironmentHelper.shared.getAttributes()
                    )
                }
                .navigationTitle("Theme"),
            isActive: $showingThemeDetails
        ) {
            HStack {
                Text("Theme")
                Spacer()
                Text(selectedTheme.rawValue)
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder var iconNavLink: some View {
        if UIApplication.shared.supportsAlternateIcons {
            NavigationLink(
                destination:
                    List {
                        Picker(selection: $selectedIcon, label: EmptyView()) {
                            ForEach(AppearanceIconOption.allCases, id: \.self) { option in
                                HStack(spacing: 10) {
                                    appIconImage(option)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(12)
                                    Text(option == .system ? "Default" : option.localizedName)
                                        .tag(option)
                                }
                            }
                        }
                        .pickerStyle(.inline)
                    }
                    .onChange(of: selectedIcon) { option in
                        Defaults[.customizeIcon] = option
                        UIApplication.shared.setAlternateIconName(
                            option == .system ? nil : option.rawValue)
                        showingIconDetails.toggle()
                    }
                    .onAppear {
                        ClientLogger.shared.logCounter(
                            .SettingAppIcon, attributes: EnvironmentHelper.shared.getAttributes()
                        )
                    }
                    .navigationTitle("App Icon"),
                isActive: $showingIconDetails
            ) {
                HStack {
                    Text("App Icon")
                    Spacer()
                    appIconImage(selectedIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .cornerRadius(5)
                }
            }
        }
    }

    func appIconImage(_ option: AppearanceIconOption) -> Image {
        switch option {
        case .system:
            return Image(uiImage: UIImage(named: "System@2x.png")!)
        case .black:
            return Image(uiImage: UIImage(named: "Black@2x.png")!)
        }
    }
}
