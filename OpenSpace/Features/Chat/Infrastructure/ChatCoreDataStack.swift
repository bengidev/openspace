import CoreData
import Foundation

final class ChatCoreDataStack: @unchecked Sendable {
    static let shared = ChatCoreDataStack()

    private let model: NSManagedObjectModel
    private var loadedContainer: NSPersistentContainer?
    private var loadTask: Task<NSPersistentContainer, Error>?
    private let lock = NSLock()

    private init() {
        self.model = ChatCoreDataStack.createModel()
    }

    func container() async throws -> NSPersistentContainer {
        lock.lock()
        if let container = loadedContainer {
            lock.unlock()
            return container
        }
        if let task = loadTask {
            lock.unlock()
            return try await task.value
        }
        let task = Task {
            try await loadStores()
        }
        loadTask = task
        lock.unlock()

        let container = try await task.value

        lock.lock()
        loadedContainer = container
        lock.unlock()

        return container
    }

    private func loadStores() async throws -> NSPersistentContainer {
        let cloudContainer = NSPersistentCloudKitContainer(name: "ChatModel", managedObjectModel: model)

        guard let description = cloudContainer.persistentStoreDescriptions.first else {
            throw PersistenceError.missingStoreDescription
        }

        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        let cloudKitID = "iCloud.io.github.bengidev.OpenSpace"
        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: cloudKitID)

        do {
            let container: NSPersistentContainer = try await withCheckedThrowingContinuation { continuation in
                cloudContainer.loadPersistentStores { _, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: cloudContainer)
                    }
                }
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            return container
        } catch {
            let localContainer = NSPersistentContainer(name: "ChatModel", managedObjectModel: model)
            if let localDescription = localContainer.persistentStoreDescriptions.first {
                localDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            }
            let container: NSPersistentContainer = try await withCheckedThrowingContinuation { continuation in
                localContainer.loadPersistentStores { _, error in
                    if let error = error {
                        continuation.resume(throwing: PersistenceError.localStoreLoadFailed(error))
                    } else {
                        continuation.resume(returning: localContainer)
                    }
                }
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            return container
        }
    }

    static func createTestModel() -> NSManagedObjectModel {
        createModel()
    }

    private static func createModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let conversationEntity = NSEntityDescription()
        conversationEntity.name = "ConversationEntity"
        conversationEntity.managedObjectClassName = "ConversationEntity"

        let conversationId = NSAttributeDescription()
        conversationId.name = "conversationId"
        conversationId.attributeType = .UUIDAttributeType
        conversationId.isOptional = false

        let title = NSAttributeDescription()
        title.name = "title"
        title.attributeType = .stringAttributeType
        title.isOptional = false

        let createdAt = NSAttributeDescription()
        createdAt.name = "createdAt"
        createdAt.attributeType = .dateAttributeType
        createdAt.isOptional = false

        let updatedAt = NSAttributeDescription()
        updatedAt.name = "updatedAt"
        updatedAt.attributeType = .dateAttributeType
        updatedAt.isOptional = false

        let modelID = NSAttributeDescription()
        modelID.name = "modelID"
        modelID.attributeType = .stringAttributeType
        modelID.isOptional = true

        let providerID = NSAttributeDescription()
        providerID.name = "providerID"
        providerID.attributeType = .stringAttributeType
        providerID.isOptional = true

        conversationEntity.properties = [conversationId, title, createdAt, updatedAt, modelID, providerID]

        let messageEntity = NSEntityDescription()
        messageEntity.name = "MessageEntity"
        messageEntity.managedObjectClassName = "MessageEntity"

        let messageId = NSAttributeDescription()
        messageId.name = "messageId"
        messageId.attributeType = .UUIDAttributeType
        messageId.isOptional = false

        let msgConversationId = NSAttributeDescription()
        msgConversationId.name = "conversationId"
        msgConversationId.attributeType = .UUIDAttributeType
        msgConversationId.isOptional = false

        let timestamp = NSAttributeDescription()
        timestamp.name = "timestamp"
        timestamp.attributeType = .dateAttributeType
        timestamp.isOptional = false

        let role = NSAttributeDescription()
        role.name = "role"
        role.attributeType = .stringAttributeType
        role.isOptional = false

        let messageType = NSAttributeDescription()
        messageType.name = "messageType"
        messageType.attributeType = .stringAttributeType
        messageType.isOptional = false

        let status = NSAttributeDescription()
        status.name = "status"
        status.attributeType = .stringAttributeType
        status.isOptional = false

        let payloadJSON = NSAttributeDescription()
        payloadJSON.name = "payloadJSON"
        payloadJSON.attributeType = .transformableAttributeType
        payloadJSON.isOptional = true
        payloadJSON.valueTransformerName = NSValueTransformerName.secureUnarchiveFromDataTransformerName.rawValue

        messageEntity.properties = [messageId, msgConversationId, timestamp, role, messageType, status, payloadJSON]

        model.entities = [conversationEntity, messageEntity]

        let conversationIndex = NSFetchIndexDescription(
            name: "byConversationId",
            elements: [NSFetchIndexElementDescription(property: conversationId, collationType: .binary)]
        )
        conversationEntity.indexes = [conversationIndex]

        let msgConversationIndex = NSFetchIndexDescription(
            name: "byMessageConversationId",
            elements: [NSFetchIndexElementDescription(property: msgConversationId, collationType: .binary)]
        )
        let msgTimestampIndex = NSFetchIndexDescription(
            name: "byMessageTimestamp",
            elements: [NSFetchIndexElementDescription(property: timestamp, collationType: .binary)]
        )
        messageEntity.indexes = [msgConversationIndex, msgTimestampIndex]

        return model
    }

    func viewContext() async throws -> NSManagedObjectContext {
        let container = try await container()
        return container.viewContext
    }

    func newBackgroundContext() async throws -> NSManagedObjectContext {
        let container = try await container()
        return container.newBackgroundContext()
    }
}

@objc(ConversationEntity)
final class ConversationEntity: NSManagedObject {
    @NSManaged var conversationId: UUID
    @NSManaged var title: String
    @NSManaged var createdAt: Date
    @NSManaged var updatedAt: Date
    @NSManaged var modelID: String?
    @NSManaged var providerID: String?
}

@objc(MessageEntity)
final class MessageEntity: NSManagedObject {
    @NSManaged var messageId: UUID
    @NSManaged var conversationId: UUID
    @NSManaged var timestamp: Date
    @NSManaged var role: String
    @NSManaged var messageType: String
    @NSManaged var status: String
    @NSManaged var payloadJSON: Data?
}
