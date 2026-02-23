//
//  OnboardingStep2View.swift
//  SwiftUI-Navigation-PoC
//

import SwiftUI

struct OnboardingStep2View: View {
    let onShowPaywall: () -> Void
    let onNext: () -> Void
    let onPopToRoot: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Onboarding Step 2").font(.title2).bold()

            Button("Show Paywall", action: onShowPaywall)
                .buttonStyle(.bordered)

            Button("Next", action: onNext)
                .buttonStyle(.borderedProminent)

            Button("Pop to root (Step1)", action: onPopToRoot)
                .buttonStyle(.bordered)
        }
        .padding(24)
    }
}
