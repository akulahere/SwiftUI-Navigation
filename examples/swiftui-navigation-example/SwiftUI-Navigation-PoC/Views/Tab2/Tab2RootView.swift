//
//  Tab2RootView.swift
//  SwiftUI-Navigation-PoC
//

import SwiftUI

struct Tab2RootView: View {
    let goNext: () -> Void
    let popBackTwo: () -> Void
    let logout: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Tab2 Root").font(.title2).bold()

            Button("Go A", action: goNext)
                .buttonStyle(.borderedProminent)

            Button("Pop back 2 (no-op on root)", action: popBackTwo)
                .buttonStyle(.bordered)

            Button("Logout (via Success)", action: logout)
                .buttonStyle(.bordered)
        }
        .padding(24)
    }
}
