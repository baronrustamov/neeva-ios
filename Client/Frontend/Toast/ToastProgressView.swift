// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import SFSafeSymbols
import Shared
import SwiftUI

enum ToastProgressStatus {
    case inProgress
    case success
    case failed

    var icon: SFSymbol {
        switch self {
        case .inProgress:
            return .circle
        case .success:
            return .checkmark
        case .failed:
            return .xmark
        }
    }
}

class ToastProgressViewModel: ObservableObject {
    @Published var status: ToastProgressStatus = .inProgress
    @Published var progress: Double?

    var downloadListener: AnyCancellable?
}

struct ToastProgressView: View {
    private let width: CGFloat = 18

    @EnvironmentObject var progressViewModel: ToastProgressViewModel
    var stateDidChange: ((ToastProgressStatus) -> Void)?

    @State var flipProgressGradient = false
    @State var flipProgressGradientTimer: Timer?

    var body: some View {
        ZStack(alignment: .center) {
            switch progressViewModel.status {
            case .inProgress:
                if let progress = progressViewModel.progress {
                    Circle()
                        .strokeBorder()
                        .background(
                            Circle()
                                .mask(
                                    PieShape(progress: progress)
                                        .animation(.default, value: progressViewModel.status)
                                        .animation(.default, value: progressViewModel.progress)
                                )
                        )
                } else {
                    ProgressView()
                }
            case .success, .failed:
                Circle()
                    .foregroundColor(.white)

                Symbol(decorative: progressViewModel.status.icon, size: 10)
                    .foregroundColor(Color.ToastBackground)
            }
        }
        .frame(width: width, height: width)
        .onChange(of: progressViewModel.status) { _ in
            stateDidChange?(progressViewModel.status)
        }
        .frame(width: width, height: width)
        .onChange(of: progressViewModel.status) { _ in
            stateDidChange?(progressViewModel.status)
        }
    }
}

struct ToastProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ToastProgressView()
            .environmentObject(ToastProgressViewModel())
            .preferredColorScheme(.dark)
    }
}

struct PieShape: Shape {
    var progress: Double?
    var animatableData: Double {
        get {
            self.progress ?? 0
        }
        set {
            self.progress = newValue
        }
    }

    private let startAngle = 1.5 * .pi
    private var endAngle: Double {
        startAngle + 2 * .pi * (progress ?? 0)
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: rect.center)
        path.addArc(
            center: rect.center, radius: rect.size.width / 2,
            startAngle: Angle(radians: startAngle),
            endAngle: Angle(radians: endAngle), clockwise: false)
        path.closeSubpath()
        return path
    }
}
