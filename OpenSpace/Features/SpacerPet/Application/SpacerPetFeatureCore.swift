import ComposableArchitecture
import CoreGraphics
import Foundation

@ObservableState
struct SpacerPetFeatureState: Equatable {
    var storedX = 0.78
    var storedY = 0.74
    var storedScale = 1.0
    var isCompanionVisible = false
    var dragStartPoint: CGPoint?
    var dragPoint: CGPoint?
    var isDragging = false
    var latestDragTranslation: CGSize = .zero
    var isMenuPresented = false
    var currentMotion: SpacerPetMotion = .idle
    var expression: SpacerPetExpression = .calm
    var loadingPhase: SpacerPetLoadingPhase = .initializing
    var loadingSessionID = UUID()
    var motionStartedAt = Date()
    var motionTrigger = 0
    var tapReactionIndex = 0
}

@CasePathable
enum SpacerPetFeatureAction: Equatable {
    case onAppear
    case onDisappear
    case preferencesLoaded(SpacerPetPreferences)
    case hideMenuTapped
    case companionTapped
    case longPressed
    case visibilityTapped
    case dragChanged(containerSize: CGSize, currentPoint: CGPoint, translation: CGSize)
    case dragEnded(containerSize: CGSize)
    case growTapped
    case shrinkTapped
    case resetSizeTapped
    case motionTapped(SpacerPetMotion)
    case sceneFirstFrameLoaded(UUID)
    case loadingFallbackElapsed
    case resetMotionElapsed
    case ambientTick
}

@Reducer
struct SpacerPetFeature {
    @Dependency(\.continuousClock) private var clock
    @Dependency(SpacerPetPersistenceClient.self) private var persistence

    private let minCompanionScale = 0.74
    private let maxCompanionScale = 1.42
    private let companionScaleStep = 0.1

    var body: some Reducer<SpacerPetFeatureState, SpacerPetFeatureAction> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let preferences = persistence.load()
                var effects: [Effect<SpacerPetFeatureAction>] = [.send(.preferencesLoaded(preferences))]

                if state.loadingPhase == .initializing {
                    state.loadingPhase = .loading
                }

                if state.loadingPhase != .ready {
                    effects.append(
                        .run { [clock] send in
                            try await clock.sleep(for: .milliseconds(1_600))
                            await send(.loadingFallbackElapsed)
                        }
                        .cancellable(id: "spacerPet.loadingFallback", cancelInFlight: true)
                    )
                }

                effects.append(
                    .run { [clock] send in
                        while !Task.isCancelled {
                            try await clock.sleep(for: .seconds(9))
                            await send(.ambientTick)
                        }
                    }
                    .cancellable(id: "spacerPet.ambientMotion", cancelInFlight: true)
                )

                return .merge(effects)

            case .onDisappear:
                return .merge(
                    .cancel(id: "spacerPet.loadingFallback"),
                    .cancel(id: "spacerPet.resetMotion"),
                    .cancel(id: "spacerPet.ambientMotion")
                )

            case let .preferencesLoaded(preferences):
                state.storedX = preferences.positionX
                state.storedY = preferences.positionY
                state.storedScale = min(max(preferences.scale, minCompanionScale), maxCompanionScale)
                return .none

            case .hideMenuTapped:
                state.isMenuPresented = false
                return .none

            case .companionTapped:
                guard state.isCompanionVisible, state.loadingPhase == .ready, !state.isMenuPresented else {
                    return .none
                }

                let reactions: [SpacerPetMotion] = [.highFive, .wave, .jump, .settle]
                let reaction = reactions[state.tapReactionIndex % reactions.count]
                state.tapReactionIndex += 1
                return play(reaction, state: &state)

            case .longPressed:
                guard state.isCompanionVisible, state.loadingPhase == .ready else {
                    return .none
                }

                state.expression = .curious
                state.currentMotion = .lookAround
                state.motionStartedAt = Date()
                state.motionTrigger += 1
                state.isMenuPresented = true
                return .cancel(id: "spacerPet.resetMotion")

            case .visibilityTapped:
                guard state.loadingPhase == .ready || state.isCompanionVisible else {
                    return .none
                }

                state.isCompanionVisible.toggle()

                if state.isCompanionVisible {
                    return play(.settle, state: &state)
                }

                state.isMenuPresented = false
                state.currentMotion = .idle
                state.expression = .calm
                state.motionStartedAt = Date()
                return .cancel(id: "spacerPet.resetMotion")

            case let .dragChanged(containerSize, currentPoint, translation):
                state.isMenuPresented = false
                let startPoint = state.dragStartPoint ?? currentPoint
                state.dragStartPoint = startPoint
                state.isDragging = true
                state.latestDragTranslation = translation
                state.dragPoint = clampedPoint(
                    CGPoint(x: startPoint.x + translation.width, y: startPoint.y + translation.height),
                    in: containerSize,
                    scale: state.storedScale
                )
                return .none

            case let .dragEnded(containerSize):
                let persistedPoint = state.dragPoint.map {
                    clampedPoint($0, in: containerSize, scale: state.storedScale)
                }

                if let persistedPoint, containerSize.width > 0, containerSize.height > 0 {
                    state.storedX = Double(persistedPoint.x / containerSize.width)
                    state.storedY = Double(persistedPoint.y / containerSize.height)
                }

                state.dragStartPoint = nil
                state.dragPoint = nil
                state.latestDragTranslation = .zero
                state.isDragging = false

                let saveEffect: Effect<SpacerPetFeatureAction>
                if let persistedPoint, containerSize.width > 0, containerSize.height > 0 {
                    let preferences = SpacerPetPreferences(
                        positionX: Double(persistedPoint.x / containerSize.width),
                        positionY: Double(persistedPoint.y / containerSize.height),
                        scale: state.storedScale
                    )
                    saveEffect = .run { [persistence] _ in
                        persistence.save(preferences)
                    }
                } else {
                    saveEffect = .none
                }

                return .merge(saveEffect, play(.settle, state: &state))

            case .growTapped:
                state.storedScale = min(max(state.storedScale + companionScaleStep, minCompanionScale), maxCompanionScale)
                return savePreferences(state)

            case .shrinkTapped:
                state.storedScale = min(max(state.storedScale - companionScaleStep, minCompanionScale), maxCompanionScale)
                return savePreferences(state)

            case .resetSizeTapped:
                state.storedScale = 1.0
                return savePreferences(state)

            case let .motionTapped(motion):
                return play(motion, state: &state)

            case let .sceneFirstFrameLoaded(identifier):
                guard identifier == state.loadingSessionID else {
                    return .none
                }

                return markSceneFirstFrameLoaded(state: &state)

            case .loadingFallbackElapsed:
                return markSceneFirstFrameLoaded(state: &state)

            case .resetMotionElapsed:
                state.currentMotion = .idle
                state.expression = .calm
                state.motionStartedAt = Date()
                return .none

            case .ambientTick:
                guard !state.isMenuPresented, !state.isDragging, state.currentMotion == .idle else {
                    return .none
                }

                guard state.isCompanionVisible, state.loadingPhase == .ready else {
                    return .none
                }

                let ambientMotions: [SpacerPetMotion] = [.lookAround, .jump, .wave, .scan]
                return play(ambientMotions.randomElement() ?? .lookAround, state: &state)
            }
        }
    }

    private func markSceneFirstFrameLoaded(state: inout SpacerPetFeatureState) -> Effect<SpacerPetFeatureAction> {
        guard state.loadingPhase != .ready else {
            return .none
        }

        state.loadingPhase = .ready

        if state.isCompanionVisible {
            return .merge(
                .cancel(id: "spacerPet.loadingFallback"),
                play(.settle, state: &state)
            )
        }

        return .cancel(id: "spacerPet.loadingFallback")
    }

    private func play(_ motion: SpacerPetMotion, state: inout SpacerPetFeatureState) -> Effect<SpacerPetFeatureAction> {
        state.currentMotion = motion
        state.expression = motion.expression
        state.motionStartedAt = Date()
        state.motionTrigger += 1

        if motion.closesMenu {
            state.isMenuPresented = false
        }

        guard motion != .idle else {
            return .cancel(id: "spacerPet.resetMotion")
        }

        return .run { [clock] send in
            try await clock.sleep(for: .nanoseconds(Int64(motion.durationNanoseconds)))
            await send(.resetMotionElapsed)
        }
        .cancellable(id: "spacerPet.resetMotion", cancelInFlight: true)
    }

    private func savePreferences(_ state: SpacerPetFeatureState) -> Effect<SpacerPetFeatureAction> {
        let preferences = SpacerPetPreferences(
            positionX: state.storedX,
            positionY: state.storedY,
            scale: state.storedScale
        )

        return .run { [persistence] _ in
            persistence.save(preferences)
        }
    }

    private func clampedPoint(_ point: CGPoint, in containerSize: CGSize, scale: Double) -> CGPoint {
        guard containerSize.width > 0, containerSize.height > 0 else {
            return .zero
        }

        let companionSize = CGSize(width: 146 * scale, height: 174 * scale)
        let horizontalInset = (companionSize.width / 2) + 12
        let verticalInset = (companionSize.height / 2) + 16
        let minX = min(containerSize.width, horizontalInset)
        let maxX = max(minX, containerSize.width - horizontalInset)
        let minY = min(containerSize.height, verticalInset)
        let maxY = max(minY, containerSize.height - verticalInset)

        return CGPoint(
            x: min(max(point.x, minX), maxX),
            y: min(max(point.y, minY), maxY)
        )
    }
}
