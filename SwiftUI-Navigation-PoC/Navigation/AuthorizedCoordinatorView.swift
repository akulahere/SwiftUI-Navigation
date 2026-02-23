//
//  AuthorizedCoordinatorView.swift
//  SwiftUI-Navigation-PoC
//

import SwiftUI

struct AuthorizedCoordinatorView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        TabView(selection: $router.selectedTab) {
            Tab1CoordinatorView()
                .environmentObject(router)
                .tabItem { Label("Tab 1", systemImage: "house") }
                .tag(AppRouter.Tab.tab1)

            Tab2CoordinatorView()
                .environmentObject(router)
                .tabItem { Label("Tab 2", systemImage: "person") }
                .tag(AppRouter.Tab.tab2)
        }
    }
}
