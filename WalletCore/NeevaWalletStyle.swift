// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import SwiftUI

public struct WalletTheme {
    public static let sharedBundle = Bundle(for: WalletBundleHookClass.self)
    public static let gradient = LinearGradient(
        colors: [.wallet.gradientStart, .wallet.gradientEnd], startPoint: .leading,
        endPoint: .trailing)
}

private class WalletBundleHookClass {}

extension UIColor {
    public enum wallet {
        public static let gradientStart = UIColor(
            named: "GradientStart", in: WalletTheme.sharedBundle, compatibleWith: nil)!
        public static let gradientEnd = UIColor(
            named: "GradientEnd", in: WalletTheme.sharedBundle, compatibleWith: nil)!
    }
}

extension Color {
    public enum wallet {
        public static let gradientStart = Color(UIColor.wallet.gradientStart)
        public static let gradientEnd = Color(UIColor.wallet.gradientEnd)
        public static let secondary = Color(
            light: Color.quaternarySystemFill, dark: Color.tertiarySystemFill)
        public static let primaryLabel = Color(light: Color.brand.white, dark: Color.black)
    }
}

extension View {
    public func gradientForeground() -> some View {
        self
            .overlay(WalletTheme.gradient)
            .mask(self)
    }
}

public struct NeevaWalletButtonStyle: ButtonStyle {
    public enum VisualSpec {
        case primary
        case secondary
    }

    let visualSpec: VisualSpec
    @Environment(\.isEnabled) private var isEnabled

    @ViewBuilder var background: some View {
        switch visualSpec {
        case .primary:
            WalletTheme.gradient
        case .secondary:
            Color.wallet.secondary
        }
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(visualSpec == VisualSpec.primary ? .wallet.primaryLabel : .label)
            .padding(.vertical, 8)
            .frame(height: 48)
            .background(background)
            .clipShape(Capsule())
            .opacity(isEnabled ? 1 : 0.5)
    }
}

public struct NeevaWalletLongPressButton<Content: View>: View {
    @State var unlocked = false
    @State var unlockActive = false
    @State var countDown = 4
    @State var timer: Timer? = nil

    let action: () -> Void
    let label: () -> Content

    public init(action: @escaping () -> Void, label: @escaping () -> Content) {
        self.action = action
        self.label = label
    }

    public var body: some View {
        label()
            .foregroundColor(.wallet.primaryLabel)
            .padding(.vertical, 8)
            .frame(height: 48)
            .animation(nil)
            .background(
                LinearGradient(
                    colors: unlockActive || unlocked
                        ? [.wallet.gradientStart, .wallet.gradientEnd] : [.wallet.gradientEnd],
                    startPoint: .leading,
                    endPoint: unlockActive || unlocked ? .trailing : .leading)
            )
            .animation(unlockActive ? .linear(duration: 4) : nil)
            .clipShape(Capsule())
            .overlay(
                Text(verbatim: "\(countDown)")
                    .bold()
                    .foregroundColor(.wallet.primaryLabel)
                    .padding(.leading, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
            )
            .onLongPressGesture(
                minimumDuration: 4,
                pressing: { pressing in
                    unlockActive = pressing
                    if pressing, timer == nil {
                        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                            if countDown > 0 {
                                countDown -= 1
                            } else {
                                action()
                                timer?.invalidate()
                            }
                        }
                    } else if !pressing, let timer = self.timer {
                        timer.invalidate()
                        self.timer = nil
                        countDown = 4
                    }
                },
                perform: {
                    unlocked = true
                    unlockActive = false
                    action()
                    timer?.invalidate()
                })
    }
}

public struct DashboardButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .withFont(unkerned: .bodyMedium)
            .foregroundColor(.label)
            .padding(12)
            .frame(height: 40)
            .background(configuration.isPressed ? Color.tertiarySystemFill : Color.clear)
            .roundedOuterBorder(cornerRadius: 20, color: .secondarySystemFill, lineWidth: 1)
            .clipShape(Capsule())
    }
}

extension ButtonStyle where Self == NeevaWalletButtonStyle {
    public static func wallet(_ visualSpec: NeevaWalletButtonStyle.VisualSpec) -> Self {
        .init(visualSpec: visualSpec)
    }
}
