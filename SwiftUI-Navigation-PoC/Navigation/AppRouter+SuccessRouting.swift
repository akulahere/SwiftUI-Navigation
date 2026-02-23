//
//  AppRouter+SuccessRouting.swift
//  SwiftUI-Navigation-PoC
//

import Foundation

extension AppRouter: SuccessRouting {
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
