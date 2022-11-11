// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct TabGroupHeader: View {
    @ObservedObject var groupDetails: TabGroupCardDetails
    @Environment(\.columns) private var columns
    let rowIndex: Int?

    var body: some View {
        HStack {
            Menu {
                TabGroupContextMenu(groupDetails: groupDetails)
            } label: {
                Label("ellipsis", systemImage: "ellipsis")
                    .foregroundColor(.label)
                    .labelStyle(.iconOnly)
                    .frame(height: 44)
            }

            Text(groupDetails.title)
                .withFont(.labelLarge)
                .foregroundColor(.label)
                .accessibility(identifier: "TabGroupTitle")
                .accessibility(value: Text(groupDetails.title))

            Spacer()

            if groupDetails.allDetails.count > columns.count {
                Button {
                    groupDetails.isExpanded.toggle()
                    logExpandStateChanged()
                } label: {
                    Label(
                        "arrows",
                        systemImage: groupDetails.isExpanded
                            ? "arrow.down.right.and.arrow.up.left"
                            : "arrow.up.left.and.arrow.down.right"
                    )
                    .foregroundColor(.label)
                    .labelStyle(.iconOnly)
                    .padding()
                }.accessibilityHidden(true)
            }
        }
        .padding(.leading, CardGridUX.GridSpacing)
        .frame(height: SingleLevelTabCardsViewUX.TabGroupCarouselTitleSize)
        // the top and bottom paddings applied below are to make the tap target
        // of the context menu taller
        .padding(.top, SingleLevelTabCardsViewUX.TabGroupCarouselTopPadding)
        .padding(.bottom, SingleLevelTabCardsViewUX.TabGroupCarouselTitleSpacing)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tab Group, \(groupDetails.title)")
        .accessibilityAddTraits([.isHeader, .isButton])
        .accessibilityValue(groupDetails.isShowingDetails ? "Expanded" : "Collapsed")
        .accessibilityAction {
            groupDetails.isShowingDetails.toggle()
        }
        .contentShape(Rectangle())
        .contextMenu { TabGroupContextMenu(groupDetails: groupDetails) }
        .textFieldAlert(
            isPresented: $groupDetails.renaming, title: "Rename “\(groupDetails.title)”",
            required: false
        ) { newName in
            if newName.isEmpty {
                groupDetails.customTitle = nil
            } else {
                groupDetails.customTitle = newName
            }
        } configureTextField: { tf in
            tf.clearButtonMode = .always
            tf.placeholder = groupDetails.defaultTitle ?? ""
            tf.text = groupDetails.customTitle
            tf.autocapitalizationType = .words
        }
        .actionSheet(isPresented: $groupDetails.deleting) {
            let buttons: [ActionSheet.Button] = [
                .destructive(Text("Close All")) {
                    groupDetails.onClose(showToast: false)
                },
                .cancel(),
            ]

            var title: String {
                if let title = groupDetails.customTitle {
                    return "Close all \(groupDetails.allDetails.count) tabs from “\(title)”?"
                } else {
                    return "Close these \(groupDetails.allDetails.count) tabs?"
                }
            }

            return ActionSheet(title: Text(title), buttons: buttons)
        }
    }

    func logExpandStateChanged() {
        ClientLogger.shared.logCounter(
            groupDetails.isExpanded ? .tabGroupExpanded : .tabGroupCollapsed,
            attributes: getLogCounterAttributesForTabGroups(
                tabGroupRowIndex: rowIndex, selectedChildTabIndex: nil,
                expanded: nil, numTabs: groupDetails.allDetails.count)
        )
    }
}
