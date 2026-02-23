//
//  AppRouter+OnboardingRouting.swift
//  SwiftUI-Navigation-PoC
//

import Foundation

extension AppRouter: OnboardingRouting {
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
}
