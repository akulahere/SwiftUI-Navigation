import SwiftUI

struct OnboardingCoordinatorView: View {
    @EnvironmentObject private var router: AppRouter
    private var onboardingRouter: any OnboardingRouting { router }
    private var successRouter: any SuccessRouting { router }

    var body: some View {
        NavigationStack(path: $router.onboardingStack) {
            VStack(spacing: 16) {
                Text("Onboarding Start")
                Button("Next") { onboardingRouter.onboardingPush(.details) }
                Button("Show Paywall Offer") {
                    onboardingRouter.presentPaywall(
                        source: "onboarding.start",
                        offerTitle: "Premium Annual",
                        offerSubtitle: "7-day trial, then yearly billing"
                    )
                }
            }
            .navigationDestination(for: OnboardingRoute.self) { route in
                switch route {
                case .details:
                    VStack(spacing: 16) {
                        Text("Onboarding Details")
                        Button("Show Paywall Offer") {
                            onboardingRouter.presentPaywall(
                                source: "onboarding.details",
                                offerTitle: "Premium Plus",
                                offerSubtitle: "Monthly plan with family access"
                            )
                        }
                        Button("Finish") {
                            // Onboarding success is shown full-screen.
                            successRouter.presentSuccess(
                                title: "Done!",
                                message: "Onboarding is complete.",
                                primaryButton: "Open App",
                                primaryAction: .goAuthorizedHomeRoot,
                                presentationStyle: .fullScreen
                            )
                        }
                    }
                case .finalStep:
                    Text("Final Step")
                }
            }
        }
        .sheet(item: $router.paywallPayload) { payload in
            OnboardingPaywallView(
                payload: payload,
                onClose: { onboardingRouter.dismissPaywall() }
            )
        }
    }
}

private struct OnboardingPaywallView: View {
    let payload: PaywallPayload
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Paywall")
                .font(.title2)
                .bold()
            Text(payload.offerTitle)
                .font(.headline)
            Text(payload.offerSubtitle)
                .multilineTextAlignment(.center)
            Text("Source: \(payload.source)")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Button("Close", action: onClose)
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
    }
}
