import ComposableArchitecture
import SwiftData
import SwiftUI

@main
struct OpenSpaceApp: App {
    private let sharedModelContainer = OpenSpaceModelContainer.shared

    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(initialState: AppCore.State()) {
                    AppCore()
                } withDependencies: {
                    $0.onboardingPersistence = .live(modelContainer: sharedModelContainer)
                    $0.chatPersistence = .live(modelContainer: sharedModelContainer)
                }
            )
        }
        .modelContainer(sharedModelContainer)
    }
}
