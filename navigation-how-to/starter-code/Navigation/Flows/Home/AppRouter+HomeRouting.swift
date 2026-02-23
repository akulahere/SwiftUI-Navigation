import Foundation

extension AppRouter: HomeRouting {
    func homePush(_ route: HomeRoute) {
        homeStack.append(route)
        track(.homePushed(route))
    }

    func homePop(_ n: Int = 1) {
        let count = min(max(n, 0), homeStack.count)
        guard count > 0 else { return }
        homeStack.removeLast(count)
        track(.homePopped(count: count))
    }

    func homePopTo(_ route: HomeRoute) {
        guard let index = homeStack.lastIndex(of: route) else { return }
        let count = homeStack.distance(from: index, to: homeStack.endIndex) - 1
        guard count > 0 else { return }
        homeStack.removeLast(count)
        track(.homePoppedTo(route))
    }

    func homePopToRoot() {
        guard homeStack.isEmpty == false else { return }
        homeStack.removeAll()
        track(.homePoppedToRoot)
    }
}
