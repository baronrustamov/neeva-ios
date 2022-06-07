// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI

struct ExperimentSettingsView: View {
    @Environment(\.dismissScreen) var dismissScreen

    let scrollViewAppearance = UINavigationBar.appearance().scrollEdgeAppearance
    @State private var valueTextDefaultBrowser: String?
    @State private var valueTextPromoCard: String?

    var body: some View {
        List {
            Group {
                Button {
                    NeevaExperiment.resetAllExperiments()
                } label: {
                    Text("Reset all experiments")
                        .foregroundColor(Color.label)
                }

                /* Experiment Example */
                //OptionalPrefilledStringField<NeevaExperiment.DefaultBrowserV2>(
                //    "DefaultBrowserPromptView",
                //    value: $valueText,
                //    experiment: .defaultBrowserPromptV2
                //)

                OptionalPrefilledStringField<NeevaExperiment.PromoCardTypeAfterFirstRun>(
                    "PromoCardTypeAfterFirstRun",
                    value: $valueTextPromoCard,
                    experiment: .promoCardTypeAfterFirstRun
                )

                OptionalPrefilledStringField<NeevaExperiment.DefaultBrowserWelcomeScreen>(
                    "DefaultBrowserWelcomeScreen",
                    value: $valueTextPromoCard,
                    experiment: .defaultBrowserWelcomeScreen
                )
            }
        }
        .listStyle(.insetGrouped)
        .applyToggleStyle()
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct OptionalPrefilledStringField<Arm: ExperimentArms>: View {
    init(_ title: String, value: Binding<String?>, experiment: NeevaExperiment.Experiment<Arm>) {
        self.title = title
        self.experiment = experiment
        if let arm = NeevaExperiment.arm(for: experiment) {
            self._value = State(initialValue: arm.rawValue)
        }
    }

    let title: String
    @State var value: String?
    var experiment: NeevaExperiment.Experiment<Arm>

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Menu {
                ForEach(Arm.allCases, id: \.rawValue) { caseValue in
                    Button {
                        value = caseValue.rawValue
                        NeevaExperiment.forceExperimentArm(
                            experiment: experiment, experimentArm: value
                        )
                    } label: {
                        if let currentValue = value, currentValue == caseValue.rawValue {
                            Label(caseValue.rawValue, systemSymbol: .checkmark)
                        } else {
                            Text(caseValue.rawValue)
                        }
                    }
                }
                Button {
                    value = nil
                    NeevaExperiment.resetExperiment(experiment: experiment)
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

struct ExperimentSettingsView_Preview: PreviewProvider {
    static var previews: some View {
        SettingPreviewWrapper {
            ExperimentSettingsView()
        }
    }
}
