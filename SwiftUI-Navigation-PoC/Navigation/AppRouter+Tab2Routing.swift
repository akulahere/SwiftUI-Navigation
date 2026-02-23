//
//  AppRouter+Tab2Routing.swift
//  SwiftUI-Navigation-PoC
//

import Foundation

extension AppRouter: Tab2Routing {
    func tab2Push(_ route: Tab2Route) {
        tab2Stack.append(route)
    }

    func tab2Pop(_ n: Int = 1) {
        let count = min(max(n, 0), tab2Stack.count)
        guard count > 0 else { return }
        tab2Stack.removeLast(count)
    }

    func tab2PopToRoot() {
        tab2Stack.removeAll()
    }
}
