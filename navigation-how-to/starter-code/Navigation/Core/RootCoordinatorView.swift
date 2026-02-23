import SwiftUI

struct RootCoordinatorView: View {
    @StateObject private var router = AppRouter()

    // Show only sheet-style success payload in .sheet.
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

    // Show only full-screen success payload in .fullScreenCover.
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

private struct SuccessView: View {
    let title: String
    let message: String
    let primaryButton: String
    let onPrimary: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(title).font(.title2).bold()
            Text(message).multilineTextAlignment(.center)
            Button(primaryButton, action: onPrimary)
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
    }
}
