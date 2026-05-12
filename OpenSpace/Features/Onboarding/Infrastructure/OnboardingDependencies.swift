import ComposableArchitecture
import Foundation
import SwiftData

struct OnboardingPersistenceClient {
    var isCompleted: @Sendable () async throws -> Bool
    var complete: @Sendable () async throws -> Void
}

extension OnboardingPersistenceClient {
    static func live(modelContainer: ModelContainer) -> Self {
        Self(
            isCompleted: {
                let context = ModelContext(modelContainer)
                let descriptor = FetchDescriptor<OnboardingProgressEntity>(sortBy: [SortDescriptor(\.createdAt)])
                let records = try context.fetch(descriptor)
                return records.first?.isCompleted ?? false
            },
            complete: {
                let context = ModelContext(modelContainer)
                let descriptor = FetchDescriptor<OnboardingProgressEntity>(sortBy: [SortDescriptor(\.createdAt)])
                let records = try context.fetch(descriptor)

                let progress: OnboardingProgressEntity
                if let first = records.first {
                    progress = first
                } else {
                    progress = OnboardingProgressEntity()
                    context.insert(progress)
                }

                progress.isCompleted = true
                progress.completedAt = Date()
                progress.lastPageIndex = OnboardingPageModel.all.count - 1

                try context.save()
            }
        )
    }
}

extension OnboardingPersistenceClient: DependencyKey {
    static let liveValue = Self(
        isCompleted: {
            fatalError("OnboardingPersistenceClient must be injected via withDependencies")
        },
        complete: {
            fatalError("OnboardingPersistenceClient must be injected via withDependencies")
        }
    )

    static let testValue = Self(
        isCompleted: { false },
        complete: {}
    )

    static let previewValue = testValue
}

extension DependencyValues {
    var onboardingPersistence: OnboardingPersistenceClient {
        get { self[OnboardingPersistenceClient.self] }
        set { self[OnboardingPersistenceClient.self] = newValue }
    }
}
