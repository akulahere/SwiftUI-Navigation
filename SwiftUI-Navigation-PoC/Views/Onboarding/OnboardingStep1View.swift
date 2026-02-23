//
//  OnboardingStep1View.swift
//  SwiftUI-Navigation-PoC
//

import SwiftUI

struct OnboardingStep1View: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Onboarding Step 1").font(.title2).bold()
            Button("Next", action: onNext)
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
    }
}
