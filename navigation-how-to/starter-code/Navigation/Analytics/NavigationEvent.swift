import Foundation

// Keep events explicit so navigation analytics stay predictable.
enum NavigationEvent: Equatable {
    case onboardingPushed(OnboardingRoute)
    case onboardingPopped(count: Int)
    case onboardingPoppedTo(OnboardingRoute)
    case onboardingPoppedToRoot

    case homePushed(HomeRoute)
    case homePopped(count: Int)
    case homePoppedTo(HomeRoute)
    case homePoppedToRoot

    case profilePushed(ProfileRoute)
    case profilePopped(count: Int)
    case profilePoppedTo(ProfileRoute)
    case profilePoppedToRoot

    case paywallPresented(source: String)
    case paywallDismissed

    case successPresented(style: SuccessPresentationStyle)
    case successPrimaryHandled(SuccessAction)

    case commandHandled(NavigationCommand)
}
