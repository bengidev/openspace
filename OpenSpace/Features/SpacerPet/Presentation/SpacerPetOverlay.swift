//
//  SpacerPetOverlay.swift
//  OpenSpace
//

import Combine
import SwiftUI

struct SpacerPetOverlay: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("home.petCompanion.positionX") private var storedX = 0.78
    @AppStorage("home.petCompanion.positionY") private var storedY = 0.74
    @AppStorage("home.petCompanion.scale") private var storedScale = 1.0

    let palette: OpenSpacePalette

    @State private var isCompanionVisible = false
    @State private var dragStartPoint: CGPoint?
    @State private var dragPoint: CGPoint?
    @State private var isDragging = false
    @State private var latestDragTranslation: CGSize = .zero
    @State private var isMenuPresented = false
    @State private var currentMotion: SpacerPetMotion = .idle
    @State private var expression: SpacerPetExpression = .calm
    @State private var loadingPhase: SpacerPetLoadingPhase = .initializing
    @State private var loadingSessionID = UUID()
    @State private var motionStartedAt = Date()
    @State private var motionTrigger = 0
    @State private var tapReactionIndex = 0
    @State private var loadingFallbackTask: Task<Void, Never>?
    @State private var resetMotionTask: Task<Void, Never>?
    @State private var ambientMotionTask: Task<Void, Never>?

    private let baseCompanionSize = CGSize(width: 146, height: 174)
    private let menuSize = CGSize(width: 250, height: 374)
    private let visibilityControlSize = CGSize(width: 272, height: 52)
    private let minCompanionScale = 0.74
    private let maxCompanionScale = 1.42
    private let companionScaleStep = 0.1

    var body: some View {
        GeometryReader { proxy in
            let containerSize = proxy.size
            let resolvedPoint = resolvedCompanionPoint(in: containerSize)
            let menuPoint = menuPoint(for: resolvedPoint, in: containerSize)
            let visibilityPoint = visibilityControlPoint(in: containerSize)
            let isCompanionReady = loadingPhase == .ready
            let isCompanionDisplayed = isCompanionVisible && isCompanionReady

            ZStack {
                if isMenuPresented {
                    Button {
                        hideMenu()
                    } label: {
                        Rectangle()
                            .fill(.clear)
                            .contentShape(Rectangle())
                            .frame(width: containerSize.width, height: containerSize.height)
                    }
                    .frame(width: containerSize.width, height: containerSize.height)
                    .position(x: containerSize.width / 2, y: containerSize.height / 2)
                    .buttonStyle(.plain)
                    .accessibilityHidden(true)
                    .zIndex(0)
                }

                Button {
                    guard isCompanionDisplayed, !isMenuPresented else {
                        return
                    }
                    playNextTapReaction()
                } label: {
                    SpacerPetBody(
                        palette: palette,
                        motion: activeMotion,
                        expression: activeExpression,
                        motionStartedAt: motionStartedAt,
                        loadIdentifier: loadingSessionID,
                        reduceMotion: reduceMotion
                    )
                    .frame(width: baseCompanionSize.width, height: baseCompanionSize.height)
                    .scaleEffect(companionScale)
                    .frame(width: companionSize.width, height: companionSize.height)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .opacity(isCompanionDisplayed ? 1 : 0.001)
                .allowsHitTesting(isCompanionDisplayed)
                .position(resolvedPoint)
                .highPriorityGesture(
                    dragGesture(containerSize: containerSize, currentPoint: resolvedPoint)
                )
                .simultaneousGesture(longPressGesture)
                .sensoryFeedback(.selection, trigger: motionTrigger)
                .accessibilityLabel("Pet companion")
                .accessibilityValue("\(activeMotion.title), \(Int(companionScale * 100)) percent")
                .accessibilityHint("Drag to move. Long press to open pet actions.")
                .accessibilityHidden(!isCompanionDisplayed)
                .animation(.easeInOut(duration: 0.18), value: isCompanionDisplayed)
                .animation(.spring(response: 0.28, dampingFraction: 0.78), value: resolvedPoint)
                .animation(.spring(response: 0.24, dampingFraction: 0.8), value: companionScale)
                .zIndex(1)

                if isMenuPresented {
                    SpacerPetControlPanel(
                        palette: palette,
                        canGrow: companionScaleValue < maxCompanionScale,
                        canShrink: companionScaleValue > minCompanionScale,
                        growAction: {
                            adjustCompanionScale(by: companionScaleStep)
                        },
                        shrinkAction: {
                            adjustCompanionScale(by: -companionScaleStep)
                        },
                        resetSizeAction: {
                            resetCompanionScale()
                        },
                        playAction: { motion in
                            play(motion)
                        }
                    )
                    .frame(width: menuSize.width, height: menuSize.height)
                    .position(menuPoint)
                    .transition(.scale(scale: 0.92).combined(with: .opacity))
                    .zIndex(2)
                }

                SpacerPetVisibilityControl(
                    palette: palette,
                    loadingPhase: loadingPhase,
                    isCompanionVisible: isCompanionVisible,
                    canToggle: isCompanionReady || isCompanionVisible,
                    action: toggleCompanionVisibility
                )
                .frame(width: visibilityControlSize.width, height: visibilityControlSize.height)
                .position(visibilityPoint)
                .zIndex(3)
            }
            .animation(.spring(response: 0.24, dampingFraction: 0.86), value: isMenuPresented)
        }
        .onAppear {
            startLoadingPreparation()
            startAmbientMotionLoop()
        }
        .onDisappear {
            loadingFallbackTask?.cancel()
            resetMotionTask?.cancel()
            ambientMotionTask?.cancel()
            loadingFallbackTask = nil
            ambientMotionTask = nil
        }
        .onReceive(NotificationCenter.default.publisher(for: .spacerPetSceneDidLoadFirstFrame).receive(on: RunLoop.main)) { notification in
            guard let identifier = notification.object as? UUID, identifier == loadingSessionID else {
                return
            }

            markSceneFirstFrameLoaded()
        }
    }

    private var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.45, maximumDistance: 18)
            .onEnded { _ in
                guard isCompanionVisible, loadingPhase == .ready else {
                    return
                }
                showMenu()
            }
    }

    private var companionScaleValue: Double {
        min(max(storedScale, minCompanionScale), maxCompanionScale)
    }

    private var companionScale: CGFloat {
        CGFloat(companionScaleValue)
    }

    private var companionSize: CGSize {
        CGSize(
            width: baseCompanionSize.width * companionScale,
            height: baseCompanionSize.height * companionScale
        )
    }

    private var activeMotion: SpacerPetMotion {
        if isDragging {
            return latestDragTranslation.width < 0 ? .scootLeft : .scootRight
        }

        return currentMotion
    }

    private var activeExpression: SpacerPetExpression {
        if isDragging {
            return .focused
        }

        return expression
    }

    private func resolvedCompanionPoint(in containerSize: CGSize) -> CGPoint {
        if let dragPoint {
            return clampedPoint(dragPoint, in: containerSize)
        }

        let storedPoint = CGPoint(
            x: containerSize.width * CGFloat(storedX),
            y: containerSize.height * CGFloat(storedY)
        )
        return clampedPoint(storedPoint, in: containerSize)
    }

    private func menuPoint(for companionPoint: CGPoint, in containerSize: CGSize) -> CGPoint {
        guard containerSize.width > 0, containerSize.height > 0 else {
            return .zero
        }

        let horizontalInset = (menuSize.width / 2) + 12
        let verticalInset = (menuSize.height / 2) + 16
        let verticalGap: CGFloat = 16
        let preferredY = companionPoint.y - (companionSize.height / 2) - verticalGap - (menuSize.height / 2)
        let fallbackY = companionPoint.y + (companionSize.height / 2) + verticalGap + (menuSize.height / 2)
        let rawY = preferredY >= verticalInset ? preferredY : fallbackY

        return CGPoint(
            x: min(max(companionPoint.x, horizontalInset), max(horizontalInset, containerSize.width - horizontalInset)),
            y: min(max(rawY, verticalInset), max(verticalInset, containerSize.height - verticalInset))
        )
    }

    private func visibilityControlPoint(in containerSize: CGSize) -> CGPoint {
        guard containerSize.width > 0, containerSize.height > 0 else {
            return .zero
        }

        let horizontalInset = (visibilityControlSize.width / 2) + 12
        let verticalInset = (visibilityControlSize.height / 2) + 18

        return CGPoint(
            x: min(max(containerSize.width / 2, horizontalInset), max(horizontalInset, containerSize.width - horizontalInset)),
            y: min(max(containerSize.height - 58, verticalInset), max(verticalInset, containerSize.height - verticalInset))
        )
    }

    private func dragGesture(containerSize: CGSize, currentPoint: CGPoint) -> some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { value in
                hideMenu()
                let startPoint = dragStartPoint ?? currentPoint
                dragStartPoint = startPoint
                isDragging = true
                latestDragTranslation = value.translation

                dragPoint = clampedPoint(
                    CGPoint(
                        x: startPoint.x + value.translation.width,
                        y: startPoint.y + value.translation.height
                    ),
                    in: containerSize
                )
            }
            .onEnded { _ in
                if let dragPoint {
                    persist(point: dragPoint, in: containerSize)
                }

                dragStartPoint = nil
                dragPoint = nil
                latestDragTranslation = .zero
                isDragging = false
                play(.settle)
            }
    }

    private func clampedPoint(_ point: CGPoint, in containerSize: CGSize) -> CGPoint {
        guard containerSize.width > 0, containerSize.height > 0 else {
            return .zero
        }

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

    private func persist(point: CGPoint, in containerSize: CGSize) {
        guard containerSize.width > 0, containerSize.height > 0 else {
            return
        }

        let clamped = clampedPoint(point, in: containerSize)
        storedX = Double(clamped.x / containerSize.width)
        storedY = Double(clamped.y / containerSize.height)
    }

    private func showMenu() {
        guard isCompanionVisible, loadingPhase == .ready else {
            return
        }

        resetMotionTask?.cancel()
        expression = .curious
        currentMotion = .lookAround
        motionStartedAt = Date()
        motionTrigger += 1
        isMenuPresented = true
    }

    private func hideMenu() {
        guard isMenuPresented else {
            return
        }

        isMenuPresented = false
    }

    private func toggleCompanionVisibility() {
        guard loadingPhase == .ready || isCompanionVisible else {
            return
        }

        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
            isCompanionVisible.toggle()
        }

        if isCompanionVisible {
            play(.settle)
        } else {
            hideMenu()
            resetMotionTask?.cancel()
            currentMotion = .idle
            expression = .calm
            motionStartedAt = Date()
        }
    }

    private func playNextTapReaction() {
        let reactions: [SpacerPetMotion] = [.highFive, .wave, .jump, .settle]
        let reaction = reactions[tapReactionIndex % reactions.count]
        tapReactionIndex += 1
        play(reaction)
    }

    private func play(_ motion: SpacerPetMotion) {
        resetMotionTask?.cancel()
        currentMotion = motion
        expression = motion.expression
        motionStartedAt = Date()
        motionTrigger += 1

        if motion.closesMenu {
            hideMenu()
        }

        guard motion != .idle else {
            return
        }

        resetMotionTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: motion.durationNanoseconds)
            guard !Task.isCancelled else {
                return
            }
            currentMotion = .idle
            expression = .calm
            motionStartedAt = Date()
        }
    }

    private func startLoadingPreparation() {
        guard loadingPhase != .ready else {
            return
        }

        if loadingPhase == .initializing {
            withAnimation(.easeInOut(duration: 0.16)) {
                loadingPhase = .loading
            }
        }

        loadingFallbackTask?.cancel()
        loadingFallbackTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_600_000_000)
            guard !Task.isCancelled, loadingPhase != .ready else {
                return
            }

            markSceneFirstFrameLoaded()
        }
    }

    private func markSceneFirstFrameLoaded() {
        guard loadingPhase != .ready else {
            return
        }

        loadingFallbackTask?.cancel()
        loadingFallbackTask = nil

        withAnimation(.easeInOut(duration: 0.18)) {
            loadingPhase = .ready
        }

        if isCompanionVisible {
            play(.settle)
        }
    }

    private func adjustCompanionScale(by amount: Double) {
        withAnimation(.spring(response: 0.24, dampingFraction: 0.8)) {
            storedScale = min(max(companionScaleValue + amount, minCompanionScale), maxCompanionScale)
        }
    }

    private func resetCompanionScale() {
        withAnimation(.spring(response: 0.24, dampingFraction: 0.8)) {
            storedScale = 1.0
        }
    }

    private func startAmbientMotionLoop() {
        guard ambientMotionTask == nil else {
            return
        }

        ambientMotionTask = Task { @MainActor in
            let ambientMotions: [SpacerPetMotion] = [.lookAround, .jump, .wave, .scan]

            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 9_000_000_000)
                guard !Task.isCancelled else {
                    return
                }

                guard !isMenuPresented, !isDragging, currentMotion == .idle else {
                    continue
                }

                guard isCompanionVisible, loadingPhase == .ready else {
                    continue
                }

                play(ambientMotions.randomElement() ?? .lookAround)
            }
        }
    }
}
