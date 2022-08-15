// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct InternalSettingsView: View {
    @Default(.searchInputPromptDismissed) var searchInputPromptDismissed
    @Default(.introSeen) var introSeen
    @Default(.walletIntroSeen) var walletintroSeen
    @Default(.walletOnboardingDone) var walletOnboardingDone
    @Default(.didFirstNavigation) var didFirstNavigation
    @Default(.seenSpacesIntro) var seenSpacesIntro
    @Default(.seenSpacesShareIntro) var seenSpacesShareIntro
    @Default(.lastVersionNumber) var lastVersionNumber
    @Default(.didDismissReferralPromoCard) var didDismissReferralPromoCard
    @Default(.deletedSuggestedSites) var deletedSuggestedSites
    @Default(.recentlyClosedTabs) var recentlyClosedTabs
    @Default(.saveLogins) var saveLogins
    @Default(.topSitesCacheIsValid) var topSitesCacheIsValid
    @Default(.topSitesCacheSize) var topSitesCacheSize
    @Default(.widgetKitSimpleTabKey) var widgetKitSimpleTabKey
    @Default(.widgetKitSimpleTopTab) var widgetKitSimpleTopTab
    @Default(.applicationCleanlyBackgrounded) var applicationCleanlyBackgrounded
    @Default(.ratingsCardHidden) var ratingsCardHidden
    @Default(.lastScheduledNeevaPromoID) var lastScheduledNeevaPromoID
    @Default(.lastNeevaPromoScheduledTimeInterval) var lastNeevaPromoScheduledTimeInterval
    @Default(.didRegisterNotificationTokenOnServer) var didRegisterNotificationTokenOnServer
    @Default(.productSearchPromoTimeInterval) var productSearchPromoTimeInterval
    @Default(.newsProviderPromoTimeInterval) var newsProviderPromoTimeInterval
    @Default(.seenNotificationPermissionPromo) var seenNotificationPermissionPromo
    @Default(.fastTapPromoTimeInterval) var fastTapPromoTimeInterval
    @Default(.defaultBrowserPromoTimeInterval) var defaultBrowserPromoTimeInterval
    @Default(.previewModeQueries) var previewModeQueries
    @Default(.signupPromptInterval) var signupPromptInterval
    @Default(.maxQueryLimit) var maxQueryLimit
    @Default(.signedInOnce) var signedInOnce
    @Default(.didDismissDefaultBrowserCard) var didDismissDefaultBrowserCard
    @Default(.didDismissPreviewSignUpCard) var didDismissPreviewSignUpCard
    @Default(.didSetDefaultBrowser) var didSetDefaultBrowser
    @Default(.didShowDefaultBrowserInterstitial) var didShowDefaultBrowserInterstitial
    @Default(.didShowDefaultBrowserInterstitialFromSkipToBrowser)
    var didShowDefaultBrowserInterstitialFromSkipToBrowser
    @Default(.numOfDailyZeroQueryImpression) var numOfDailyZeroQueryImpression
    @Default(.lastZeroQueryImpUpdatedTimestamp) var lastZeroQueryImpUpdatedTimestamp
    @Default(.didTriggerSystemReviewDialog) var didTriggerSystemReviewDialog
    @Default(.numberOfAppForeground) var numberOfAppForeground
    @Default(.forceProdGraphQLLogger) var forceProdGraphQLLogger
    @Default(.firstRunImpressionLogged) var firstRunImpressionLogged
    @Default(.lastReportedConversionEvent) var lastReportedConversionEvent
    @Default(.lastDefaultBrowserInterstitialChoice) var lastDefaultBrowserInterstitialChoice
    @Default(.introSeenDate) var introSeenDate
    @Default(.shouldCollectUsageStats) var shouldCollectUsageStats

    var body: some View {
        List {
            Section(header: Text(verbatim: "First Run")) {
                Toggle(String("searchInputPromptDismissed"), isOn: $searchInputPromptDismissed)
                Toggle(String("introSeen"), isOn: $introSeen)
                Toggle(String("walletintroSeen"), isOn: $walletintroSeen)
                Toggle(String("walletOnboardingDone"), isOn: $walletOnboardingDone)
                Toggle(String("didFirstNavigation"), isOn: $didFirstNavigation)
                Toggle(String("signedInOnce"), isOn: $signedInOnce)
                Toggle(String("firstRunImpressionLogged"), isOn: $firstRunImpressionLogged)
                HStack {
                    VStack(alignment: .leading) {
                        Text(verbatim: "previewModeQueries")
                        Text(verbatim: "\(previewModeQueries.count)")
                            .foregroundColor(.secondaryLabel)
                            .font(.caption)
                    }
                    Spacer()
                    Button(String("Clear")) { previewModeQueries.removeAll() }
                        .font(.body)
                        .accentColor(.red)
                        .buttonStyle(.borderless)
                }
                NumberField(
                    String("signupPromptInterval"), number: $signupPromptInterval)
                NumberField(
                    String("maxQueryLimit"), number: $maxQueryLimit)
            }
            Group {
                Section(header: Text(verbatim: "Spaces")) {
                    Toggle(String("spacesIntroSeen"), isOn: $seenSpacesIntro)
                    Toggle(String("spacesShareIntroSeen"), isOn: $seenSpacesShareIntro)
                }
                CheatsheetSettingsView()
                Section(header: Text(verbatim: "Promo Cards")) {
                    Toggle(
                        String("didDismissDefaultBrowserCard"), isOn: $didDismissDefaultBrowserCard)
                    Toggle(
                        String("didDismissReferralPromoCard"), isOn: $didDismissReferralPromoCard)
                    Toggle(
                        String("didDismissPreviewSignUpCard"), isOn: $didDismissPreviewSignUpCard)

                    Toggle(String("ratingsCardHidden"), isOn: $ratingsCardHidden)
                    Toggle(
                        String("seenNotificationPermissionPromo"),
                        isOn: $seenNotificationPermissionPromo)
                    Toggle(
                        String("didTriggerSystemReviewDialog"), isOn: $didTriggerSystemReviewDialog)
                    NumberField(String("numberOfAppForeground"), number: $numberOfAppForeground)
                    HStack {
                        VStack(alignment: .leading) {
                            Text(verbatim: "introSeenDate")
                            Text(
                                verbatim:
                                    "\(introSeenDate?.timeIntervalSince1970 ?? 0)"
                            )
                            .foregroundColor(.secondaryLabel)
                            .font(.caption)
                        }
                        Spacer()
                        Button(String("Clear")) { introSeenDate = nil }
                            .font(.body)
                            .accentColor(.red)
                            .buttonStyle(.borderless)
                    }
                }
                Section(header: Text(verbatim: "Conversion Logging")) {
                    NumberField("lastReportedConversionEvent", number: $lastReportedConversionEvent)
                }
            }
            Section(header: Text(verbatim: "Default Browser")) {
                Toggle(String("didSetDefaultBrowser"), isOn: $didSetDefaultBrowser)
                Toggle(
                    String("didShowDefaultBrowserInterstitial"),
                    isOn: $didShowDefaultBrowserInterstitial
                )
                Toggle(
                    String("didShowDefaultBrowserInterstitialFromSkipToBrowser"),
                    isOn: $didShowDefaultBrowserInterstitialFromSkipToBrowser
                )
                NumberField(
                    String("numOfDailyZeroQueryImpression"), number: $numOfDailyZeroQueryImpression)
                HStack {
                    VStack(alignment: .leading) {
                        Text(verbatim: "lastZeroQueryImpUpdatedTimestamp")
                        Text(
                            verbatim:
                                "\(lastZeroQueryImpUpdatedTimestamp?.timeIntervalSince1970 ?? 0)"
                        )
                        .foregroundColor(.secondaryLabel)
                        .font(.caption)
                    }
                    Spacer()
                    Button(String("Clear")) { lastZeroQueryImpUpdatedTimestamp = nil }
                        .font(.body)
                        .accentColor(.red)
                        .buttonStyle(.borderless)
                }
                NumberField(
                    String("lastDefaultBrowserInterstitialChoice"),
                    number: $lastDefaultBrowserInterstitialChoice
                )
            }
            Section(header: Text(verbatim: "User-generated")) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(verbatim: "deletedSuggestedSites")
                        Text(
                            String(
                                "\(deletedSuggestedSites.count) site\(deletedSuggestedSites.count == 1 ? "" : "s")"
                            )
                        )
                        .foregroundColor(.secondaryLabel)
                        .font(.caption)
                    }
                    Spacer()
                    Button(String("Clear")) { deletedSuggestedSites = [] }
                        .font(.body)
                        .accentColor(.red)
                        .buttonStyle(.borderless)
                }
                OptionalDataKeyView("recentlyClosedTabs", data: $recentlyClosedTabs)
            }

            Section(header: Text(verbatim: "Miscellaneous")) {
                Toggle(String("forceProdGraphQLLogger"), isOn: $forceProdGraphQLLogger)
                Toggle(String("saveLogins"), isOn: $saveLogins)
                    // comment this line out if you’re working on logins and need access
                    .disabled(!saveLogins)

                OptionalStringField("lastVersionNumber", text: $lastVersionNumber)
                OptionalBooleanField("shouldCollectUsageStats", value: $shouldCollectUsageStats)
            }

            Section(header: Text(verbatim: "Top Sites Cache")) {
                HStack {
                    Text(verbatim: "topSitesCacheIsValid")
                    Spacer()
                    Text(String(topSitesCacheIsValid))
                        .foregroundColor(.secondaryLabel)
                }
                OptionalNumberField("topSitesCacheSize", number: $topSitesCacheSize)
            }

            Section(header: Text(verbatim: "WidgetKit")) {
                OptionalDataKeyView("widgetKitSimpleTabKey", data: $widgetKitSimpleTabKey)
                OptionalDataKeyView("widgetKitSimpleTopTab", data: $widgetKitSimpleTopTab)
            }

            Section(header: Text(verbatim: "Performance")) {
                Toggle(
                    String("applicationCleanlyBackgrounded"), isOn: $applicationCleanlyBackgrounded)
                if let cleanlyBackgrounded = cleanlyBackgroundedLastTime {
                    let text =
                        cleanlyBackgrounded
                        ? "Was cleanly backgrounded last time"
                        : "Was NOT cleanly backgrounded last time"
                    Text(text)
                        .font(.system(.footnote)).italic()
                        .foregroundColor(cleanlyBackgrounded ? nil : Color.red)
                }
            }

            Section(header: Text(verbatim: "Notification")) {
                OptionalStringField(
                    "lastScheduledNeevaPromoID", text: $lastScheduledNeevaPromoID)
                OptionalNumberField(
                    "lastNeevaPromoScheduledTimeInterval",
                    number: $lastNeevaPromoScheduledTimeInterval)
                Toggle(
                    String("didRegisterNotificationTokenOnServer"),
                    isOn: $didRegisterNotificationTokenOnServer)

                NumberField(
                    "productSearchPromoTimeInterval", number: $productSearchPromoTimeInterval)

                NumberField(
                    "newsProviderPromoTimeInterval", number: $newsProviderPromoTimeInterval)

                NumberField("fastTapPromoTimeInterval", number: $fastTapPromoTimeInterval)

                NumberField(
                    "defaultBrowserPromoTimeInterval", number: $defaultBrowserPromoTimeInterval)
            }

            makeNavigationLink(title: String("Spotlight Search")) {
                SpotlightSettingsView()
            }
        }
        .font(.system(.footnote, design: .monospaced))
        .minimumScaleFactor(0.75)
        .listStyle(.insetGrouped)
        .applyToggleStyle()
    }

    private var cleanlyBackgroundedLastTime: Bool? {
        (UIApplication.shared.delegate as? AppDelegate)?.cleanlyBackgroundedLastTime
    }
}

private struct OptionalBooleanField: View {
    init(_ title: String, value: Binding<Bool?>) {
        self.title = title
        self._value = value
    }

    let title: String
    @Binding var value: Bool?

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Menu {
                Button {
                    value = true
                } label: {
                    if value == true {
                        Label("true", systemSymbol: .checkmark)
                    } else {
                        Text("true")
                    }
                }
                Button {
                    value = false
                } label: {
                    if value == false {
                        Label("false", systemSymbol: .checkmark)
                    } else {
                        Text("false")
                    }
                }
                Button {
                    value = nil
                } label: {
                    if value == nil {
                        Label("nil", systemSymbol: .checkmark)
                    } else {
                        Text("nil")
                    }
                }
            } label: {
                HStack {
                    Text(value.map { String($0) } ?? "nil")
                    Symbol(decorative: .chevronDown)
                }
            }
        }
    }
}

private struct OptionalNumberField<Number: FixedWidthInteger>: View {
    init(_ title: String, number: Binding<Number?>) {
        self.title = title
        self._number = number
    }

    let title: String
    @Binding var number: Number?

    var body: some View {
        HStack {
            Text(title)
            TextField(
                "nil",
                text: Binding(
                    get: { number.map { String($0) } ?? "" },
                    set: {
                        if let parsed = Number($0) {
                            number = parsed
                        } else if $0.isEmpty {
                            number = nil
                        }
                    }
                )
            ).multilineTextAlignment(.trailing)
        }
    }
}

struct NumberField<Number: FixedWidthInteger>: View {
    init(_ title: String, number: Binding<Number>) {
        self.title = title
        self._number = number
    }

    let title: String
    @Binding var number: Number
    var body: some View {
        HStack {
            Text(title)
            TextField(
                "0",
                text: Binding(
                    get: { String(number) },
                    set: {
                        if let parsed = Number($0) {
                            number = parsed
                        }
                    }
                )
            ).multilineTextAlignment(.trailing)
        }
    }
}

struct OptionalStringField: View {
    init(_ title: String, text: Binding<String?>) {
        self.title = title
        self._text = text
    }

    let title: String
    @Binding var text: String?

    var body: some View {
        HStack {
            Text(title)
            TextField(
                "nil",
                text: Binding(
                    get: { text ?? "" },
                    set: { text = $0.isEmpty ? nil : $0 }
                )
            ).multilineTextAlignment(.trailing)
        }
    }
}

private struct OptionalDataKeyView: View {
    init(_ name: String, data: Binding<Data?>) {
        self.name = name
        self._data = data
    }

    let name: String
    @Binding var data: Data?

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                Group {
                    if let data = data {
                        Text(ByteCountFormatter().string(fromByteCount: Int64(data.count)))
                            .font(.caption)
                    } else {
                        Text("nil")
                            .font(.system(.caption, design: .monospaced))
                    }
                }
                .foregroundColor(.secondaryLabel)
            }
            Spacer()
            Button("Clear") { data = nil }
                .font(.body)
                .accentColor(.red)
                .buttonStyle(.borderless)
        }
    }
}

struct InternalSettings_Previews: PreviewProvider {
    static var previews: some View {
        InternalSettingsView()
        InternalSettingsView().previewDevice("iPhone 8")
    }
}
