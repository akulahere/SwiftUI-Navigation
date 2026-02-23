//
//  AppRouter+Tab1Routing.swift
//  SwiftUI-Navigation-PoC
//

import Foundation

extension AppRouter: Tab1Routing {
    func tab1Push(_ route: Tab1Route) {
        tab1Stack.append(route)
    }

    func tab1Pop(_ n: Int = 1) {
        let count = min(max(n, 0), tab1Stack.count)
        guard count > 0 else { return }
        tab1Stack.removeLast(count)
    }

    func tab1PopToRoot() {
        tab1Stack.removeAll()
    }
}
