//
//  Tab1RootView.swift
//  SwiftUI-Navigation-PoC
//

import SwiftUI

struct Tab1RootView: View {
    let goNext: () -> Void
    let popBackTwo: () -> Void
    let showSuccess: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Tab1 Root").font(.title2).bold()

            Button("Go Screen2", action: goNext)
                .buttonStyle(.borderedProminent)

            Button("Pop back 2 (no-op on root)", action: popBackTwo)
                .buttonStyle(.bordered)

            Button("Show Success", action: showSuccess)
                .buttonStyle(.bordered)
        }
        .padding(24)
    }
}
