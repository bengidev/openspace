import SwiftData

enum OpenSpaceModelContainer {
    static let schema = Schema([
        OnboardingProgressEntity.self,
        ChatConversationRecord.self,
        ChatMessageRecord.self,
    ])

    static let shared: ModelContainer = {
        do {
            return try makeModelContainer(isStoredInMemoryOnly: false)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    static func makeInMemory() throws -> ModelContainer {
        try makeModelContainer(isStoredInMemoryOnly: true)
    }

    private static func makeModelContainer(isStoredInMemoryOnly: Bool) throws -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: isStoredInMemoryOnly
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
