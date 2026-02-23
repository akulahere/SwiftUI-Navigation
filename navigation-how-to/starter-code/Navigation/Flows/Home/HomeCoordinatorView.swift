import SwiftUI

struct HomeCoordinatorView: View {
    @EnvironmentObject private var router: AppRouter
    private var homeRouter: any HomeRouting { router }
    private var successRouter: any SuccessRouting { router }

    var body: some View {
        NavigationStack(path: $router.homeStack) {
            VStack(spacing: 16) {
                Text("Home Root")
                Button("Open Details") { homeRouter.homePush(.details(id: UUID())) }
                Button("Show Success") {
                    // Main flow success uses default .sheet style.
                    successRouter.presentSuccess(
                        title: "Success",
                        message: "Action completed.",
                        primaryButton: "OK",
                        primaryAction: .dismiss
                    )
                }
            }
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .details(let id):
                    Text("Details \(id.uuidString.prefix(6))")
                case .filters:
                    Text("Filters")
                }
            }
        }
    }
}
