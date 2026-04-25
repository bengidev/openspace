//
//  OpenSpaceTests.swift
//  OpenSpaceTests
//
//  Created by Bambang Tri Rahmat Doni on 16/04/26.
//

import ComposableArchitecture
import Foundation
import Testing
@testable import OpenSpace

@MainActor
struct OpenSpaceTests {
    @Test
    func `models dev catalog decodes top level providers and ignores model metadata`() throws {
        let fixture = Data(#"""
            {
              "z-provider": {
                "npm": "@ai-sdk/openai-compatible",
                "api": "https://z.example/v1",
                "env": ["Z_API_KEY"],
                "name": "Zeta AI",
                "doc": "https://z.example/docs",
                "models": {
                  "ignored-model": { "name": "Ignored" }
                }
              },
              "alpha": {
                "id": "alpha-explicit",
                "npm": "@ai-sdk/alpha",
                "api": "https://alpha.example/v1",
                "env": ["ALPHA_API_KEY"],
                "name": "alpha Labs",
                "doc": "https://alpha.example/docs"
              }
            }
            """#.utf8)

        let providers = try AIProvider.decodeCatalog(from: fixture)

        #expect(providers == [
            AIProvider(
                id: "alpha-explicit",
                name: "alpha Labs",
                npm: "@ai-sdk/alpha",
                api: "https://alpha.example/v1",
                env: ["ALPHA_API_KEY"],
                doc: "https://alpha.example/docs"
            ),
            AIProvider(
                id: "z-provider",
                name: "Zeta AI",
                npm: "@ai-sdk/openai-compatible",
                api: "https://z.example/v1",
                env: ["Z_API_KEY"],
                doc: "https://z.example/docs"
            ),
        ])
    }

    @Test
    func `appeared fetches providers and keeps connection unselected`() async {
        let alpha = AIProvider(id: "alpha", name: "Alpha", npm: nil, api: nil, env: [], doc: nil)
        let zeta = AIProvider(id: "zeta", name: "zeta", npm: nil, api: nil, env: [], doc: nil)
        let store = TestStore(initialState: WorkspaceFeature.State()) {
            WorkspaceFeature()
        } withDependencies: {
            $0.apiClient.fetchProviders = { [zeta, alpha] }
        }

        await store.send(.appeared) {
            $0.hasAppeared = true
            $0.isLoadingProviders = true
        }
        await store.receive(\.providersResponse.success) {
            $0.isLoadingProviders = false
            $0.providers = [alpha, zeta]
        }
    }

    @Test
    func `provider response preserves existing connected provider`() async {
        let alpha = AIProvider(id: "alpha", name: "Alpha", npm: nil, api: nil, env: [], doc: nil)
        let store = TestStore(initialState: WorkspaceFeature.State(
            selectedProviderID: alpha.id,
            isLoadingProviders: true
        )) {
            WorkspaceFeature()
        }

        await store.send(.providersResponse(.success([alpha]))) {
            $0.isLoadingProviders = false
            $0.providers = [alpha]
        }
    }

    @Test
    func `provider response clears stale connected provider`() async {
        let alpha = AIProvider(id: "alpha", name: "Alpha", npm: nil, api: nil, env: [], doc: nil)
        let store = TestStore(initialState: WorkspaceFeature.State(
            selectedProviderID: "removed",
            isLoadingProviders: true
        )) {
            WorkspaceFeature()
        }

        await store.send(.providersResponse(.success([alpha]))) {
            $0.isLoadingProviders = false
            $0.providers = [alpha]
            $0.selectedProviderID = nil
        }
    }

    @Test
    func `provider selected updates selected provider id`() async {
        let store = TestStore(initialState: WorkspaceFeature.State(selectedProviderID: "alpha")) {
            WorkspaceFeature()
        }

        await store.send(.providerSelected("zeta")) {
            $0.selectedProviderID = "zeta"
        }
    }

    @Test
    func `provider fetch failure records error message`() async {
        struct FetchFailed: LocalizedError, Equatable {
            var errorDescription: String? { "Provider fetch failed." }
        }

        let store = TestStore(initialState: WorkspaceFeature.State()) {
            WorkspaceFeature()
        } withDependencies: {
            $0.apiClient.fetchProviders = { throw FetchFailed() }
        }

        await store.send(.fetchProviders) {
            $0.isLoadingProviders = true
            $0.providerErrorMessage = nil
        }
        await store.receive(\.providersResponse.failure) {
            $0.isLoadingProviders = false
            $0.providerErrorMessage = "Provider fetch failed."
        }
    }

    @Test
    func `prompt submitted without selected provider records validation error`() async {
        let store = TestStore(initialState: WorkspaceFeature.State(selectedPrompt: "Draft release notes")) {
            WorkspaceFeature()
        }

        await store.send(.promptSubmitted) {
            $0.errorMessage = "Select an AI provider before sending a prompt."
        }
    }

    @Test
    func `prompt submitted with provider fetch error surfaces catalog error`() async {
        let store = TestStore(initialState: WorkspaceFeature.State(
            selectedPrompt: "Draft release notes",
            providerErrorMessage: "Provider fetch failed."
        )) {
            WorkspaceFeature()
        }

        await store.send(.promptSubmitted) {
            $0.errorMessage = "Provider fetch failed."
        }
    }

    @Test
    func `prompt submitted sends selected provider to api client`() async {
        let provider = AIProvider(id: "alpha", name: "Alpha", npm: nil, api: nil, env: [], doc: nil)
        let expectedThread = WorkspaceThread(title: "Alpha response")
        var state = WorkspaceFeature.State()
        state.providers = [provider]
        state.selectedProviderID = provider.id
        state.selectedPrompt = "Draft release notes"
        let store = TestStore(initialState: state) {
            WorkspaceFeature()
        } withDependencies: {
            $0.apiClient.sendPrompt = { prompt, selectedProvider, style in
                #expect(prompt == "Draft release notes")
                #expect(selectedProvider == provider)
                #expect(style == .balanced)
                return expectedThread
            }
        }

        await store.send(.promptSubmitted) {
            $0.isLoading = true
        }
        await store.receive(\.sendPromptResponse.success) {
            $0.isLoading = false
            $0.threads.insert(expectedThread, at: 0)
            $0.selectedPrompt = ""
            $0.highlightedQuickPrompt = nil
        }
    }

    @Test
    func `prompt changed clears highlighted quick prompt when text diverges`() async {
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
    func `quick prompt tapped updates prompt and focus`() async {
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
