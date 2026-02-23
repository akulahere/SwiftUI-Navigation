//
//  Tab2CoordinatorView.swift
//  SwiftUI-Navigation-PoC
//

import SwiftUI

struct Tab2CoordinatorView: View {
    // MARK: - Private variables

    @EnvironmentObject private var router: AppRouter
    private var tab2Router: any Tab2Routing { router }
    private var successRouter: any SuccessRouting { router }

    // MARK: - Other

    var body: some View {
        NavigationStack(path: $router.tab2Stack) {
            Tab2RootView(
                goNext: { tab2Router.tab2Push(.a) },
                popBackTwo: { tab2Router.tab2Pop(2) },
                logout: {
                    successRouter.presentSuccess(
                        title: "Log out?",
                        message: "This will reset state and return to onboarding.",
                        primaryButton: "Log out",
                        primaryAction: .logoutToOnboarding
                    )
                }
            )
            .navigationDestination(for: Tab2Route.self) { route in
                switch route {
                case .a:
                    ScreenView(title: "Tab2 A") { tab2Router.tab2Push(.b) }
                case .b:
                    ScreenView(title: "Tab2 B") { tab2Router.tab2Push(.c) }
                case .c:
                    ScreenView(title: "Tab2 C") { tab2Router.tab2Push(.d) }
                case .d:
                    ScreenView(title: "Tab2 D") { tab2Router.tab2Push(.e) }
                case .e:
                    VStack(spacing: 16) {
                        Text("Tab2 E")
                            .font(.title2).bold()

                        Button("Pop back 2 screens") {
                            tab2Router.tab2Pop(2)
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Pop to root") {
                            tab2Router.tab2PopToRoot()
                        }
                        .buttonStyle(.bordered)

                        Button("Show Success (dismiss only)") {
                            successRouter.presentSuccess(
                                title: "Success",
                                message: "Just dismiss this success screen.",
                                primaryButton: "OK",
                                primaryAction: .dismiss
                            )
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(24)
                }
            }
        }
    }
}
