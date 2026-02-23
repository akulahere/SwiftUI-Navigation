//
//  OnboardingCoordinatorView.swift
//  SwiftUI-Navigation-PoC
//

import SwiftUI

struct OnboardingCoordinatorView: View {
    // MARK: - Private variables

    @EnvironmentObject private var router: AppRouter
    private var onboardingRouter: any OnboardingRouting { router }
    private var successRouter: any SuccessRouting { router }

    // MARK: - Other

    var body: some View {
        NavigationStack(path: $router.onboardingStack) {
            OnboardingStep1View(
                onNext: { onboardingRouter.onboardingPush(.step2) }
            )
            .navigationDestination(for: OnboardingRoute.self) { route in
                switch route {
                case .step2:
                    OnboardingStep2View(
                        onShowPaywall: { onboardingRouter.presentPaywall() },
                        onNext: { onboardingRouter.onboardingPush(.step3) },
                        onPopToRoot: { onboardingRouter.onboardingPopToRoot() }
                    )

                case .step3:
                    OnboardingStep3View(
                        onFinish: {
                            successRouter.presentSuccess(
                                title: "Done!",
                                message: "Onboarding is complete.",
                                primaryButton: "Open App",
                                primaryAction: .goAuthorizedTab1Root,
                                presentationStyle: .fullScreen
                            )
                        },
                        onPopToRoot: { onboardingRouter.onboardingPopToRoot() }
                    )
                }
            }
        }
        .sheet(isPresented: $router.isPaywallPresented) {
            PaywallSheetView(
                onClose: { onboardingRouter.dismissPaywall() },
                onPurchased: {
                    onboardingRouter.dismissPaywall()
                    successRouter.presentSuccess(
                        title: "Purchase successful",
                        message: "Access unlocked.",
                        primaryButton: "Continue",
                        primaryAction: .dismiss,
                        presentationStyle: .fullScreen
                    )
                }
            )
            .presentationDetents([.medium, .large])
        }
    }
}
