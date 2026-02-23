//
//  AppRouter.swift
//  SwiftUI-Navigation-PoC
//
//  Created by Dmytro Akulinin on 23.02.2026.
//

import SwiftUI
import Observation
import Combine

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
            tab1PopToRoot()
            tab2PopToRoot()
            selectedTab = .tab1
            flow = .onboarding
            onboardingPopToRoot()
            dismissPaywall()
        }
    }
}
