import Foundation

struct ChatConversation: Equatable, Identifiable, Sendable {
    let id: UUID
    var title: String
    let createdAt: Date
    var updatedAt: Date
    var modelID: String?
    var providerID: String?

    nonisolated init(
        id: UUID = UUID(),
        title: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        modelID: String? = nil,
        providerID: String? = nil
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.modelID = modelID
        self.providerID = providerID
    }
}
