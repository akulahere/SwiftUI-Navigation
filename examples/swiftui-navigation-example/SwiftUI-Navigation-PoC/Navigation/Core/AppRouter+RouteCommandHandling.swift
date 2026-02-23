//
//  AppRouter+RouteCommandHandling.swift
//  SwiftUI-Navigation-PoC
//

import Foundation

@MainActor
protocol AppRouteCommandHandling: AnyObject {
    func handleRouteCommand(_ command: AppRouteCommand)
}

extension AppRouter: AppRouteCommandHandling {
    // MARK: - Default functions

    func handleRouteCommand(_ command: AppRouteCommand) {
        switch command {
        case .goAuthorizedTab1Root:
            onboardingPopToRoot()
            tab1PopToRoot()
            tab2PopToRoot()
            dismissPaywall()
            flow = .authorized
            selectedTab = .tab1

        case .goAuthorizedTab2Root:
            onboardingPopToRoot()
            tab1PopToRoot()
            tab2PopToRoot()
            dismissPaywall()
            flow = .authorized
            selectedTab = .tab2

        case .logoutToOnboarding:
            onboardingPopToRoot()
            tab1PopToRoot()
            tab2PopToRoot()
            dismissPaywall()
            selectedTab = .tab1
            flow = .onboarding
        }
    }
}
