//
//  RootCoordinatorView.swift
//  SwiftUI-Navigation-PoC
//

import SwiftUI

struct RootCoordinatorView: View {
    @StateObject private var router = AppRouter()

    var body: some View {
        Group {
            switch router.flow {
            case .onboarding:
                OnboardingCoordinatorView()
                    .environmentObject(router)

            case .authorized:
                AuthorizedCoordinatorView()
                    .environmentObject(router)
            }
        }
        .sheet(item: $router.successPayload) { payload in
            SuccessView(
                title: payload.title,
                message: payload.message,
                primaryButton: payload.primaryButton,
                onPrimary: { router.handleSuccessPrimary() }
            )
        }
    }
}

#Preview {
    RootCoordinatorView()
}
