//
//  OpenSpaceTests.swift
//  OpenSpaceTests
//
//  Created by Bambang Tri Rahmat Doni on 16/04/26.
//

import ComposableArchitecture
import Testing
@testable import OpenSpace

struct OpenSpaceTests {
  @Test
  func promptChangedClearsHighlightedQuickPromptWhenTextDiverges() async {
    let store = TestStore(initialState: WorkspaceFeature.State(
      selectedPrompt: WorkspaceQuickPrompt.toDoList.rawValue,
      highlightedQuickPrompt: .toDoList
    )) {
      WorkspaceFeature()
    }

    await store.send(.promptChanged("Draft a release summary")) {
      $0.selectedPrompt = "Draft a release summary"
      $0.highlightedQuickPrompt = nil
    }
  }

  @Test
  func quickPromptTappedUpdatesPromptAndFocus() async {
    let store = TestStore(initialState: WorkspaceFeature.State()) {
      WorkspaceFeature()
    }

    await store.send(.quickPromptTapped(.articleSummary)) {
      $0.highlightedQuickPrompt = .articleSummary
      $0.selectedPrompt = WorkspaceQuickPrompt.articleSummary.rawValue
      $0.isPromptFocused = true
    }
  }
}
