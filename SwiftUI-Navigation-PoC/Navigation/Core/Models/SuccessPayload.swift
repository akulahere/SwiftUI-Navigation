//
//  SuccessPayload.swift
//  SwiftUI-Navigation-PoC
//

import Foundation

struct SuccessPayload: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String
    let primaryButton: String
    let primaryAction: SuccessAction
}
