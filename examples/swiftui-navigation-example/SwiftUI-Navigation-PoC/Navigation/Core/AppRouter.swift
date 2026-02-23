//
//  AppRouter.swift
//  SwiftUI-Navigation-PoC
//
//  Created by Dmytro Akulinin on 23.02.2026.
//

import SwiftUI
import Combine

@MainActor
final class AppRouter: ObservableObject {
    // MARK: - Default variables

    // Shared state
    @Published var flow: Flow = .onboarding
    @Published var selectedTab: Tab = .tab1
    @Published var successPayload: SuccessPayload?

    // Onboarding state
    @Published var onboardingStack: [OnboardingRoute] = []
    @Published var isPaywallPresented = false

    // Feature state
    @Published var tab1Stack: [Tab1Route] = []
    @Published var tab2Stack: [Tab2Route] = []
}
