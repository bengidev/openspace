# OpenSpace TCA Migration Analysis

> Date: 2026-04-23
> Context: TCA (ComposableArchitecture) akan digunakan untuk integrasi API dengan pendekatan declarative
> Reference: https://refactoring.guru/refactoring/smells + TCA best practices

---

## Executive Summary

TCA adalah **dependency yang direncanakan aktif**, bukan dead code. Namun struktur kode saat ini **tidak siap** untuk adopsi TCA. Duplikasi platform (3,915 baris) dan God Object state (`WorkspaceModels.swift`) akan menjadi **masalah lebih besar** saat TCA diintegrasikan karena:

1. TCA menggunakan **single source of truth** (Store) - duplikasi 3x view code berarti 3x maintenance terhadap interaksi yang sama
2. TCA State harus **serializable dan testable** - enum dengan 150+ baris string marketing tidak bisa masuk ke State
3. TCA Reducer memerlukan **Action yang terdefinisi dengan jelas** - `@State` manual saat ini tidak memiliki action boundary

---

## TCA Architecture Mapping

### Target Architecture (Post-TCA)

```
AppFeature (Reducer)
  -> AppView
       -> OnboardingFeature (Reducer)
            -> OnboardingView (StoreOf<OnboardingFeature>)
                 -> Platform-specific layout (thin wrappers)
       -> WorkspaceFeature (Reducer)
            -> WorkspaceView (StoreOf<WorkspaceFeature>)
                 -> Platform-specific layout (thin wrappers)
```

### Per-Feature Structure

```swift
// MARK: - Feature State
@Reducer
struct WorkspaceFeature {
  @ObservableState
  struct State: Equatable {
    var selectedDestination: WorkspaceDestination = .home
    var selectedModel: WorkspaceModel = .chatGPT4o
    var selectedPrompt: String = ""
    var selectedWritingStyle: WorkspaceWritingStyle = .balanced
    var citationEnabled: Bool = true
    var highlightedQuickPrompt: QuickPrompt?
    var isPromptFocused: Bool = false
    var hasAppeared: Bool = false
    
    // API integration
    var isLoading: Bool = false
    var threads: [Thread] = []
    var errorMessage: String?
  }
  
  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case destinationSelected(WorkspaceDestination)
    case promptSubmitted(String)
    case quickPromptTapped(QuickPrompt)
    case modelSelected(WorkspaceModel)
    case writingStyleSelected(WorkspaceWritingStyle)
    case citationToggled(Bool)
    case sendButtonTapped
    
    // API Actions
    case fetchThreads
    case threadsResponse(Result<[Thread], Error>)
    case dismissError
  }
  
  @Dependency(\.apiClient) var apiClient
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case let .destinationSelected(destination):
        state.selectedDestination = destination
        return .send(.fetchThreads)
        
      case let .promptSubmitted(prompt):
        state.selectedPrompt = prompt
        state.isLoading = true
        return .run { [model = state.selectedModel] send in
          await send(.threadsResponse(Result {
            try await apiClient.sendPrompt(prompt, model: model)
          }))
        }
        
      case let .threadsResponse(.success(threads)):
        state.isLoading = false
        state.threads = threads
        return .none
        
      case let .threadsResponse(.failure(error)):
        state.isLoading = false
        state.errorMessage = error.localizedDescription
        return .none
        
      // ... other actions
      }
    }
  }
}
```

---

## Smell Analysis: TCA Context

### 1. DUPLICATE CODE (Critical - Worsened by TCA)

**Current**: 3,915 lines of platform-specific views
**TCA Impact**: Jika tidak diperbaiki, setiap feature TCA akan memiliki 3x view code yang harus mengikat ke Store yang sama.

**Fix for TCA**: Extract unified `WorkspaceContentView` yang menerima `StoreOf<WorkspaceFeature>` + `WorkspaceLayoutProfile`. Platform views menjadi thin wrappers (< 50 baris masing-masing).

```swift
// Unified - works with TCA Store
struct WorkspaceContentView: View {
  let store: StoreOf<WorkspaceFeature>
  let profile: WorkspaceLayoutProfile
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: profile.mainSectionSpacing) {
        UtilityBar(store: store, profile: profile)
        HeroSection(store: store, profile: profile)
        ComposerCard(store: store, profile: profile)
      }
    }
  }
}

// Platform wrapper - 15 lines max
struct WorkspaceIOSView: View {
  let store: StoreOf<WorkspaceFeature>
  
  var body: some View {
    GeometryReader { proxy in
      WorkspaceContentView(
        store: store,
        profile: IOSLayoutProfile(containerSize: proxy.size)
      )
    }
  }
}
```

---

### 2. LARGE CLASS / GOD OBJECT (Critical for TCA)

**Current**: `WorkspaceModels.swift` menggabungkan 7 konsep
**TCA Impact**: TCA State harus Equatable dan terpisah per-feature. God Object akan membuat Reducer menjadi monolith yang tidak bisa di-test.

**Fix for TCA**: Split menjadi domain yang jelas:

```
WorkspaceDestination.swift     // Navigation identity (masuk State)
WorkspaceContentCatalog.swift  // Marketing copy (TIDAK masuk State - static)
QuickPrompt.swift              // Data struct (masuk State)
WorkspaceModel.swift           // AI model config (masuk State)
WorkspaceWritingStyle.swift    // Enum (masuk State)
```

---

### 3. DATA CLUMPS (Critical for TCA)

**Current**: `WorkspaceViewBindings` aggregation
**TCA Impact**: TCA tidak memerlukan binding aggregation karena Store menyediakan binding otomatis via `BindingAction` + `viewStore.bindings`.

**Fix for TCA**: Hapus `WorkspaceViewBindings`. Ganti dengan `StoreOf<WorkspaceFeature>` yang memiliki `BindingReducer()`.

---

### 4. SWITCH STATEMENTS (Medium for TCA)

**Current**: `WorkspaceRenderContext` switch-on-variant
**TCA Impact**: Layout configuration sebaiknya di-extract dari Reducer. State TCA tidak boleh menyimpan layout constants.

**Fix for TCA**: `WorkspaceLayoutProfile` tetap sebagai protocol, dipilih di View layer (bukan di Reducer).

```swift
// State TIDAK menyimpan layout
struct State: Equatable {
  // Hanya business state
}

// View memilih profile
var body: some View {
  WithViewStore(store, observe: { $0 }) { viewStore in
    let profile = currentPlatformProfile()
    WorkspaceContentView(store: store, profile: profile)
  }
}
```

---

### 5. FEATURE ENVY (Medium for TCA)

**Current**: `WorkspaceDestination` berisi content strings
**TCA Impact**: Strings marketing tidak boleh di Reducer. Reducer harus fokus pada business logic.

**Fix for TCA**: `WorkspaceContentCatalog` sebagai static dependency, bisa di-inject via TCA DependencyValues.

```swift
extension DependencyValues {
  var contentCatalog: WorkspaceContentCatalog {
    get { self[ContentCatalogKey.self] }
    set { self[ContentCatalogKey.self] = newValue }
  }
}

private enum ContentCatalogKey: DependencyKey {
  static let liveValue = WorkspaceContentCatalog.live
}
```

---

## Recommended Migration Path to TCA

### Phase 0: Pre-TCA Refactoring (Week 1)

**Goal**: Bersihkan struktur agar siap menerima TCA tanpa tech debt.

1. **Extract Unified Components**
   - Buat `WorkspaceContentView` unified (ganti 3 platform content views)
   - Buat `OnboardingContentView` unified
   - Platform views menjadi thin wrappers

2. **Extract Content Catalog**
   - Pindahkan semua marketing copy dari `WorkspaceDestination`
   - Buat `WorkspaceContentCatalog` static struct

3. **Extract Layout Profile**
   - Ganti `WorkspaceRenderContext` switch-heavy dengan `WorkspaceLayoutProfile` protocol

4. **Split God Object**
   - `WorkspaceModels.swift` -> 4-5 file terpisah

### Phase 1: TCA Foundation (Week 2)

1. **Define Features**
   ```swift
   @Reducer
   struct WorkspaceFeature { ... }
   
   @Reducer
   struct OnboardingFeature { ... }
   
   @Reducer
   struct AppFeature {
     @ObservableState
     struct State: Equatable {
       var onboarding = OnboardingFeature.State()
       var workspace = WorkspaceFeature.State()
       var hasCompletedOnboarding: Bool = false
     }
     
     enum Action {
       case onboarding(OnboardingFeature.Action)
       case workspace(WorkspaceFeature.Action)
       case onboardingCompleted
     }
     
     var body: some ReducerOf<Self> {
       Scope(state: \.onboarding, action: \.onboarding) {
         OnboardingFeature()
       }
       Scope(state: \.workspace, action: \.workspace) {
         WorkspaceFeature()
       }
       Reduce { state, action in
         switch action {
         case .onboarding(.continueButtonTapped):
           state.hasCompletedOnboarding = true
           return .none
         default:
           return .none
         }
       }
     }
   }
   ```

2. **Wire up Store in App**
   ```swift
   @main
   struct OpenSpaceApp: App {
     let store = Store(initialState: AppFeature.State()) {
       AppFeature()
     }
     
     var body: some Scene {
       WindowGroup {
         AppView(store: store)
       }
     }
   }
   ```

### Phase 2: API Integration (Week 3)

1. **Define API Client Dependency**
   ```swift
   struct APIClient {
     var sendPrompt: (String, WorkspaceModel) async throws -> [Thread]
     var fetchThreads: () async throws -> [Thread]
     var deleteThread: (UUID) async throws -> Void
   }
   
   extension APIClient: DependencyKey {
     static let liveValue = APIClient(
       sendPrompt: { prompt, model in
         // Live implementation
       },
       fetchThreads: {
         // Live implementation
       },
       deleteThread: { id in
         // Live implementation
       }
     )
   }
   ```

2. **Add API Actions to Reducers**
   - `.sendPrompt`, `.fetchThreads`, `.threadsResponse`
   - `.run` effects untuk async network calls
   - `.cancel` untuk cancellation

3. **Add Loading & Error States**
   - `isLoading` di State
   - `errorMessage` + dismiss action
   - Skeleton/redacted UI integration

### Phase 3: Testing (Week 4)

1. **Unit Test Reducers**
   ```swift
   @Test
   func destinationSelectedFetchesThreads() async {
     let store = TestStore(initialState: WorkspaceFeature.State()) {
       WorkspaceFeature()
     } withDependencies: {
       $0.apiClient.fetchThreads = { [] }
     }
     
     await store.send(.destinationSelected(.threads)) {
       $0.selectedDestination = .threads
     }
     await store.receive(.fetchThreads)
     await store.receive(.threadsResponse(.success([]))) {
       $0.threads = []
     }
   }
   ```

2. **Integration Tests**
   - Test full user flows
   - Mock API responses
   - Test error handling

---

## Key Principles for TCA Migration

1. **State = Business State Only**
   - Layout constants TIDAK di State
   - Marketing copy TIDAK di State
   - Color schemes TIDAK di State (gunakan Environment)

2. **One Store Per Feature**
   - `WorkspaceFeature` -> `WorkspaceView`
   - `OnboardingFeature` -> `OnboardingView`
   - `AppFeature` meng-compose keduanya

3. **Platform Views = Thin Wrappers**
   - Unified content view menerima Store + LayoutProfile
   - Platform hanya memilih profile dan menambahkan shell chrome

4. **Content Catalog = Dependency**
   - Static strings di-inject via TCA DependencyValues
   - Memudahkan localization dan testing

5. **Preview Support = Store-based**
   - Ganti `WorkspacePreviewSupport` dengan store initialization
   - Preview bisa menggunakan mock dependencies

---

## Files to Create/Modify for TCA

### New Files

```
OpenSpace/
├── Features/
│   ├── Workspace/
│   │   ├── WorkspaceFeature.swift       # TCA Reducer
│   │   ├── WorkspaceView.swift          # Root view (Store-based)
│   │   ├── WorkspaceContentView.swift   # Unified content
│   │   ├── WorkspaceContentCatalog.swift # Static content
│   │   └── Views/
│   │       ├── WorkspaceNavigation.swift
│   │       ├── WorkspaceUtilityBar.swift
│   │       ├── WorkspaceHeroSection.swift
│   │       ├── WorkspaceComposerCard.swift
│   │       └── WorkspaceQuickPrompts.swift
│   ├── Onboarding/
│   │   ├── OnboardingFeature.swift
│   │   ├── OnboardingView.swift
│   │   └── OnboardingContentView.swift
│   └── App/
│       ├── AppFeature.swift
│       └── AppView.swift
├── Shared/
│   ├── Layout/
│   │   ├── WorkspaceLayoutProfile.swift
│   │   └── PlatformProfiles.swift
│   ├── API/
│   │   ├── APIClient.swift
│   │   └── Models/
│   │       ├── Thread.swift
│   │       └── Message.swift
│   └── Dependencies/
│       └── ContentCatalogDependency.swift
```

### Modified Files

- `OpenSpaceApp.swift` -> Initialize Store, remove @State
- `AppRootView.swift` -> Use StoreOf<AppFeature>
- `WorkspaceModels.swift` -> Split into domain files
- `ThemeColors.swift` -> No changes needed

### Deleted Files (post-refactor)

- `WorkspaceAbstractView.swift` (replaced by direct Store usage)
- `OnboardingAbstractView.swift`
- `WorkspaceIOSContentViews.swift`
- `WorkspaceMacContentViews.swift`
- `WorkspaceIPadContentViews.swift`
- `OnboardingIOSView.swift` / `OnboardingMacView.swift` / `OnboardingIPadView.swift`
- `WorkspaceViewBindings.swift` (replaced by Store bindings)
- `WorkspaceRenderContext.swift` (replaced by LayoutProfile)

---

## Conclusion

TCA adoption akan lebih **mudah dan bersih** jika refactoring dilakukan TERLEBIH DAHULU. Struktur saat ini akan membuat TCA implementation menjadi:
- Reducer yang terlalu besar (God Object State)
- View duplication yang berlipat (3x Store binding code)
- Testing yang sulit (state tidak terpisah dari layout/content)

Rekomendasi: **Lakukan pre-TCA refactoring (Phase 0) sebelum mengimplementasikan TCA Reducers.**
