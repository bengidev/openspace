import ComposableArchitecture
import SwiftData
import SwiftUI

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \OnboardingProgress.createdAt, order: .forward) private var progressRecords: [OnboardingProgress]
    @State private var store = Store(initialState: OnboardingFeature.State()) {
        OnboardingFeature()
    }

    var body: some View {
        Group {
            if progressRecords.first?.isCompleted == true {
                ContentView()
            } else {
                OnboardingView(store: store, onFinish: completeOnboarding)
            }
        }
    }

    private func completeOnboarding() {
        let progress = progressRecords.first ?? OnboardingProgress()
        progress.isCompleted = true
        progress.completedAt = Date()
        progress.lastPageIndex = OnboardingPage.all.count - 1

        if progressRecords.first == nil {
            modelContext.insert(progress)
        }

        try? modelContext.save()
    }
}
