//
//  AppRouter+OnboardingRouting.swift
//  SwiftUI-Navigation-PoC
//

import Foundation

extension AppRouter: OnboardingRouting {
    // MARK: - Default functions

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
}
