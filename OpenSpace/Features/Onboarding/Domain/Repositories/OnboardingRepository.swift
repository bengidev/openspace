import Foundation

protocol OnboardingRepository {
    func isOnboardingCompleted() async throws -> Bool
    func completeOnboarding() async throws
}
