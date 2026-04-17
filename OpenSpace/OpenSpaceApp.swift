//
//  OpenSpaceApp.swift
//  OpenSpace
//
//  Created by Bambang Tri Rahmat Doni on 16/04/26.
//

import SwiftData
import SwiftUI

@main
struct OpenSpaceApp: App {
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      Item.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  init() {
    // Configure the global tint color for the entire app
    let accent = UIColor(ThemeColor.accent)
    UIView.appearance().tintColor = accent
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .openSpaceTheme()
    }
    .modelContainer(sharedModelContainer)
  }
}