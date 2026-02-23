import Foundation

// Cross-flow transitions go through commands.
enum NavigationCommand: Equatable {
    case goAuthorizedHomeRoot
    case goAuthorizedProfileRoot
    case logoutToOnboarding
}
