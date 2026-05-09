import ComposableArchitecture
import Foundation

extension DependencyValues {
    var onboardingRepository: OnboardingRepository {
        get { self[OnboardingRepositoryKey.self] }
        set { self[OnboardingRepositoryKey.self] = newValue }
    }
}

private enum OnboardingRepositoryKey: DependencyKey {
    static let liveValue: OnboardingRepository = UnimplementedOnboardingRepository()
    static let testValue: OnboardingRepository = MockOnboardingRepository()
    static let previewValue: OnboardingRepository = MockOnboardingRepository()
}

struct UnimplementedOnboardingRepository: OnboardingRepository {
    func isOnboardingCompleted() async throws -> Bool {
        fatalError("OnboardingRepository must be injected via withDependencies")
    }

    func completeOnboarding() async throws {
        fatalError("OnboardingRepository must be injected via withDependencies")
    }
}

struct MockOnboardingRepository: OnboardingRepository {
    var completed = false

    func isOnboardingCompleted() async throws -> Bool {
        completed
    }

    func completeOnboarding() async throws {
        // no-op
    }
}
