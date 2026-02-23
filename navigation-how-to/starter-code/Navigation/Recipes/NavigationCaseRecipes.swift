import Foundation

// Code recipes for typical navigation changes.
enum NavigationCaseRecipes {}

@MainActor
extension AppRouter {
    // Recipe: go to start of a flow (cross-flow reset).
    func recipeGoToOnboardingStart() {
        handleCommand(.logoutToOnboarding)
    }

    // Recipe: go to authorized area and open a specific tab root.
    func recipeGoToProfileRoot() {
        handleCommand(.goAuthorizedProfileRoot)
    }

    // Recipe: pop N screens back safely.
    func recipePopTwoInHome() {
        homePop(2)
    }

    // Recipe: return to a specific screen in current stack.
    func recipeBackToEditInProfile() {
        profilePopTo(.edit)
    }

    // Recipe: flow-local common screen with parameters.
    func recipeShowOnboardingPaywall() {
        presentPaywall(
            source: "recipe",
            offerTitle: "Premium Annual",
            offerSubtitle: "7-day trial"
        )
    }

    // Recipe: app-global common screen from any flow.
    func recipeShowGlobalSuccessSheet() {
        presentSuccess(
            title: "Saved",
            message: "Your changes were saved.",
            primaryButton: "OK",
            primaryAction: .dismiss,
            presentationStyle: .sheet
        )
    }
}

// Recipe: add analytics without touching feature views.
final class PrintNavigationAnalyticsTracker: NavigationAnalyticsTracking {
    func track(_ event: NavigationEvent) {
        print("Navigation event:", event)
    }
}
