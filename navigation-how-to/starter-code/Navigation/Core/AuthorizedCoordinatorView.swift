import SwiftUI

struct AuthorizedCoordinatorView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        TabView(selection: $router.selectedTab) {
            HomeCoordinatorView()
                .environmentObject(router)
                .tabItem { Label("Home", systemImage: "house") }
                .tag(Tab.home)

            ProfileCoordinatorView()
                .environmentObject(router)
                .tabItem { Label("Profile", systemImage: "person") }
                .tag(Tab.profile)
        }
    }
}
