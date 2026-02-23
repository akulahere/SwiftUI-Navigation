//
//  SuccessView.swift
//  SwiftUI-Navigation-PoC
//

import SwiftUI

struct SuccessView: View {
    let title: String
    let message: String
    let primaryButton: String
    let onPrimary: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(title).font(.title).bold()
            Text(message).multilineTextAlignment(.center)

            Button(primaryButton) { onPrimary() }
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
    }
}
