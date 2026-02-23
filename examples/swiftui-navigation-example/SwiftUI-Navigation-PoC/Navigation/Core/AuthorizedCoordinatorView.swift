//
//  AuthorizedCoordinatorView.swift
//  SwiftUI-Navigation-PoC
//

import SwiftUI

struct AuthorizedCoordinatorView: View {
    // MARK: - Private variables

    @EnvironmentObject private var router: AppRouter

    // MARK: - Other

    var body: some View {
        TabView(selection: $router.selectedTab) {
            Tab1CoordinatorView()
                .environmentObject(router)
                .tabItem { Label("Tab 1", systemImage: "house") }
                .tag(Tab.tab1)

            Tab2CoordinatorView()
                .environmentObject(router)
                .tabItem { Label("Tab 2", systemImage: "person") }
                .tag(Tab.tab2)
        }
    }
}
