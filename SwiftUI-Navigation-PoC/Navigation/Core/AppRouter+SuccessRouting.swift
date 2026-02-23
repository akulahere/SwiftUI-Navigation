//
//  AppRouter+SuccessRouting.swift
//  SwiftUI-Navigation-PoC
//

import Foundation

extension AppRouter: SuccessRouting {
    // MARK: - Default functions

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
            tab1PopToRoot()
            tab2PopToRoot()
            selectedTab = .tab1
            flow = .onboarding
            onboardingPopToRoot()
            dismissPaywall()
        }
    }
}
