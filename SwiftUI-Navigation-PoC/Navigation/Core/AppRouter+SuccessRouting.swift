//
//  AppRouter+SuccessRouting.swift
//  SwiftUI-Navigation-PoC
//

import Foundation

extension AppRouter: SuccessRouting {
    // MARK: - Default functions

    func presentSuccess(
        title: String,
        message: String,
        primaryButton: String,
        primaryAction: SuccessAction
    ) {
        successPayload = .init(
            title: title,
            message: message,
            primaryButton: primaryButton,
            primaryAction: primaryAction
        )
    }

    func handleSuccessPrimary() {
        guard let payload = successPayload else { return }
        successPayload = nil

        guard let command = payload.primaryAction.routeCommand else { return }
        handleRouteCommand(command)
    }
}
