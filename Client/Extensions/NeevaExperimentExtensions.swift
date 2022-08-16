// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared

extension NeevaExperiment {
    public static func logStartExperiment<Arm: ExperimentArms>(for experiment: Experiment<Arm>) {
        guard let arm = arm(for: experiment) else {
            return
        }

        ClientLogger.shared.logCounter(
            .StartExperiment,
            attributes: [
                ClientLogCounterAttribute(
                    key: LogConfig.ExperimentAttribute.experiment,
                    value: experiment.key
                ),
                ClientLogCounterAttribute(
                    key: LogConfig.ExperimentAttribute.experimentArm,
                    value: arm.rawValue
                ),
            ])

    }
}
