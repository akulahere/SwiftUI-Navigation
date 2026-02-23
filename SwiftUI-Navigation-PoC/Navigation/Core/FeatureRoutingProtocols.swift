//
//  FeatureRoutingProtocols.swift
//  SwiftUI-Navigation-PoC
//

import Foundation

@MainActor
protocol OnboardingRouting: AnyObject {
    // MARK: - Default variables

    var onboardingStack: [OnboardingRoute] { get set }
    var isPaywallPresented: Bool { get set }

    // MARK: - Default functions

    func onboardingPush(_ route: OnboardingRoute)
    func onboardingPopToRoot()
    func presentPaywall()
    func dismissPaywall()
}

@MainActor
protocol Tab1Routing: AnyObject {
    // MARK: - Default variables

    var tab1Stack: [Tab1Route] { get set }

    // MARK: - Default functions

    func tab1Push(_ route: Tab1Route)
    func tab1Pop(_ n: Int)
    func tab1PopToRoot()
}

@MainActor
protocol Tab2Routing: AnyObject {
    // MARK: - Default variables

    var tab2Stack: [Tab2Route] { get set }

    // MARK: - Default functions

    func tab2Push(_ route: Tab2Route)
    func tab2Pop(_ n: Int)
    func tab2PopToRoot()
}

@MainActor
protocol SuccessRouting: AnyObject {
    // MARK: - Default variables

    var successPayload: SuccessPayload? { get set }
    var flow: Flow { get set }
    var selectedTab: Tab { get set }

    // MARK: - Default functions

    func presentSuccess(
        title: String,
        message: String,
        primaryButton: String,
        primaryAction: SuccessAction
    )

    func handleSuccessPrimary()
}
