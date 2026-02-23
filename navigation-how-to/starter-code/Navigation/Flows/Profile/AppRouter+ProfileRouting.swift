import Foundation

extension AppRouter: ProfileRouting {
    func profilePush(_ route: ProfileRoute) {
        profileStack.append(route)
        track(.profilePushed(route))
    }

    func profilePop(_ n: Int = 1) {
        let count = min(max(n, 0), profileStack.count)
        guard count > 0 else { return }
        profileStack.removeLast(count)
        track(.profilePopped(count: count))
    }

    func profilePopTo(_ route: ProfileRoute) {
        guard let index = profileStack.lastIndex(of: route) else { return }
        let count = profileStack.distance(from: index, to: profileStack.endIndex) - 1
        guard count > 0 else { return }
        profileStack.removeLast(count)
        track(.profilePoppedTo(route))
    }

    func profilePopToRoot() {
        guard profileStack.isEmpty == false else { return }
        profileStack.removeAll()
        track(.profilePoppedToRoot)
    }
}
