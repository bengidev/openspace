//
//  SpacerPetOverlay.swift
//  OpenSpace
//

import ComposableArchitecture
import Combine
import SwiftUI

struct SpacerPetOverlay: View {
    @Bindable var store: StoreOf<SpacerPetFeature>

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let baseCompanionSize = CGSize(width: 146, height: 174)
    private let menuSize = CGSize(width: 250, height: 374)
    private let visibilityControlSize = CGSize(width: 272, height: 52)
    private let minCompanionScale = 0.74
    private let maxCompanionScale = 1.42

    var body: some View {
        GeometryReader { proxy in
            let containerSize = proxy.size
            let resolvedPoint = resolvedCompanionPoint(in: containerSize)
            let menuPoint = menuPoint(for: resolvedPoint, in: containerSize)
            let visibilityPoint = visibilityControlPoint(in: containerSize)
            let isCompanionReady = store.loadingPhase == .ready
            let isCompanionDisplayed = store.isCompanionVisible && isCompanionReady

            ZStack {
                if store.isMenuPresented {
                    Button {
                        store.send(.hideMenuTapped)
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
                    store.send(.companionTapped)
                } label: {
                    SpacerPetBody(
                        motion: activeMotion,
                        expression: activeExpression,
                        motionStartedAt: store.motionStartedAt,
                        loadIdentifier: store.loadingSessionID,
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
                .sensoryFeedback(.selection, trigger: store.motionTrigger)
                .accessibilityLabel("Pet companion")
                .accessibilityValue("\(activeMotion.title), \(Int(companionScale * 100)) percent")
                .accessibilityHint("Drag to move. Long press to open pet actions.")
                .accessibilityHidden(!isCompanionDisplayed)
                .animation(.easeInOut(duration: 0.18), value: isCompanionDisplayed)
                .animation(.spring(response: 0.28, dampingFraction: 0.78), value: resolvedPoint)
                .animation(.spring(response: 0.24, dampingFraction: 0.8), value: companionScale)
                .zIndex(1)

                if store.isMenuPresented {
                    SpacerPetControlPanel(
                        canGrow: companionScaleValue < maxCompanionScale,
                        canShrink: companionScaleValue > minCompanionScale,
                        growAction: {
                            withAnimation(.spring(response: 0.24, dampingFraction: 0.8)) {
                                _ = store.send(.growTapped)
                            }
                        },
                        shrinkAction: {
                            withAnimation(.spring(response: 0.24, dampingFraction: 0.8)) {
                                _ = store.send(.shrinkTapped)
                            }
                        },
                        resetSizeAction: {
                            withAnimation(.spring(response: 0.24, dampingFraction: 0.8)) {
                                _ = store.send(.resetSizeTapped)
                            }
                        },
                        playAction: { motion in
                            store.send(.motionTapped(motion))
                        }
                    )
                    .frame(width: menuSize.width, height: menuSize.height)
                    .position(menuPoint)
                    .transition(.scale(scale: 0.92).combined(with: .opacity))
                    .zIndex(2)
                }

                SpacerPetVisibilityControl(
                    loadingPhase: store.loadingPhase,
                    isCompanionVisible: store.isCompanionVisible,
                    canToggle: isCompanionReady || store.isCompanionVisible,
                    action: {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                            _ = store.send(.visibilityTapped)
                        }
                    }
                )
                .frame(width: visibilityControlSize.width, height: visibilityControlSize.height)
                .position(visibilityPoint)
                .zIndex(3)
            }
            .animation(.spring(response: 0.24, dampingFraction: 0.86), value: store.isMenuPresented)
        }
        .onAppear {
            store.send(.onAppear)
        }
        .onDisappear {
            store.send(.onDisappear)
        }
        .onReceive(NotificationCenter.default.publisher(for: .spacerPetSceneDidLoadFirstFrame).receive(on: RunLoop.main)) { notification in
            guard let identifier = notification.object as? UUID else {
                return
            }

            store.send(.sceneFirstFrameLoaded(identifier))
        }
    }

    private var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.45, maximumDistance: 18)
            .onEnded { _ in
                store.send(.longPressed)
            }
    }

    private var companionScaleValue: Double {
        min(max(store.storedScale, minCompanionScale), maxCompanionScale)
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
        if store.isDragging {
            return store.latestDragTranslation.width < 0 ? .scootLeft : .scootRight
        }

        return store.currentMotion
    }

    private var activeExpression: SpacerPetExpression {
        if store.isDragging {
            return .focused
        }

        return store.expression
    }

    private func resolvedCompanionPoint(in containerSize: CGSize) -> CGPoint {
        if let dragPoint = store.dragPoint {
            return clampedPoint(dragPoint, in: containerSize)
        }

        let storedPoint = CGPoint(
            x: containerSize.width * CGFloat(store.storedX),
            y: containerSize.height * CGFloat(store.storedY)
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
                store.send(
                    .dragChanged(
                        containerSize: containerSize,
                        currentPoint: currentPoint,
                        translation: value.translation
                    )
                )
            }
            .onEnded { _ in
                store.send(.dragEnded(containerSize: containerSize))
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
}
