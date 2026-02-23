import Foundation

// Data required to present global success UI.
struct SuccessPayload: Identifiable, Equatable {
    let id: UUID
    let title: String
    let message: String
    let primaryButton: String
    let primaryAction: SuccessAction
    let presentationStyle: SuccessPresentationStyle

    init(
        id: UUID = UUID(),
        title: String,
        message: String,
        primaryButton: String,
        primaryAction: SuccessAction,
        presentationStyle: SuccessPresentationStyle = .sheet
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.primaryAction = primaryAction
        self.presentationStyle = presentationStyle
    }
}
