import ComposableArchitecture
import SwiftData
import SwiftUI

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \OnboardingProgress.createdAt, order: .forward) private var progressRecords: [OnboardingProgress]
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var store = Store(initialState: OnboardingFeature.State()) {
        OnboardingFeature()
    }

    private var resolvedColorScheme: ColorScheme? {
        switch appTheme {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    var body: some View {
        Group {
            if progressRecords.first?.isCompleted == true {
                HomeView()
            } else {
                OnboardingView(store: store, appTheme: $appTheme, onFinish: completeOnboarding)
            }
        }
        .preferredColorScheme(resolvedColorScheme)
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
