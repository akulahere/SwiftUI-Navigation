import Foundation

extension AppRouter: NavigationCommandHandling {
    // Keep cross-flow transitions in one place.
    func handleCommand(_ command: NavigationCommand) {
        switch command {
        case .goAuthorizedHomeRoot:
            onboardingStack.removeAll()
            homeStack.removeAll()
            profileStack.removeAll()
            dismissPaywall()
            flow = .authorized
            selectedTab = .home

        case .goAuthorizedProfileRoot:
            onboardingStack.removeAll()
            homeStack.removeAll()
            profileStack.removeAll()
            dismissPaywall()
            flow = .authorized
            selectedTab = .profile

        case .logoutToOnboarding:
            onboardingStack.removeAll()
            homeStack.removeAll()
            profileStack.removeAll()
            dismissPaywall()
            selectedTab = .home
            flow = .onboarding
        }

        track(.commandHandled(command))
    }
}
