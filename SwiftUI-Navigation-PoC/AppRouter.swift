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

    enum Tab: Hashable {
        case tab1
        case tab2
    }

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

    enum OnboardingRoute: Hashable {
        case step2
        case step3
    }

    enum Tab1Route: Hashable {
        case screen2
        case screen3(id: Int)
        case screen4
        case screen5
    }

    enum Tab2Route: Hashable {
        case a
        case b
        case c
        case d
        case e
    }

    // MARK: - Shared state

    @Published var flow: Flow = .onboarding
    @Published var selectedTab: Tab = .tab1
    @Published var successPayload: SuccessPayload?

    // MARK: - Onboarding state

    @Published var onboardingStack: [OnboardingRoute] = []
    @Published var isPaywallPresented = false

    // MARK: - Feature state

    @Published var tab1Stack: [Tab1Route] = []
    @Published var tab2Stack: [Tab2Route] = []
}
