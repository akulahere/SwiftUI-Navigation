import Foundation

@MainActor
protocol OnboardingRouting: AnyObject {
    var onboardingStack: [OnboardingRoute] { get set }
    var paywallPayload: PaywallPayload? { get set }

    func onboardingPush(_ route: OnboardingRoute)
    func onboardingPop(_ n: Int)
    func onboardingPopTo(_ route: OnboardingRoute)
    func onboardingPopToRoot()
    func presentPaywall(source: String, offerTitle: String, offerSubtitle: String)
    func dismissPaywall()
}

@MainActor
protocol HomeRouting: AnyObject {
    var homeStack: [HomeRoute] { get set }

    func homePush(_ route: HomeRoute)
    func homePop(_ n: Int)
    func homePopTo(_ route: HomeRoute)
    func homePopToRoot()
}

@MainActor
protocol ProfileRouting: AnyObject {
    var profileStack: [ProfileRoute] { get set }

    func profilePush(_ route: ProfileRoute)
    func profilePop(_ n: Int)
    func profilePopTo(_ route: ProfileRoute)
    func profilePopToRoot()
}

@MainActor
protocol SuccessRouting: AnyObject {
    var successPayload: SuccessPayload? { get set }

    func presentSuccess(
        title: String,
        message: String,
        primaryButton: String,
        primaryAction: SuccessAction,
        presentationStyle: SuccessPresentationStyle
    )

    func handleSuccessPrimary()
}

extension SuccessRouting {
    // Convenient default for regular (non-onboarding) screens.
    func presentSuccess(
        title: String,
        message: String,
        primaryButton: String,
        primaryAction: SuccessAction
    ) {
        presentSuccess(
            title: title,
            message: message,
            primaryButton: primaryButton,
            primaryAction: primaryAction,
            presentationStyle: .sheet
        )
    }
}

@MainActor
protocol NavigationCommandHandling: AnyObject {
    func handleCommand(_ command: NavigationCommand)
}
