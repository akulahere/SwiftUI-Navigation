//
//  OnboardingStep3View.swift
//  SwiftUI-Navigation-PoC
//

import SwiftUI

struct OnboardingStep3View: View {
    let onFinish: () -> Void
    let onPopToRoot: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Onboarding Step 3").font(.title2).bold()

            Button("Finish", action: onFinish)
                .buttonStyle(.borderedProminent)

            Button("Pop to root (Step1)", action: onPopToRoot)
                .buttonStyle(.bordered)
        }
        .padding(24)
    }
}
