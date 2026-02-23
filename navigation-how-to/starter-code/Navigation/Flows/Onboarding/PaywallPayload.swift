import Foundation

// Flow-local common screen payload with parameters.
struct PaywallPayload: Identifiable, Equatable {
    let id: UUID
    let source: String
    let offerTitle: String
    let offerSubtitle: String

    init(
        id: UUID = UUID(),
        source: String,
        offerTitle: String,
        offerSubtitle: String
    ) {
        self.id = id
        self.source = source
        self.offerTitle = offerTitle
        self.offerSubtitle = offerSubtitle
    }
}
