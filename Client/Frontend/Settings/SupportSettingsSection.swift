// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct SupportSettingsSection: View {
    @Environment(\.openInNewTab) var openInNewTab
    @Environment(\.settingsPresentIntroViewController) var presentIntroViewController

    var body: some View {
        if NeevaUserInfo.shared.hasLoginCookie() {
            NavigationLinkButton("Welcome Tours") {
                ClientLogger.shared.logCounter(
                    .ViewShowTour, attributes: EnvironmentHelper.shared.getAttributes())
                openInNewTab(NeevaConstants.appWelcomeToursURL, false)
            }
        } else {
            NavigationLinkButton("Show Tour") {
                ClientLogger.shared.logCounter(
                    .ViewShowTour, attributes: EnvironmentHelper.shared.getAttributes())
                presentIntroViewController()
            }
        }

        NavigationLinkButton("Help Center") {
            ClientLogger.shared.logCounter(
                .ViewHelpCenter, attributes: EnvironmentHelper.shared.getAttributes())
            openInNewTab(NeevaConstants.appHelpCenterURL, false)
        }
    }
}

struct SupportSettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        SettingPreviewWrapper {
            Section(header: Text("Support")) {
                SupportSettingsSection()
            }
        }
    }
}
