//
//  PaywallSheetView.swift
//  SwiftUI-Navigation-PoC
//

import SwiftUI

struct PaywallSheetView: View {
    let onClose: () -> Void
    let onPurchased: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Paywall").font(.title2).bold()

            Button("Close", action: onClose)
                .buttonStyle(.bordered)

            Button("Purchase", action: onPurchased)
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
    }
}
