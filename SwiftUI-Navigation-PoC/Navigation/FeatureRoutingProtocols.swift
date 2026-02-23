//
//  FeatureRoutingProtocols.swift
//  SwiftUI-Navigation-PoC
//

import Foundation

@MainActor
protocol OnboardingRouting: AnyObject {
    var onboardingStack: [AppRouter.OnboardingRoute] { get set }
    var isPaywallPresented: Bool { get set }
    var flow: AppRouter.Flow { get set }
    var selectedTab: AppRouter.Tab { get set }

    func onboardingPush(_ route: AppRouter.OnboardingRoute)
    func onboardingPopToRoot()
    func presentPaywall()
    func dismissPaywall()
    func finishOnboardingAndGoAuthorized()
}

@MainActor
protocol Tab1Routing: AnyObject {
    var tab1Stack: [AppRouter.Tab1Route] { get set }

    func tab1Push(_ route: AppRouter.Tab1Route)
    func tab1Pop(_ n: Int)
    func tab1PopToRoot()
}

@MainActor
protocol Tab2Routing: AnyObject {
    var tab2Stack: [AppRouter.Tab2Route] { get set }

    func tab2Push(_ route: AppRouter.Tab2Route)
    func tab2Pop(_ n: Int)
    func tab2PopToRoot()
}

@MainActor
protocol SuccessRouting: AnyObject {
    var successPayload: AppRouter.SuccessPayload? { get set }
    var flow: AppRouter.Flow { get set }
    var selectedTab: AppRouter.Tab { get set }

    func presentSuccess(
        title: String,
        message: String,
        primaryButton: String,
        primaryAction: AppRouter.SuccessAction
    )

    func handleSuccessPrimary()
}
