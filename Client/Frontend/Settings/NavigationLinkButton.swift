// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

/// A re-implementation of `NavigationLink`’s appearance in `List` that offers support for a link icon
/// instead of the standard chevron and runs a closure instead of pushing a new view.
struct NavigationLinkButton<Label: View>: View {
    let label: () -> Label
    let action: () -> Void
    let style: Style

    enum Style {
        case link
        case modal
        case loading

        @ViewBuilder fileprivate var symbol: some View {
            switch self {
            case .link:
                Symbol(decorative: .arrowTopRightOnSquare, weight: .medium)
            case .modal:
                Image(systemSymbol: .chevronForward)
                    .font(.footnote.weight(.semibold))
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
    }

    init(
        action: @escaping () -> Void, style: Style = .link,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.label = label
        self.action = action
        self.style = style
    }

    var body: some View {
        let button = Button(action: action) {
            HStack {
                label().foregroundColor(.label)
                Spacer(minLength: 0)
                style.symbol
                    .foregroundColor(.tertiaryLabel)
            }
        }
        if style == .link {
            button.accessibilityAddTraits(.isLink)
        } else {
            button
        }
    }
}

extension NavigationLinkButton where Label == Text {
    init(_ title: LocalizedStringKey, style: Style = .link, action: @escaping () -> Void) {
        self.label = { Text(title) }
        self.action = action
        self.style = style
    }
}

/// A view that looks like a `NavigationLink` in a `List`, but opens a sheet when tapped instead of pushing a view.
struct SheetNavigationLink<Label: View, Sheet: View>: View {
    let label: () -> Label
    let sheet: () -> Sheet

    @State var sheetVisible = false

    init(@ViewBuilder label: @escaping () -> Label, @ViewBuilder sheet: @escaping () -> Sheet) {
        self.label = label
        self.sheet = sheet
    }

    var body: some View {
        NavigationLinkButton(
            action: { sheetVisible = true },
            style: .modal,
            label: label
        ).sheet(isPresented: $sheetVisible, content: sheet)
    }
}

extension SheetNavigationLink where Label == Text {
    init(_ title: String, @ViewBuilder sheet: @escaping () -> Sheet) {
        self.label = { Text(title) }
        self.sheet = sheet
    }
}

@ViewBuilder
func makeNavigationLink<D: View>(title: LocalizedStringKey, destination: () -> D) -> some View {
    NavigationLink(title, destination: destination().navigationTitle(title))
}

@_disfavoredOverload
@ViewBuilder
func makeNavigationLink<D: View, S: StringProtocol>(title: S, destination: () -> D) -> some View {
    NavigationLink(title, destination: destination().navigationTitle(title))
}

struct NavigationLinkButton_Previews: PreviewProvider {
    static var previews: some View {
        List {
            NavigationLinkButton("Test") {}
            NavigationLinkButton("Test", style: .modal) {}
            NavigationLinkButton(action: {}) {
                Label(String("Test"), systemSymbol: .starFill)
            }
            NavigationLinkButton(action: {}, style: .modal) {
                Label(String("Test"), systemSymbol: .starFill)
            }
        }
    }
}
