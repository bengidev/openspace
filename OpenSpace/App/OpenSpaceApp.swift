//
//  OpenSpaceApp.swift
//  OpenSpace
//
//  Created by Bambang Tri Rahmat Doni on 16/04/26.
//

import SwiftUI
import ComposableArchitecture

@main
struct OpenSpaceApp: App {
  init() {
    // Configure the global tint color for the entire app (UIKit only)
    #if os(iOS)
      let accent = UIColor(ThemeColor.accent)
      UIView.appearance().tintColor = accent
    #endif
  }

  var body: some Scene {
    WindowGroup {
      AppRootView()
        .openSpaceTheme()
    }
    #if os(macOS)
      .defaultSize(width: 1120, height: 620)
    #endif
  }
}
