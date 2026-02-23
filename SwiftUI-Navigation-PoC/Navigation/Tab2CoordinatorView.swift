//
//  Tab2CoordinatorView.swift
//  SwiftUI-Navigation-PoC
//

import SwiftUI

struct Tab2CoordinatorView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        NavigationStack(path: $router.tab2Stack) {
            Tab2RootView(
                goNext: { router.tab2Push(.a) },
                popBackTwo: { router.tab2Pop(2) },
                logout: {
                    router.presentSuccess(
                        title: "Log out?",
                        message: "This will reset state and return to onboarding.",
                        primaryButton: "Log out",
                        primaryAction: .logoutToOnboarding
                    )
                }
            )
            .navigationDestination(for: AppRouter.Tab2Route.self) { route in
                switch route {
                case .a:
                    ScreenView(title: "Tab2 A") { router.tab2Push(.b) }
                case .b:
                    ScreenView(title: "Tab2 B") { router.tab2Push(.c) }
                case .c:
                    ScreenView(title: "Tab2 C") { router.tab2Push(.d) }
                case .d:
                    ScreenView(title: "Tab2 D") { router.tab2Push(.e) }
                case .e:
                    VStack(spacing: 16) {
                        Text("Tab2 E")
                            .font(.title2).bold()

                        Button("Pop back 2 screens") {
                            router.tab2Pop(2)
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Pop to root") {
                            router.tab2PopToRoot()
                        }
                        .buttonStyle(.bordered)

                        Button("Show Success (dismiss only)") {
                            router.presentSuccess(
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
