import Foundation
import SwiftData

actor SwiftDataOnboardingRepository: OnboardingRepository {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func isOnboardingCompleted() async throws -> Bool {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<OnboardingProgressEntity>(sortBy: [SortDescriptor(\.createdAt)])
        let records = try context.fetch(descriptor)
        return records.first?.isCompleted ?? false
    }

    func completeOnboarding() async throws {
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
        progress.lastPageIndex = OnboardingPage.all.count - 1

        try context.save()
    }
}
