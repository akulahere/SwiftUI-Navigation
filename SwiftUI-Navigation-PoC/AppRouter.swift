//
//  AppRouter.swift
//  SwiftUI-Navigation-PoC
//
//  Created by Dmytro Akulinin on 23.02.2026.
//


import SwiftUI
import Observation
import Combine
// MARK: - Router

@MainActor
final class AppRouter: ObservableObject {

    enum Flow: Equatable {
        case onboarding
        case authorized
    }

    enum Tab: Hashable { case tab1, tab2 }

    // MARK: Global state
    @Published var flow: Flow = .onboarding
    @Published var selectedTab: Tab = .tab1

    // MARK: Global "Success" (can be shown from anywhere)
    @Published var successPayload: SuccessPayload? = nil

    struct SuccessPayload: Identifiable, Equatable {
        let id = UUID()
        let title: String
        let message: String
        let primaryButton: String
        let primaryAction: SuccessAction
    }

    enum SuccessAction: Equatable {
        case dismiss
        case goAuthorizedTab1Root
        case goAuthorizedTab2Root
        case logoutToOnboarding
    }

    // MARK: Onboarding navigation
    enum OnboardingRoute: Hashable {
        case step2
        case step3
    }

    @Published var onboardingStack: [OnboardingRoute] = []
    @Published var isPaywallPresented: Bool = false

    // MARK: Tab1 navigation
    enum Tab1Route: Hashable {
        case screen2
        case screen3(id: Int)
        case screen4
        case screen5
    }

    @Published var tab1Stack: [Tab1Route] = []

    // MARK: Tab2 navigation
    enum Tab2Route: Hashable {
        case a, b, c, d, e
    }

    @Published var tab2Stack: [Tab2Route] = []

    // MARK: - Navigation API (Onboarding)

    func onboardingPush(_ route: OnboardingRoute) {
        onboardingStack.append(route)
    }

    func onboardingPopToRoot() {
        onboardingStack.removeAll()
    }

    func presentPaywall() {
        isPaywallPresented = true
    }

    func dismissPaywall() {
        isPaywallPresented = false
    }

    func finishOnboardingAndGoAuthorized() {
        flow = .authorized
        onboardingPopToRoot()
        selectedTab = .tab1
        tab1PopToRoot()
        tab2PopToRoot()
    }

    // MARK: - Navigation API (Tabs)

    func tab1Push(_ route: Tab1Route) { tab1Stack.append(route) }
    func tab2Push(_ route: Tab2Route) { tab2Stack.append(route) }

    func tab1Pop(_ n: Int = 1) {
        let k = min(max(n, 0), tab1Stack.count)
        guard k > 0 else { return }
        tab1Stack.removeLast(k)
    }

    func tab2Pop(_ n: Int = 1) {
        let k = min(max(n, 0), tab2Stack.count)
        guard k > 0 else { return }
        tab2Stack.removeLast(k)
    }

    func tab1PopToRoot() { tab1Stack.removeAll() }
    func tab2PopToRoot() { tab2Stack.removeAll() }

    // Convenience: "pop a couple screens back" for the current tab
    func popBackTwoScreensInCurrentTab() {
        switch selectedTab {
        case .tab1: tab1Pop(2)
        case .tab2: tab2Pop(2)
        }
    }

    // MARK: - Success

    func presentSuccess(
        title: String,
        message: String,
        primaryButton: String,
        primaryAction: SuccessAction
    ) {
        successPayload = .init(
            title: title,
            message: message,
            primaryButton: primaryButton,
            primaryAction: primaryAction
        )
    }

    func handleSuccessPrimary() {
        guard let payload = successPayload else { return }
        successPayload = nil

        switch payload.primaryAction {
        case .dismiss:
            break

        case .goAuthorizedTab1Root:
            flow = .authorized
            selectedTab = .tab1
            tab1PopToRoot()

        case .goAuthorizedTab2Root:
            flow = .authorized
            selectedTab = .tab2
            tab2PopToRoot()

        case .logoutToOnboarding:
            // Full reset
            tab1PopToRoot()
            tab2PopToRoot()
            selectedTab = .tab1
            flow = .onboarding
            onboardingPopToRoot()
            dismissPaywall()
        }
    }
}

// MARK: - Root Coordinator

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
        // Global Success sheet
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

// MARK: - Onboarding Coordinator (3 steps + Paywall sheet + pop-to-root)

struct OnboardingCoordinatorView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        NavigationStack(path: $router.onboardingStack) {
            OnboardingStep1View(
                onNext: { router.onboardingPush(.step2) }
            )
            .navigationDestination(for: AppRouter.OnboardingRoute.self) { route in
                switch route {
                case .step2:
                    OnboardingStep2View(
                        onShowPaywall: { router.presentPaywall() },
                        onNext: { router.onboardingPush(.step3) },
                        onPopToRoot: { router.onboardingPopToRoot() } // ✅ required
                    )

                case .step3:
                    OnboardingStep3View(
                        onFinish: {
                            // show global success, then go authorized
                            router.presentSuccess(
                                title: "Готово!",
                                message: "Онбординг завершён.",
                                primaryButton: "В приложение",
                                primaryAction: .goAuthorizedTab1Root
                            )
                            router.finishOnboardingAndGoAuthorized()
                        },
                        onPopToRoot: { router.onboardingPopToRoot() } // optional convenience
                    )
                }
            }
        }
        .sheet(isPresented: $router.isPaywallPresented) {
            PaywallSheetView(
                onClose: { router.dismissPaywall() },
                onPurchased: {
                    router.dismissPaywall()
                    router.presentSuccess(
                        title: "Покупка успешна",
                        message: "Доступ открыт.",
                        primaryButton: "Продолжить",
                        primaryAction: .dismiss
                    )
                }
            )
            .presentationDetents([.medium, .large])
        }
    }
}

// MARK: - Authorized Coordinator (TabView + 2 stacks + pop-back-2)

struct AuthorizedCoordinatorView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        TabView(selection: $router.selectedTab) {

            Tab1CoordinatorView()
                .environmentObject(router)
                .tabItem { Label("Tab 1", systemImage: "house") }
                .tag(AppRouter.Tab.tab1)

            Tab2CoordinatorView()
                .environmentObject(router)
                .tabItem { Label("Tab 2", systemImage: "person") }
                .tag(AppRouter.Tab.tab2)
        }
    }
}

// MARK: - Tab1 Coordinator

struct Tab1CoordinatorView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        NavigationStack(path: $router.tab1Stack) {
            Tab1RootView(
                goNext: { router.tab1Push(.screen2) },
                popBackTwo: { router.tab1Pop(2) }, // ✅ required
                showSuccess: {
                    router.presentSuccess(
                        title: "Успех",
                        message: "Общий Success показан из Tab1.",
                        primaryButton: "Ок",
                        primaryAction: .dismiss
                    )
                }
            )
            .navigationDestination(for: AppRouter.Tab1Route.self) { route in
                switch route {
                case .screen2:
                    ScreenView(title: "Tab1 Screen2") {
                        router.tab1Push(.screen3(id: 42))
                    }

                case .screen3(let id):
                    ScreenView(title: "Tab1 Screen3 id=\(id)") {
                        router.tab1Push(.screen4)
                    }

                case .screen4:
                    ScreenView(title: "Tab1 Screen4") {
                        router.tab1Push(.screen5)
                    }

                case .screen5:
                    VStack(spacing: 16) {
                        Text("Tab1 Screen5")
                            .font(.title2).bold()

                        Button("Pop back 2 screens") {
                            router.tab1Pop(2) // ✅ required
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Go to Tab1 root") {
                            router.tab1PopToRoot()
                        }
                        .buttonStyle(.bordered)

                        Button("Show Success -> Tab2 root") {
                            router.presentSuccess(
                                title: "Готово",
                                message: "Перекидываем на корень Tab2.",
                                primaryButton: "На Tab2",
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
                        router.tab1Pop(2) // quick demo action
                    }
                }
            }
        }
    }
}

// MARK: - Tab2 Coordinator

struct Tab2CoordinatorView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        NavigationStack(path: $router.tab2Stack) {
            Tab2RootView(
                goNext: { router.tab2Push(.a) },
                popBackTwo: { router.tab2Pop(2) }, // ✅ required
                logout: {
                    router.presentSuccess(
                        title: "Выйти?",
                        message: "Сбросим состояние и вернёмся в онбординг.",
                        primaryButton: "Выйти",
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
                            router.tab2Pop(2) // ✅ required
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Pop to root") {
                            router.tab2PopToRoot()
                        }
                        .buttonStyle(.bordered)

                        Button("Show Success (dismiss only)") {
                            router.presentSuccess(
                                title: "Успех",
                                message: "Просто закрываем success.",
                                primaryButton: "Ок",
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

// MARK: - Common reusable Views (placeholders)

struct SuccessView: View {
    let title: String
    let message: String
    let primaryButton: String
    let onPrimary: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(title).font(.title).bold()
            Text(message).multilineTextAlignment(.center)

            Button(primaryButton) { onPrimary() }
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
    }
}

struct ScreenView: View {
    let title: String
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(title).font(.title2).bold()
            Button("Next", action: onNext)
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
    }
}

struct OnboardingStep1View: View {
    let onNext: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Text("Onboarding Step 1").font(.title2).bold()
            Button("Next", action: onNext)
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
    }
}

struct OnboardingStep2View: View {
    let onShowPaywall: () -> Void
    let onNext: () -> Void
    let onPopToRoot: () -> Void // ✅ required

    var body: some View {
        VStack(spacing: 16) {
            Text("Onboarding Step 2").font(.title2).bold()

            Button("Show Paywall", action: onShowPaywall)
                .buttonStyle(.bordered)

            Button("Next", action: onNext)
                .buttonStyle(.borderedProminent)

            Button("Pop to root (Step1)", action: onPopToRoot) // ✅
                .buttonStyle(.bordered)
        }
        .padding(24)
    }
}

struct OnboardingStep3View: View {
    let onFinish: () -> Void
    let onPopToRoot: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Onboarding Step 3").font(.title2).bold()

            Button("Finish", action: onFinish)
                .buttonStyle(.borderedProminent)

            Button("Pop to root (Step1)", action: onPopToRoot)
                .buttonStyle(.bordered)
        }
        .padding(24)
    }
}

struct PaywallSheetView: View {
    let onClose: () -> Void
    let onPurchased: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Paywall").font(.title2).bold()

            Button("Close", action: onClose)
                .buttonStyle(.bordered)

            Button("Purchase", action: onPurchased)
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
    }
}

struct Tab1RootView: View {
    let goNext: () -> Void
    let popBackTwo: () -> Void
    let showSuccess: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Tab1 Root").font(.title2).bold()

            Button("Go Screen2", action: goNext)
                .buttonStyle(.borderedProminent)

            Button("Pop back 2 (no-op on root)", action: popBackTwo) // ✅
                .buttonStyle(.bordered)

            Button("Show Success", action: showSuccess)
                .buttonStyle(.bordered)
        }
        .padding(24)
    }
}

struct Tab2RootView: View {
    let goNext: () -> Void
    let popBackTwo: () -> Void
    let logout: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Tab2 Root").font(.title2).bold()

            Button("Go A", action: goNext)
                .buttonStyle(.borderedProminent)

            Button("Pop back 2 (no-op on root)", action: popBackTwo) // ✅
                .buttonStyle(.bordered)

            Button("Logout (via Success)", action: logout)
                .buttonStyle(.bordered)
        }
        .padding(24)
    }
}

// MARK: - Preview

#Preview {
    RootCoordinatorView()
}
