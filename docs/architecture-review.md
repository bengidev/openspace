# OpenSpace Architecture Review — Clean Architecture + TCA

This document contains the refined architecture for the OpenSpace project, combining **Clean Architecture** (layer separation) with **TCA / swift-composable-architecture** (data flow discipline in the presentation layer).

---

## 1. Summary of Changes

| Aspect | Original Design | New Architecture |
|--------|----------------|------------------|
| Lifecycle | AppDelegate → SceneDelegate | `@main App` (SwiftUI native) |
| Presentation | ViewModel + @Observable | TCA Reducer + @ObservableState |
| Navigation root | Dashboard Feature | RootFeature (TCA Reducer) |
| State management | Scattered across ViewModels | Centralized per Feature State |
| DI pattern | Manual protocol-based | TCA `@DependencyClient` + Protocol |
| Domain layer | No separation | Domain Entities + UseCase Protocols |
| Data layer | SwiftData directly in View | Repository + DTO mapping |
| Shared/Utilities | Generic groups | Split into specific areas |

**Why it changed:**

- The original design used UIKit lifecycle patterns that don't fit a pure SwiftUI app
- Without TCA, SwiftUI state management tends to become spaghetti as the app grows (multi-tab, streaming, auth state)
- Without Clean Architecture, domain logic mixes with persistence and presentation
- TCA + Clean Architecture complement each other: TCA governs Presentation, Clean Architecture governs layer boundaries

---

## 2. Architecture Philosophy

### Clean Architecture — Three Layers

```
┌─────────────────────────────────────────┐
│         PRESENTATION LAYER (TCA)        │
│  Feature Reducers, Views, Actions       │
│  Depends on: Domain                     │
├─────────────────────────────────────────┤
│         DOMAIN LAYER (Pure)             │
│  Entities, UseCase Protocols            │
│  Depends on: nothing                    │
├─────────────────────────────────────────┤
│         DATA LAYER (Implementations)    │
│  Repositories, Networking, SwiftData    │
│  Depends on: Domain                     │
└─────────────────────────────────────────┘
```

**Dependency Rule:** Dependencies only point inward. Presentation → Domain ← Data. Domain knows nothing about TCA, SwiftData, or SwiftUI.

### TCA within the Presentation Layer

TCA governs data flow in the presentation layer:

```
User Action → Reducer → State mutation + Effect
                           ↓
                    Effect.run → UseCase → Repository
                           ↓
                    Response → State mutation
                           ↓
                    View re-renders
```

This replaces the ViewModel + @Observable pattern which lacks formal discipline. Every state change must go through an Action, every side effect must go through an Effect.

---

## 3. Folder Structure

```
OpenSpace/
├── App/
│   ├── OpenSpaceApp.swift          # @main entry point
│   └── RootFeature.swift           # TCA root reducer (compose sub-features)
│
├── Features/                       # PRESENTATION LAYER
│   ├── Auth/
│   │   ├── AuthFeature.swift       # @Reducer, State, Action
│   │   └── AuthView.swift
│   │
│   ├── Chat/
│   │   ├── ChatFeature.swift       # @Reducer, State, Action, Effect
│   │   ├── ChatListView.swift
│   │   ├── ChatDetailView.swift
│   │   └── Components/
│   │       ├── MessageBubble.swift
│   │       └── ChatInputBar.swift
│   │
│   ├── Search/
│   │   ├── SearchFeature.swift
│   │   └── SearchView.swift
│   │
│   ├── History/
│   │   ├── HistoryFeature.swift
│   │   └── HistoryView.swift
│   │
│   └── Profile/
│       ├── ProfileFeature.swift
│       └── ProfileView.swift
│
├── Domain/                         # DOMAIN LAYER (Pure)
│   ├── Entities/
│   │   ├── Conversation.swift      # Plain struct, no @Model
│   │   ├── Message.swift
│   │   ├── Provider.swift
│   │   └── User.swift
│   │
│   └── Protocols/
│       ├── ChatUseCaseProtocol.swift
│       ├── AuthUseCaseProtocol.swift
│       └── SearchUseCaseProtocol.swift
│
├── Data/                           # DATA LAYER
│   ├── Repositories/
│   │   ├── ChatRepository.swift    # Implements UseCase protocol
│   │   └── AuthRepository.swift
│   │
│   ├── Persistence/
│   │   ├── Models/                 # SwiftData @Model (DTO)
│   │   │   ├── ConversationDTO.swift
│   │   │   └── MessageDTO.swift
│   │   └── ModelContainer+Config.swift
│   │
│   ├── Networking/
│   │   ├── APIClient.swift
│   │   └── Providers/
│   │       ├── OpenAIProvider.swift
│   │       └── AnthropicProvider.swift
│   │
│   └── Security/
│       └── KeychainService.swift
│
├── Shared/                         # CROSS-CUTTING
│   ├── DesignSystem/
│   │   ├── Colors.swift
│   │   ├── Typography.swift
│   │   └── Components/
│   ├── Navigation/
│   │   └── AppRoute.swift
│   └── Extensions/
│       ├── View+Extensions.swift
│       ├── Date+Extensions.swift
│       └── String+Extensions.swift
│
└── Resources/
    ├── Assets.xcassets
    ├── Localizable.xcstrings
    └── Preview Content/
```

### Area Explanations

- **App/**: Entry point and root reducer. Only two files. RootFeature composes all sub-features.
- **Features/**: Presentation layer. Each feature is a TCA Feature (@Reducer) + SwiftUI View. One feature = one folder.
- **Domain/**: Domain layer. Contains only plain structs (Entity) and protocols (UseCase). No framework imports beyond Foundation.
- **Data/**: Data layer. Implements Domain protocols. Contains Repository, SwiftData DTO, Networking, and Security.
- **Shared/**: Cross-cutting concerns used across layers. DesignSystem is used by Views, Navigation by Reducers and Views, Extensions by all layers.
- **Resources/**: Assets and non-code files.

---

## 4. Presentation Layer — TCA

### 4.1 TCA Fundamentals in This Architecture

TCA replaces the traditional ViewModel pattern. Each feature is defined as a `@Reducer`:

```swift
// Features/Chat/ChatFeature.swift
import ComposableArchitecture
import Domain

@Reducer
struct ChatFeature {
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var conversations: [Conversation] = []
        var isLoading = false
        var searchText = ""
        @Presents var destination: Destination.State?
    }

    // MARK: - Action
    enum Action: BindableAction {
        case onAppear
        case searchTextChanged(String)
        case conversationsLoaded([Conversation])
        case destination(Destination.Action)
        case binding(BindingAction<State>)
    }

    // MARK: - Destination (Navigation)
    @Reducer(state: Equatable)
    enum Destination {
        case chatDetail(ChatDetailFeature)
    }

    // MARK: - Dependencies
    @Dependency(\.chatUseCase) var chatUseCase

    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    let conversations = try await chatUseCase.fetchConversations()
                    await send(.conversationsLoaded(conversations))
                }

            case let .searchTextChanged(text):
                state.searchText = text
                return .none

            case let .conversationsLoaded(conversations):
                state.conversations = conversations
                state.isLoading = false
                return .none

            case .destination:
                return .none

            case .binding:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
```

### 4.2 View with TCA Store

```swift
// Features/Chat/ChatListView.swift
import ComposableArchitecture
import SwiftUI

struct ChatListView: View {
    @Bindable var store: StoreOf<ChatFeature>

    var body: some View {
        List {
            ForEach(store.conversations) { conversation in
                NavigationLink {
                    if let detailStore = store.scope(
                        state: \.destination?.chatDetail,
                        action: \.destination.chatDetail
                    ) {
                        ChatDetailView(store: detailStore)
                    }
                } label: {
                    ConversationRow(conversation: conversation)
                }
            }
        }
        .searchable(
            text: $store.searchText,
            prompt: "Search conversations..."
        )
        .overlay {
            if store.isLoading {
                ProgressView()
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}
```

### 4.3 Dependency Injection via @DependencyClient

TCA uses `@DependencyClient` as a replacement for manual DI:

```swift
// Domain/Protocols/ChatUseCaseProtocol.swift
import ComposableArchitecture
import Foundation

@DependencyClient
struct ChatUseCase: Sendable {
    var fetchConversations: @Sendable () async throws -> [Conversation]
    var streamMessage: @Sendable (_ conversationId: UUID, _ content: String) -> AsyncThrowingStream<Message, Error>
    var deleteConversation: @Sendable (_ id: UUID) async throws -> Void
}
```

`@DependencyClient` automatically generates:
- A protocol that can be implemented by a Repository
- Test doubles with default values (return empty/nil)
- Registration into TCA DependencyValues

Registration in the Data layer:

```swift
// Data/Repositories/ChatRepository.swift
import ComposableArchitecture
import Domain
import SwiftData

struct ChatRepository: LiveDependencyKey {
    static let liveValue: ChatUseCase = ChatUseCase(
        fetchConversations: {
            // SwiftData fetch → map DTO → return Entity
            // ...
        },
        streamMessage: { conversationId, content in
            // API call → AsyncThrowingStream
            // ...
        },
        deleteConversation: { id in
            // SwiftData delete
            // ...
        }
    )

    static let testValue: ChatUseCase = ChatUseCase(
        fetchConversations: { [] },
        streamMessage: { _, _ in AsyncThrowingStream { $0.finish() } },
        deleteConversation: { _ in }
    )
}

extension DependencyValues {
    var chatUseCase: ChatUseCase {
        get { self[ChatRepository.self] }
        set { self[ChatRepository.self] = newValue }
    }
}
```

### 4.4 Streaming Chat with Effect.run

```swift
// Inside ChatFeature Reducer
case let .sendMessage(text):
    state.isStreaming = true
    return .run { [conversationId = state.currentConversationId] send in
        let stream = chatUseCase.streamMessage(conversationId, text)
        do {
            for try await chunk in stream {
                await send(.chunkReceived(chunk))
            }
            await send(.streamFinished)
        } catch {
            await send(.streamError(error))
        }
    }
```

### 4.5 Reducer Composition (RootFeature)

```swift
// App/RootFeature.swift
import ComposableArchitecture

@Reducer
struct RootFeature {
    @ObservableState
    struct State: Equatable {
        var auth = AuthFeature.State()
        var home: HomeFeature.State?
        var route: Route = .auth

        enum Route {
            case auth
            case onboarding
            case home
        }
    }

    enum Action {
        case auth(AuthFeature.Action)
        case home(HomeFeature.Action)
        case routeChanged(Route)
    }

    @Dependency(\.authUseCase) var authUseCase

    var body: some ReducerOf<Self> {
        Scope(state: \.auth, action: \.auth) {
            AuthFeature()
        }
        Reduce { state, action in
            switch action {
            case .auth(.loginSucceeded):
                state.route = .home
                state.home = HomeFeature.State()
                return .none

            case .auth(.onboardingRequired):
                state.route = .onboarding
                return .none

            case .home:
                return .none

            case .routeChanged:
                return .none
            }
        }
        .ifLet(\.home, action: \.home) {
            HomeFeature()
        }
    }
}
```

### 4.6 HomeFeature with TabView

```swift
// Features/Home/HomeFeature.swift
import ComposableArchitecture

@Reducer
struct HomeFeature {
    @ObservableState
    struct State: Equatable {
        var chat = ChatFeature.State()
        var search = SearchFeature.State()
        var history = HistoryFeature.State()
        var profile = ProfileFeature.State()
        var selectedTab: Tab = .chat

        enum Tab: Equatable {
            case chat, search, history, profile
        }
    }

    enum Action {
        case chat(ChatFeature.Action)
        case search(SearchFeature.Action)
        case history(HistoryFeature.Action)
        case profile(ProfileFeature.Action)
        case tabSelected(State.Tab)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.chat, action: \.chat) { ChatFeature() }
        Scope(state: \.search, action: \.search) { SearchFeature() }
        Scope(state: \.history, action: \.history) { HistoryFeature() }
        Scope(state: \.profile, action: \.profile) { ProfileFeature() }
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
            default:
                return .none
            }
        }
    }
}
```

```swift
// Features/Home/HomeView.swift
import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>

    var body: some View {
        TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
            Tab("Chat", systemImage: "bubble.left.fill", value: .chat) {
                NavigationStack {
                    ChatListView(store: store.scope(state: \.chat, action: \.chat))
                }
            }
            Tab("Search", systemImage: "magnifyingglass", value: .search) {
                NavigationStack {
                    SearchView(store: store.scope(state: \.search, action: \.search))
                }
            }
            Tab("History", systemImage: "clock.fill", value: .history) {
                NavigationStack {
                    HistoryView(store: store.scope(state: \.history, action: \.history))
                }
            }
            Tab("Profile", systemImage: "person.fill", value: .profile) {
                NavigationStack {
                    ProfileView(store: store.scope(state: \.profile, action: \.profile))
                }
            }
        }
    }
}
```

---

## 5. Domain Layer

### 5.1 Principles

The Domain layer contains **pure business logic**. No SwiftUI import, no SwiftData import, no TCA import. Only Foundation.

This ensures:
- Domain can be tested without UI or database setup
- Domain doesn't change if you swap persistence layers
- Domain doesn't change if you swap presentation frameworks

### 5.2 Entity (Plain Struct)

```swift
// Domain/Entities/Conversation.swift
import Foundation

struct Conversation: Equatable, Identifiable, Sendable {
    let id: UUID
    var title: String
    var provider: Provider
    var messages: [Message]
    var createdAt: Date
    var updatedAt: Date
}

// Domain/Entities/Message.swift
import Foundation

struct Message: Equatable, Identifiable, Sendable {
    let id: UUID
    var role: Role
    var content: String
    var createdAt: Date

    enum Role: String, Equatable, Sendable {
        case user
        case assistant
        case system
    }
}

// Domain/Entities/Provider.swift
import Foundation

struct Provider: Equatable, Identifiable, Sendable {
    let id: UUID
    var name: String
    var type: ProviderType
    var apiKeyRef: String // Reference to Keychain, not the actual API key

    enum ProviderType: String, Equatable, Sendable {
        case openAI
        case anthropic
        case google
    }
}
```

### 5.3 Why Entity Is Separate from SwiftData @Model

SwiftData `@Model` carries implications:
- Coupling to a persistence framework
- `@Query` and `ModelContext` bring side effects into views
- Difficult to test in isolation
- Schema migration tied to runtime

By separating Entity (plain struct) from DTO (@Model):
- Domain stays clean and testable
- SwiftData stays in the Data layer only
- Mapping is explicit, no "magic"
- If you switch persistence tomorrow, Domain is untouched

---

## 6. Data Layer

### 6.1 DTO (SwiftData Model)

DTOs are persistence representations. They differ from Entities — this separation is **intentional**:

```swift
// Data/Persistence/Models/ConversationDTO.swift
import Foundation
import SwiftData

@Model
final class ConversationDTO {
    @Attribute(.unique) var id: UUID
    var title: String
    var providerType: String
    var providerId: UUID
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \MessageDTO.conversation)
    var messages: [MessageDTO] = []

    init(
        id: UUID = UUID(),
        title: String,
        providerType: String,
        providerId: UUID,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.providerType = providerType
        self.providerId = providerId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - DTO → Entity Mapping
extension ConversationDTO {
    func toEntity() -> Conversation {
        Conversation(
            id: id,
            title: title,
            provider: Provider(
                id: providerId,
                name: providerType,
                type: .init(rawValue: providerType) ?? .openAI,
                apiKeyRef: "provider_\(providerId.uuidString)"
            ),
            messages: messages.map { $0.toEntity() },
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
```

```swift
// Data/Persistence/Models/MessageDTO.swift
import Foundation
import SwiftData

@Model
final class MessageDTO {
    @Attribute(.unique) var id: UUID
    var role: String
    var content: String
    var createdAt: Date
    var conversation: ConversationDTO?

    init(
        id: UUID = UUID(),
        role: String,
        content: String,
        createdAt: Date = .now,
        conversation: ConversationDTO? = nil
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.createdAt = createdAt
        self.conversation = conversation
    }
}

extension MessageDTO {
    func toEntity() -> Message {
        Message(
            id: id,
            role: .init(rawValue: role) ?? .user,
            content: content,
            createdAt: createdAt
        )
    }
}
```

### 6.2 Repository Implementation

The Repository implements the UseCase protocol and manages DTO ↔ Entity mapping:

```swift
// Data/Repositories/ChatRepository.swift
import ComposableArchitecture
import Domain
import SwiftData

struct ChatRepository: LiveDependencyKey {
    static let liveValue: ChatUseCase = ChatUseCase(
        fetchConversations: {
            let context = ModelContext.shared
            let descriptor = FetchDescriptor<ConversationDTO>(
                sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
            )
            let dtos = try context.fetch(descriptor)
            return dtos.map { $0.toEntity() }
        },
        streamMessage: { conversationId, content in
            // Delegate to Networking/Providers
            AsyncThrowingStream { continuation in
                Task {
                    let provider = resolveProvider(for: conversationId)
                    let stream = provider.stream(content: content)
                    for try await chunk in stream {
                        continuation.yield(chunk.toEntity())
                    }
                    continuation.finish()
                }
            }
        },
        deleteConversation: { id in
            let context = ModelContext.shared
            let descriptor = FetchDescriptor<ConversationDTO>(
                predicate: #Predicate { $0.id == id }
            )
            if let dto = try context.fetch(descriptor).first {
                context.delete(dto)
                try context.save()
            }
        }
    )

    static let testValue: ChatUseCase = ChatUseCase(
        fetchConversations: { [] },
        streamMessage: { _, _ in AsyncThrowingStream { $0.finish() } },
        deleteConversation: { _ in }
    )
}

extension DependencyValues {
    var chatUseCase: ChatUseCase {
        get { self[ChatRepository.self] }
        set { self[ChatRepository.self] = newValue }
    }
}
```

### 6.3 ModelContainer Configuration

```swift
// Data/Persistence/ModelContainer+Config.swift
import SwiftData

extension ModelContainer {
    static let shared: ModelContainer = {
        let schema = Schema([
            ConversationDTO.self,
            MessageDTO.self,
        ])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
}
```

---

## 7. Data Flow

### 7.1 Flow Diagram

```
 1. User taps "Send" in ChatInputBar
         ↓
 2. View sends Action .sendMessage(text)
         ↓
 3. Reducer receives Action
    → State: isStreaming = true
    → Return: Effect.run
         ↓
 4. Effect.run calls chatUseCase.streamMessage(id, text)
         ↓
 5. UseCase calls ChatRepository.streamMessage()
         ↓
 6. Repository calls Networking Provider (OpenAI/Anthropic)
         ↓
 7. Provider sends HTTP request, receives SSE stream
         ↓
 8. Provider converts SSE chunk → Message Entity
         ↓
 9. AsyncThrowingStream yields Message Entity to Effect
         ↓
10. Effect sends Action .chunkReceived(message)
         ↓
11. Reducer updates State: messages.append(message)
         ↓
12. View re-renders with new message
```

### 7.2 End-to-End Code Example

```swift
// Step 1-2: View
Button("Send") {
    store.send(.sendMessage(inputText))
}

// Step 3-4: Reducer
case let .sendMessage(text):
    state.isStreaming = true
    return .run { [id = state.currentId] send in
        let stream = chatUseCase.streamMessage(id, text)  // Step 5
        do {
            for try await chunk in stream {                // Step 9
                await send(.chunkReceived(chunk))          // Step 10
            }
            await send(.streamFinished)
        } catch {
            await send(.streamError(error))
        }
    }

// Step 5-6: Repository → Provider
streamMessage: { conversationId, content in
    AsyncThrowingStream { continuation in
        Task {
            let provider = OpenAIProvider(apiKey: keychain.get(...))
            let stream = provider.stream(chatRequest: ...)   // Step 6-7
            for try await chunk in stream {                   // Step 8
                continuation.yield(chunk.toEntity())
            }
            continuation.finish()
        }
    }
}

// Step 11: Reducer
case let .chunkReceived(message):
    state.messages.append(message)
    return .none

// Step 12: View auto-re-renders due to @ObservableState
```

---

## 8. Navigation

### 8.1 Root Navigation (Auth State Switching)

```swift
// App/OpenSpaceApp.swift
import ComposableArchitecture
import SwiftUI

@main
struct OpenSpaceApp: App {
    let store = Store(initialState: RootFeature.State()) {
        RootFeature()
    }

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
        }
        .modelContainer(.shared)
    }
}
```

```swift
// App/RootView.swift
import ComposableArchitecture
import SwiftUI

struct RootView: View {
    @Bindable var store: StoreOf<RootFeature>

    var body: some View {
        switch store.route {
        case .auth, .onboarding:
            AuthView(store: store.scope(state: \.auth, action: \.auth))

        case .home:
            if let homeStore = store.scope(state: \.home, action: \.home) {
                HomeView(store: homeStore)
            }
        }
    }
}
```

### 8.2 Tab Navigation (Home)

Each tab has its own `NavigationStack`. TCA `Scope` ensures state per tab is isolated:

```swift
TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
    Tab("Chat", systemImage: "bubble.left.fill", value: .chat) {
        NavigationStack {
            ChatListView(store: store.scope(state: \.chat, action: \.chat))
                .navigationDestination(item: $store.scope(
                    state: \.chat.destination?.chatDetail,
                    action: \.chat.destination.chatDetail
                )) { detailStore in
                    ChatDetailView(store: detailStore)
                }
        }
    }
    // ... other tabs follow the same pattern
}
```

### 8.3 Push Navigation within a Tab

Push navigation uses TCA `@Presents` + `navigationDestination`:

```swift
// In ChatFeature
@Presents var destination: Destination.State?

@Reducer(state: Equatable)
enum Destination {
    case chatDetail(ChatDetailFeature)
}

// In View
.navigationDestination(item: $store.scope(
    state: \.destination?.chatDetail,
    action: \.destination.chatDetail
)) { detailStore in
    ChatDetailView(store: detailStore)
}
```

---

## 9. Swift Concurrency

### 9.1 Per-Layer Guidelines

| Layer | Actor Strategy | Example |
|-------|---------------|---------|
| Presentation (TCA) | `@MainActor` implicit on Reducer | `Effect.run` is already isolated |
| Domain | `Sendable` on Entities and UseCases | All Entities conform to `Sendable` |
| Data — Repository | `actor` for concurrent operations | `actor PersistenceStack` |
| Data — Networking | `async/await` entirely | Avoid completion handlers |
| Streaming | `AsyncThrowingStream` | Provider → Repository → Effect |

### 9.2 Actor for Persistence

```swift
// Data/Persistence/PersistenceStack.swift
actor PersistenceStack {
    private let modelContainer: ModelContainer
    private var modelContext: ModelContext

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
    }

    func fetch<T: PersistentModel>(
        _ descriptor: FetchDescriptor<T>
    ) throws -> [T] {
        try modelContext.fetch(descriptor)
    }

    func insert<T: PersistentModel>(_ model: T) throws {
        modelContext.insert(model)
        try modelContext.save()
    }

    func delete<T: PersistentModel>(_ model: T) throws {
        modelContext.delete(model)
        try modelContext.save()
    }
}
```

---

## 10. Testing Strategy

### 10.1 TCA Reducer Tests (TestStore)

```swift
// Tests/Features/ChatFeatureTests.swift
import ComposableArchitecture
import Testing

@MainActor
struct ChatFeatureTests {
    @Test
    func onAppearLoadsConversations() async {
        let store = TestStore(
            initialState: ChatFeature.State()
        ) {
            ChatFeature()
        } withDependencies: {
            $0.chatUseCase.fetchConversations = {
                [Conversation(id: UUID(), title: "Test", ...)]
            }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }

        await store.receive(.conversationsLoaded([...])) {
            $0.conversations = [...]
            $0.isLoading = false
        }
    }
}
```

### 10.2 UseCase / Repository Tests

```swift
// Tests/Data/ChatRepositoryTests.swift
import Testing
import SwiftData

struct ChatRepositoryTests {
    @Test
    func fetchConversationsReturnsEntities() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: ConversationDTO.self, MessageDTO.self,
            configurations: config
        )
        let context = container.mainContext

        // Insert test data
        let dto = ConversationDTO(title: "Test", providerType: "openAI", providerId: UUID())
        context.insert(dto)
        try context.save()

        // Test repository
        let repo = ChatRepository()
        let conversations = try await repo.liveValue.fetchConversations()
        #expect(conversations.count == 1)
        #expect(conversations.first?.title == "Test")
    }
}
```

### 10.3 Testing Hierarchy

| Level | What Is Tested | Tool |
|-------|---------------|------|
| Reducer | State transitions, Effect output | `TestStore` (TCA) |
| UseCase | Business logic, data transformation | Swift Testing |
| Repository | DTO ↔ Entity mapping, CRUD | Swift Testing + in-memory SwiftData |
| View | Snapshot, layout, accessibility | Xcode Preview + snapshot testing |
| Integration | End-to-end flow | XCUITest |

---

## 11. Phased Implementation

### Phase 1 — Setup TCA + Chat Feature (Reference Implementation)

- [ ] Add swift-composable-architecture dependency to project
- [ ] Create base folder structure (App, Features, Domain, Data, Shared)
- [ ] Create Domain/Entities/ (Conversation, Message, Provider)
- [ ] Create Domain/Protocols/ChatUseCaseProtocol.swift (@DependencyClient)
- [ ] Implement ChatFeature.swift (@Reducer + State + Action)
- [ ] Implement ChatListView.swift and ChatDetailView.swift
- [ ] Implement ChatRepository.swift (with in-memory data initially)
- [ ] Wire everything end-to-end
- [ ] Write TestStore test for ChatFeature

**Goal:** One complete feature that serves as the template for all other features.

### Phase 2 — Auth + RootFeature Navigation

- [ ] Create AuthFeature.swift (@Reducer)
- [ ] Create RootFeature.swift (compose Auth + Home)
- [ ] Create RootView.swift (switch based on route)
- [ ] Implement KeychainService.swift
- [ ] Create AuthRepository.swift
- [ ] Navigation between auth and home working

### Phase 3 — Replicate to Other Features

- [ ] Copy Chat pattern to SearchFeature
- [ ] Copy Chat pattern to HistoryFeature
- [ ] Copy Chat pattern to ProfileFeature
- [ ] Implement HomeFeature (TabView composition)
- [ ] Implement HomeView (4 tabs + NavigationStack per tab)

### Phase 4 — Networking + AI Provider Layer

- [ ] Create APIClient.swift (generic HTTP client)
- [ ] Implement ProviderProtocol (abstraction)
- [ ] Implement OpenAIProvider.swift (streaming)
- [ ] Implement AnthropicProvider.swift (streaming)
- [ ] Connect Provider to Repository
- [ ] Test streaming end-to-end

### Phase 5 — Persistence (SwiftData) + DTO Mapping

- [ ] Create ConversationDTO.swift and MessageDTO.swift
- [ ] Implement DTO → Entity mapping
- [ ] Implement ModelContainer+Config.swift
- [ ] Update Repository to use SwiftData
- [ ] Implement PersistenceStack (actor)
- [ ] Test CRUD operations

### Phase 6 — Testing & Polish

- [ ] Reducer tests for every Feature
- [ ] Repository tests for every Repository
- [ ] DTO mapping tests
- [ ] DesignSystem snapshot tests
- [ ] UI tests for main navigation flows
- [ ] Performance profiling

---

## 12. Original Design vs Recommendation

| Aspect | Original Design | New Architecture |
|--------|----------------|------------------|
| Lifecycle | AppDelegate → SceneDelegate | `@main App` (SwiftUI) |
| Presentation pattern | ViewModel + @Observable | TCA @Reducer + @ObservableState |
| State management | Scattered per ViewModel | Centralized per Feature State |
| DI pattern | Manual protocol-based | TCA @DependencyClient |
| Navigation root | Dashboard Feature | RootFeature (TCA composition) |
| Navigation tabs | TabBar (UIKit concept) | TabView + NavigationStack per tab |
| Domain separation | None | Domain/ separated (Entities + UseCase Protocols) |
| Data layer | SwiftData directly in View | Repository + DTO → Entity mapping |
| Shared/Utilities | Generic groups | Split into specific areas |
| Concurrency | Not specified | async/await + AsyncThrowingStream + actor |
| Testing | Separate Test module | TCA TestStore + Repository tests + UI tests |
| Streaming | Not planned | AsyncThrowingStream via TCA Effect.run |
| Entity design | @Model as domain model | Plain struct (Entity) separate from @Model (DTO) |

---

This architecture respects the spirit of the original design (feature-based, modular) while adding:
1. **Formal discipline** in state management (TCA)
2. **Clear boundaries** between layers (Clean Architecture)
3. **Structured testability** from day one
4. **Scalability** that opens the path to a multi-provider AI workspace
