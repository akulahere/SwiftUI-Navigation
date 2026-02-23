//
//  AppRouterRouteCommandTests.swift
//  SwiftUI-Navigation-PoCTests
//

import Testing
@testable import SwiftUI_Navigation_PoC

@MainActor
struct AppRouterRouteCommandTests {
    @Test
    func goAuthorizedTab1Root_resetsStateAndSelectsTab1() {
        let router = AppRouter()
        router.onboardingStack = [.step2, .step3]
        router.tab1Stack = [.screen2, .screen3(id: 7)]
        router.tab2Stack = [.a, .b]
        router.isPaywallPresented = true
        router.selectedTab = .tab2
        router.flow = .onboarding

        router.handleRouteCommand(.goAuthorizedTab1Root)

        #expect(router.flow == .authorized)
        #expect(router.selectedTab == .tab1)
        #expect(router.onboardingStack.isEmpty)
        #expect(router.tab1Stack.isEmpty)
        #expect(router.tab2Stack.isEmpty)
        #expect(router.isPaywallPresented == false)
    }

    @Test
    func logoutToOnboarding_resetsStateAndSelectsTab1() {
        let router = AppRouter()
        router.onboardingStack = [.step2]
        router.tab1Stack = [.screen2]
        router.tab2Stack = [.a, .b, .c]
        router.isPaywallPresented = true
        router.selectedTab = .tab2
        router.flow = .authorized

        router.handleRouteCommand(.logoutToOnboarding)

        #expect(router.flow == .onboarding)
        #expect(router.selectedTab == .tab1)
        #expect(router.onboardingStack.isEmpty)
        #expect(router.tab1Stack.isEmpty)
        #expect(router.tab2Stack.isEmpty)
        #expect(router.isPaywallPresented == false)
    }

    @Test
    func handleSuccessPrimary_appliesRouteCommandAndClearsPayload() {
        let router = AppRouter()
        router.onboardingStack = [.step3]
        router.tab1Stack = [.screen4]
        router.tab2Stack = [.a]
        router.isPaywallPresented = true
        router.flow = .onboarding
        router.selectedTab = .tab1
        router.successPayload = .init(
            title: "Done",
            message: "Switch",
            primaryButton: "Go",
            primaryAction: .goAuthorizedTab2Root
        )

        router.handleSuccessPrimary()

        #expect(router.successPayload == nil)
        #expect(router.flow == .authorized)
        #expect(router.selectedTab == .tab2)
        #expect(router.onboardingStack.isEmpty)
        #expect(router.tab1Stack.isEmpty)
        #expect(router.tab2Stack.isEmpty)
        #expect(router.isPaywallPresented == false)
    }
}
