//
//  OpenSpaceApp.swift
//  OpenSpace
//
//  Created by Bambang Tri Rahmat Doni on 07/05/26.
//

import ComposableArchitecture
import SwiftData
import SwiftUI

@main
struct OpenSpaceApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            OnboardingProgressEntity.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(initialState: AppCore.State()) {
                    AppCore()
                } withDependencies: {
                    $0.onboardingPersistence = .live(modelContainer: sharedModelContainer)
                }
            )
        }
        .modelContainer(sharedModelContainer)
    }
}
