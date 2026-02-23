import Foundation

extension AppRouter: SuccessRouting {
    func presentSuccess(
        title: String,
        message: String,
        primaryButton: String,
        primaryAction: SuccessAction,
        presentationStyle: SuccessPresentationStyle
    ) {
        successPayload = .init(
            title: title,
            message: message,
            primaryButton: primaryButton,
            primaryAction: primaryAction,
            presentationStyle: presentationStyle
        )
        track(.successPresented(style: presentationStyle))
    }

    func handleSuccessPrimary() {
        guard let payload = successPayload else { return }
        let action = payload.primaryAction
        successPayload = nil
        track(.successPrimaryHandled(action))

        guard let command = action.routeCommand else { return }
        handleCommand(command)
    }
}
