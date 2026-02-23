import SwiftUI

struct ProfileCoordinatorView: View {
    @EnvironmentObject private var router: AppRouter
    private var profileRouter: any ProfileRouting { router }
    private var successRouter: any SuccessRouting { router }

    var body: some View {
        NavigationStack(path: $router.profileStack) {
            VStack(spacing: 16) {
                Text("Profile Root")
                Button("Edit") { profileRouter.profilePush(.edit) }
                Button("Notifications") { profileRouter.profilePush(.notifications) }
                Button("Logout") {
                    successRouter.presentSuccess(
                        title: "Log out?",
                        message: "This will reset state and return to onboarding.",
                        primaryButton: "Log out",
                        primaryAction: .logoutToOnboarding
                    )
                }
            }
            .navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                case .edit:
                    VStack(spacing: 16) {
                        Text("Edit Profile")
                        Button("Open Notifications") {
                            profileRouter.profilePush(.notifications)
                        }
                    }
                case .notifications:
                    VStack(spacing: 16) {
                        Text("Notifications")
                        Button("Back to Edit (popTo)") {
                            // Example of returning to a specific screen in a stack.
                            profileRouter.profilePopTo(.edit)
                        }
                    }
                }
            }
        }
    }
}
