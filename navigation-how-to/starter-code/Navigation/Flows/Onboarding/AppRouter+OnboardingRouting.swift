import Foundation

extension AppRouter: OnboardingRouting {
    func onboardingPush(_ route: OnboardingRoute) {
        onboardingStack.append(route)
        track(.onboardingPushed(route))
    }

    func onboardingPop(_ n: Int = 1) {
        let count = min(max(n, 0), onboardingStack.count)
        guard count > 0 else { return }
        onboardingStack.removeLast(count)
        track(.onboardingPopped(count: count))
    }

    func onboardingPopTo(_ route: OnboardingRoute) {
        guard let index = onboardingStack.lastIndex(of: route) else { return }
        let count = onboardingStack.distance(from: index, to: onboardingStack.endIndex) - 1
        guard count > 0 else { return }
        onboardingStack.removeLast(count)
        track(.onboardingPoppedTo(route))
    }

    func onboardingPopToRoot() {
        guard onboardingStack.isEmpty == false else { return }
        onboardingStack.removeAll()
        track(.onboardingPoppedToRoot)
    }

    func presentPaywall(source: String, offerTitle: String, offerSubtitle: String) {
        paywallPayload = .init(
            source: source,
            offerTitle: offerTitle,
            offerSubtitle: offerSubtitle
        )
        track(.paywallPresented(source: source))
    }

    func dismissPaywall() {
        guard paywallPayload != nil else { return }
        paywallPayload = nil
        track(.paywallDismissed)
    }
}
