import SwiftUI

// Single source of truth for navigation state.
@MainActor
final class AppRouter: ObservableObject {
    // Shared state.
    @Published var flow: Flow = .onboarding
    @Published var selectedTab: Tab = .home

    // Stacks by flow/tab.
    @Published var onboardingStack: [OnboardingRoute] = []
    @Published var homeStack: [HomeRoute] = []
    @Published var profileStack: [ProfileRoute] = []

    // Flow-local overlays.
    @Published var paywallPayload: PaywallPayload?

    // Global overlays.
    @Published var successPayload: SuccessPayload?

    // Default dependencies.
    private let analyticsTracker: (any NavigationAnalyticsTracking)?

    init(analyticsTracker: (any NavigationAnalyticsTracking)? = nil) {
        self.analyticsTracker = analyticsTracker
    }

    func track(_ event: NavigationEvent) {
        analyticsTracker?.track(event)
    }
}
