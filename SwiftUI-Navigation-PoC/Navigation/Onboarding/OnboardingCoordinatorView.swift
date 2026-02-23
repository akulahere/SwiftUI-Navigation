//
//  OnboardingCoordinatorView.swift
//  SwiftUI-Navigation-PoC
//

import SwiftUI

struct OnboardingCoordinatorView: View {
    // MARK: - Private variables

    @EnvironmentObject private var router: AppRouter

    // MARK: - Other

    var body: some View {
        NavigationStack(path: $router.onboardingStack) {
            OnboardingStep1View(
                onNext: { router.onboardingPush(.step2) }
            )
            .navigationDestination(for: OnboardingRoute.self) { route in
                switch route {
                case .step2:
                    OnboardingStep2View(
                        onShowPaywall: { router.presentPaywall() },
                        onNext: { router.onboardingPush(.step3) },
                        onPopToRoot: { router.onboardingPopToRoot() }
                    )

                case .step3:
                    OnboardingStep3View(
                        onFinish: {
                            router.presentSuccess(
                                title: "Done!",
                                message: "Onboarding is complete.",
                                primaryButton: "Open App",
                                primaryAction: .goAuthorizedTab1Root
                            )
                        },
                        onPopToRoot: { router.onboardingPopToRoot() }
                    )
                }
            }
        }
        .sheet(isPresented: $router.isPaywallPresented) {
            PaywallSheetView(
                onClose: { router.dismissPaywall() },
                onPurchased: {
                    router.dismissPaywall()
                    router.presentSuccess(
                        title: "Purchase successful",
                        message: "Access unlocked.",
                        primaryButton: "Continue",
                        primaryAction: .dismiss
                    )
                }
            )
            .presentationDetents([.medium, .large])
        }
    }
}
