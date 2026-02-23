//
//  SuccessAction.swift
//  SwiftUI-Navigation-PoC
//

import Foundation

enum SuccessAction: Equatable {
    case dismiss
    case goAuthorizedTab1Root
    case goAuthorizedTab2Root
    case logoutToOnboarding
}

extension SuccessAction {
    var routeCommand: AppRouteCommand? {
        switch self {
        case .dismiss:
            return nil
        case .goAuthorizedTab1Root:
            return .goAuthorizedTab1Root
        case .goAuthorizedTab2Root:
            return .goAuthorizedTab2Root
        case .logoutToOnboarding:
            return .logoutToOnboarding
        }
    }
}
