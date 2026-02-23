import Foundation

// User intent from success UI.
enum SuccessAction: Equatable {
    case dismiss
    case goAuthorizedHomeRoot
    case goAuthorizedProfileRoot
    case logoutToOnboarding
}

extension SuccessAction {
    // Centralized mapping from UI action to routing command.
    var routeCommand: NavigationCommand? {
        switch self {
        case .dismiss:
            return nil
        case .goAuthorizedHomeRoot:
            return .goAuthorizedHomeRoot
        case .goAuthorizedProfileRoot:
            return .goAuthorizedProfileRoot
        case .logoutToOnboarding:
            return .logoutToOnboarding
        }
    }
}
