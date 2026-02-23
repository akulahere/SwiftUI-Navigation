//
//  Tab1CoordinatorView.swift
//  SwiftUI-Navigation-PoC
//

import SwiftUI

struct Tab1CoordinatorView: View {
    // MARK: - Private variables

    @EnvironmentObject private var router: AppRouter
    private var tab1Router: any Tab1Routing { router }
    private var successRouter: any SuccessRouting { router }

    // MARK: - Other

    var body: some View {
        NavigationStack(path: $router.tab1Stack) {
            Tab1RootView(
                goNext: { tab1Router.tab1Push(.screen2) },
                popBackTwo: { tab1Router.tab1Pop(2) },
                showSuccess: {
                    successRouter.presentSuccess(
                        title: "Success",
                        message: "Global success was shown from Tab1.",
                        primaryButton: "OK",
                        primaryAction: .dismiss
                    )
                }
            )
            .navigationDestination(for: Tab1Route.self) { route in
                switch route {
                case .screen2:
                    ScreenView(title: "Tab1 Screen2") {
                        tab1Router.tab1Push(.screen3(id: 42))
                    }

                case .screen3(let id):
                    ScreenView(title: "Tab1 Screen3 id=\(id)") {
                        tab1Router.tab1Push(.screen4)
                    }

                case .screen4:
                    ScreenView(title: "Tab1 Screen4") {
                        tab1Router.tab1Push(.screen5)
                    }

                case .screen5:
                    VStack(spacing: 16) {
                        Text("Tab1 Screen5")
                            .font(.title2).bold()

                        Button("Pop back 2 screens") {
                            tab1Router.tab1Pop(2)
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Go to Tab1 root") {
                            tab1Router.tab1PopToRoot()
                        }
                        .buttonStyle(.bordered)

                        Button("Show Success -> Tab2 root") {
                            successRouter.presentSuccess(
                                title: "Done",
                                message: "Switching to Tab2 root.",
                                primaryButton: "Go to Tab2",
                                primaryAction: .goAuthorizedTab2Root
                            )
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(24)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("←← 2 back") {
                        tab1Router.tab1Pop(2)
                    }
                }
            }
        }
    }
}
