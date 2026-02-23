//
//  RootCoordinatorView.swift
//  SwiftUI-Navigation-PoC
//

import SwiftUI

struct RootCoordinatorView: View {
    // MARK: - Private variables

    @StateObject private var router = AppRouter()

    private var sheetSuccessPayload: Binding<SuccessPayload?> {
        Binding(
            get: {
                guard let payload = router.successPayload else { return nil }
                return payload.presentationStyle == .sheet ? payload : nil
            },
            set: { newValue in
                if newValue == nil, router.successPayload?.presentationStyle == .sheet {
                    router.successPayload = nil
                }
            }
        )
    }

    private var fullScreenSuccessPayload: Binding<SuccessPayload?> {
        Binding(
            get: {
                guard let payload = router.successPayload else { return nil }
                return payload.presentationStyle == .fullScreen ? payload : nil
            },
            set: { newValue in
                if newValue == nil, router.successPayload?.presentationStyle == .fullScreen {
                    router.successPayload = nil
                }
            }
        )
    }

    // MARK: - Other

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
        .sheet(item: sheetSuccessPayload) { payload in
            SuccessView(
                title: payload.title,
                message: payload.message,
                primaryButton: payload.primaryButton,
                onPrimary: { router.handleSuccessPrimary() }
            )
        }
        .fullScreenCover(item: fullScreenSuccessPayload) { payload in
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
