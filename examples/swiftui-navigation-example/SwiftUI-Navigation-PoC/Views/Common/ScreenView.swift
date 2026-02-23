//
//  ScreenView.swift
//  SwiftUI-Navigation-PoC
//

import SwiftUI

struct ScreenView: View {
    let title: String
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(title).font(.title2).bold()
            Button("Next", action: onNext)
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
    }
}
