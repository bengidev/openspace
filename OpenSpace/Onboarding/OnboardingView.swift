import ComposableArchitecture
import Foundation
import SwiftUI

struct OnboardingView: View {
    @Bindable var store: StoreOf<OnboardingFeature>
    var onFinish: () -> Void = {}

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { proxy in
            let palette = OpenSpaceOnboardingPalette.resolve(colorScheme)
            let size = proxy.size
            let compactHeight = size.height < 760
            let horizontalPadding = min(max(size.width * 0.055, 20), 36)
            let visualHeight = max(compactHeight ? 270 : 326, min(size.height * (compactHeight ? 0.39 : 0.43), 390))

            ZStack {
                palette.background
                    .ignoresSafeArea()

                PixelGridBackground(
                    palette: palette,
                    spacing: compactHeight ? 18 : 22,
                    dotSize: 1.0,
                    opacity: palette.isDark ? 0.06 : 0.04
                )
                .ignoresSafeArea()

                DiagonalHatchPattern(
                    palette: palette,
                    spacing: 10,
                    opacity: palette.isDark ? 0.10 : 0.04
                )
                .ignoresSafeArea()

                VStack(spacing: compactHeight ? 12 : 18) {
                    topBar(palette: palette)

                    FeaturePageView(
                        page: store.currentPageData,
                        visualHeight: visualHeight,
                        palette: palette,
                        pairingConfirmed: store.pairingConfirmed,
                        selectedPromptIndex: store.selectedPromptIndex,
                        queuedPromptCount: store.queuedPromptCount,
                        reasoningLevel: $store.reasoningLevel.sending(\.reasoningLevelChanged),
                        onPairingToggle: { _ = store.send(.pairingToggleTapped) },
                        onPromptSelected: { _ = store.send(.promptChipTapped($0)) },
                        onAddQueuedPrompt: { _ = store.send(.addQueuedPromptTapped) }
                    )
                    .id(store.currentPageData.id)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        )
                    )

                    bottomNavigation(palette: palette)
                }
                .frame(maxWidth: 680)
                .padding(.horizontal, horizontalPadding)
                .padding(.top, compactHeight ? 8 : 12)
                .padding(.bottom, max(proxy.safeAreaInsets.bottom + 10, 18))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .sensoryFeedback(.selection, trigger: store.currentPage)
        }
    }

    private func topBar(palette: OpenSpaceOnboardingPalette) -> some View {
        HStack(spacing: 12) {
            HStack(spacing: 9) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(palette.primaryActionFill)
                        .frame(width: 20, height: 20)
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(palette.accent)
                        .frame(width: 7, height: 14)
                        .offset(x: 4)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text("OPENSPACE")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(palette.textPrimary)
                    Text("AI ASSISTANCE")
                        .font(.system(size: 9, weight: .regular))
                        .foregroundStyle(palette.textMuted)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("OpenSpace AI assistance")

            Spacer(minLength: 10)

            Text(String(format: "PG.%02d / %02d", store.currentPage + 1, store.totalPages))
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .tracking(-0.24)
                .foregroundStyle(palette.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Button {
                _ = store.send(.skipTapped)
                onFinish()
            } label: {
                Text("SKIP")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(palette.textSecondary)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Skip onboarding")
        }
        .frame(height: 44)
    }

    private func bottomNavigation(palette: OpenSpaceOnboardingPalette) -> some View {
        VStack(spacing: 24) {
            HStack(spacing: 8) {
                ForEach(0..<store.totalPages, id: \.self) { index in
                    Button {
                        withAnimation(.spring(response: 0.36, dampingFraction: 0.82)) {
                            _ = store.send(.pageSelected(index))
                        }
                    } label: {
                        Capsule(style: .continuous)
                            .fill(index == store.currentPage ? palette.accent : palette.border)
                            .frame(width: index == store.currentPage ? 28 : 6, height: 6)
                            .animation(.spring(response: 0.34, dampingFraction: 0.76), value: store.currentPage)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Go to onboarding page \(index + 1)")
                }
            }

            HStack(spacing: 10) {
                if store.currentPage > 0 {
                    Button {
                        withAnimation(.spring(response: 0.36, dampingFraction: 0.82)) {
                            _ = store.send(.previousTapped)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.left")
                            Text("BACK")
                        }
                    }
                    .buttonStyle(FactorySecondaryButtonStyle(palette: palette))
                    .accessibilityLabel("Previous onboarding page")
                }

                Button {
                    if store.isLastPage {
                        _ = store.send(.finishTapped)
                        onFinish()
                    } else {
                        withAnimation(.spring(response: 0.36, dampingFraction: 0.82)) {
                            _ = store.send(.nextTapped)
                        }
                    }
                } label: {
                    HStack(spacing: 9) {
                        Text(store.isLastPage ? "ENTER OPENSPACE" : "CONTINUE")
                        Image(systemName: store.isLastPage ? "arrow.up.right" : "arrow.right")
                    }
                }
                .buttonStyle(FactoryPrimaryButtonStyle(palette: palette))
                .accessibilityLabel(store.isLastPage ? "Enter OpenSpace" : "Continue onboarding")
            }
        }
    }
}

private struct FeaturePageView: View {
    let page: OnboardingPage
    let visualHeight: CGFloat
    let palette: OpenSpaceOnboardingPalette
    let pairingConfirmed: Bool
    let selectedPromptIndex: Int
    let queuedPromptCount: Int
    @Binding var reasoningLevel: Double
    let onPairingToggle: () -> Void
    let onPromptSelected: (Int) -> Void
    let onAddQueuedPrompt: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    var body: some View {
        if page.model == .workspaceReady {
            WorkspaceReadyVisual(page: page, palette: palette, appeared: appeared)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .task(id: page.id) {
                    await runEntrance()
                }
        } else {
            VStack(alignment: .leading, spacing: 13) {
                HStack(spacing: 10) {
                    FactoryBadge(title: page.eyebrow, systemImage: badgeSymbol, palette: palette)
                    Spacer(minLength: 8)
                    Text(page.indexLabel)
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .tracking(-0.24)
                        .foregroundStyle(palette.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(palette.accent.opacity(palette.isDark ? 0.12 : 0.10))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .stroke(palette.accent.opacity(0.28), lineWidth: 1)
                        )
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 8)

                Text(page.headline)
                    .font(.system(size: titleSize, weight: .regular))
                    .tracking(-1.2)
                    .foregroundStyle(palette.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)

                Text(page.body)
                    .font(.system(size: 13.5, weight: .regular))
                    .foregroundStyle(palette.textSecondary)
                    .lineSpacing(3)
                    .lineLimit(3)
                    .minimumScaleFactor(0.82)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 8)

                FactoryCardChrome(palette: palette, cornerRadius: 6) {
                    ZStack {
                        palette.backgroundSecondary

                        PixelGridBackground(
                            palette: palette,
                            spacing: 15,
                            dotSize: 1.0,
                            opacity: palette.isDark ? 0.06 : 0.04
                        )

                        DiagonalHatchPattern(
                            palette: palette,
                            spacing: 10,
                            opacity: palette.isDark ? 0.10 : 0.04
                        )

                        if page.model == .promptQueue {
                            VStack(spacing: 0) {
                                terminalHeader
                                    .padding(.horizontal, 14)
                                    .padding(.top, 14)
                                    .padding(.bottom, 8)

                                GeometryReader { bodyProxy in
                                    ScrollViewReader { scrollProxy in
                                        ScrollView(.vertical, showsIndicators: false) {
                                            visualBody
                                                .frame(minHeight: bodyProxy.size.height, alignment: .center)
                                        }
                                        .scrollIndicators(.hidden)
                                        .contentMargins(.vertical, 0, for: .scrollContent)
                                        .scrollBounceBehavior(.basedOnSize)
                                        .padding(.horizontal, 14)
                                        .onChange(of: queuedPromptCount) { _, newValue in
                                            if newValue > 0 {
                                                withAnimation(.easeOut(duration: 0.32)) {
                                                    scrollProxy.scrollTo("queueLast", anchor: .bottom)
                                                }
                                            }
                                        }
                                    }
                                }

                                Button(action: onAddQueuedPrompt) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "plus")
                                        Text(queuedPromptCount >= PromptQueueItem.samples.count ? "RESET QUEUE" : "ADD FOLLOW-UP")
                                        Spacer()
                                        Text("⌘↩")
                                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                            .tracking(-0.24)
                                            .foregroundStyle(palette.textMuted)
                                    }
                                    .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                                    .tracking(-0.24)
                                    .foregroundStyle(palette.accent)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                                            .fill(palette.accent.opacity(0.11))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                                            .stroke(palette.accent.opacity(0.28), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Add follow-up prompt")
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)

                                highlightFooter
                                    .padding(.horizontal, 14)
                                    .padding(.bottom, 14)
                            }
                        } else {
                            VStack(spacing: 12) {
                                terminalHeader
                                visualBody
                                highlightFooter
                            }
                            .padding(14)
                        }
                    }
                    .frame(height: visualHeight)
                }
                .factorySignalGlitch(progress: appeared ? 1 : 0, intensity: page.shaderIntensity)
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.985)
                .offset(y: appeared ? 0 : 14)
            }
            .animation(.spring(response: 0.48, dampingFraction: 0.82), value: appeared)
            .task(id: page.id) {
                await runEntrance()
            }
        }
    }

    private var titleSize: CGFloat {
        page.headline.count > 58 ? 27 : 30
    }

    private var badgeSymbol: String {
        switch page.model {
        case .encryptedPairing: "lock.shield"
        case .ideaStudio: "sparkles"
        case .promptQueue: "text.line.first.and.arrowtriangle.forward"
        case .reasoningControl: "slider.horizontal.3"
        case .workspaceReady: "sparkle"
        }
    }

    @MainActor
    private func runEntrance() async {
        appeared = false
        guard !reduceMotion else {
            appeared = true
            return
        }
        try? await Task.sleep(nanoseconds: 70_000_000)
        withAnimation(.spring(response: 0.48, dampingFraction: 0.82)) {
            appeared = true
        }
    }

    private var terminalHeader: some View {
        HStack(spacing: 10) {
            HStack(spacing: 5) {
                Circle().fill(palette.accent).frame(width: 7, height: 7)
                Circle().fill(palette.textMuted.opacity(0.42)).frame(width: 7, height: 7)
                Circle().fill(palette.textMuted.opacity(0.24)).frame(width: 7, height: 7)
            }

            Text(page.metric)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .tracking(-0.24)
                .foregroundStyle(palette.textSecondary)

            Spacer()

            Text("AGENTS / PROMPTS / MODELS / REVIEW")
                .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                .tracking(-0.24)
                .foregroundStyle(palette.textMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.56)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(palette.surface.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(palette.border, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var visualBody: some View {
        switch page.model {
        case .encryptedPairing:
            EncryptedPairingVisual(
                palette: palette,
                isConfirmed: pairingConfirmed,
                appeared: appeared,
                onToggle: onPairingToggle
            )

        case .ideaStudio:
            IdeaStudioVisual(
                palette: palette,
                selectedPromptIndex: selectedPromptIndex,
                appeared: appeared,
                onPromptSelected: onPromptSelected
            )

        case .promptQueue:
            PromptQueueVisual(
                palette: palette,
                queuedPromptCount: queuedPromptCount,
                appeared: appeared,
                onAddQueuedPrompt: onAddQueuedPrompt
            )

        case .reasoningControl:
            ReasoningControlVisual(
                palette: palette,
                reasoningLevel: $reasoningLevel,
                appeared: appeared
            )

        case .workspaceReady:
            WorkspaceReadyVisual(
                page: page,
                palette: palette,
                appeared: appeared
            )
        }
    }

    private var highlightFooter: some View {
        HStack(spacing: 8) {
            ForEach(Array(page.highlights.enumerated()), id: \.element.id) { index, highlight in
                HStack(spacing: 9) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(index == 0 ? palette.accent.opacity(0.12) : palette.surface.opacity(0.4))
                            .frame(width: 28, height: 28)
                        Image(systemName: highlight.symbol)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(index == 0 ? palette.accent : palette.textSecondary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(highlight.title.uppercased())
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .tracking(-0.24)
                            .foregroundStyle(palette.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
                        Text(highlight.detail)
                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                            .foregroundStyle(palette.textMuted)
                            .lineLimit(1)
                            .minimumScaleFactor(0.62)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(9)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(palette.backgroundSecondary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(palette.border, lineWidth: 1)
                )
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 8)
                .animation(.spring(response: 0.42, dampingFraction: 0.8).delay(Double(index) * 0.05), value: appeared)
            }
        }
    }
}

private struct EncryptedPairingVisual: View {
    let palette: OpenSpaceOnboardingPalette
    let isConfirmed: Bool
    let appeared: Bool
    let onToggle: () -> Void

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                DeviceNode(title: "LOCAL", subtitle: "Local key", systemImage: "iphone", palette: palette, active: isConfirmed)
                    .offset(x: appeared ? 0 : -24)
                Spacer(minLength: 6)
                DeviceNode(title: "OPENSPACE", subtitle: "AI chat lane", systemImage: "macbook", palette: palette, active: true)
                    .offset(x: appeared ? 0 : 24)
            }
            .padding(.horizontal, 8)

            VStack(spacing: 8) {
                ZStack {
                    Capsule(style: .continuous)
                        .stroke(palette.border.opacity(0.8), style: StrokeStyle(lineWidth: 1, dash: [5, 7]))
                        .frame(height: 3)
                        .padding(.horizontal, 82)

                    Circle()
                        .fill(palette.accent)
                        .frame(width: 9, height: 9)
                        .shadow(color: palette.accent.opacity(0.45), radius: 10)
                        .offset(x: isConfirmed ? 56 : -56)
                        .animation(.spring(response: 0.46, dampingFraction: 0.72), value: isConfirmed)

                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(palette.inverseSurface)
                        .frame(width: 82, height: 82)
                        .overlay(
                            Image(systemName: isConfirmed ? "lock.shield.fill" : "lock.open.trianglebadge.exclamationmark")
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundStyle(isConfirmed ? palette.accent : palette.warning)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .stroke(palette.textPrimary.opacity(palette.isDark ? 0.15 : 0.08), lineWidth: 1)
                        )
                }

                Button(action: onToggle) {
                    HStack(spacing: 7) {
                        Image(systemName: isConfirmed ? "arrow.triangle.2.circlepath" : "link.badge.plus")
                        Text(isConfirmed ? "ROTATE KEY" : "PAIR DEVICE")
                    }
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .tracking(-0.24)
                    .foregroundStyle(isConfirmed ? palette.accent : palette.warning)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill((isConfirmed ? palette.accent : palette.warning).opacity(0.12))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke((isConfirmed ? palette.accent : palette.warning).opacity(0.32), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isConfirmed ? "Rotate encryption key" : "Pair device")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct DeviceNode: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let palette: OpenSpaceOnboardingPalette
    let active: Bool

    var body: some View {
        VStack(spacing: 9) {
            ZStack {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(palette.surface.opacity(0.5))
                    .frame(width: 76, height: 92)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(active ? palette.accent.opacity(0.52) : palette.border, lineWidth: 1)
                    )
                Image(systemName: systemImage)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(active ? palette.textPrimary : palette.textMuted)
            }
            VStack(spacing: 3) {
                Text(title)
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .tracking(-0.24)
                    .foregroundStyle(palette.textPrimary)
                Text(subtitle)
                    .font(.system(size: 8.5, weight: .regular, design: .monospaced))
                    .foregroundStyle(palette.textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .frame(width: 108)
    }
}

private struct IdeaStudioVisual: View {
    let palette: OpenSpaceOnboardingPalette
    let selectedPromptIndex: Int
    let appeared: Bool
    let onPromptSelected: (Int) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var typedCount = 0

    private var prompt: String {
        PromptOption.samples[selectedPromptIndex].prompt
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 7) {
                ForEach(Array(PromptOption.samples.enumerated()), id: \.element.id) { index, option in
                    Button {
                        onPromptSelected(index)
                    } label: {
                        Text(option.label)
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .tracking(-0.24)
                            .foregroundStyle(index == selectedPromptIndex ? palette.primaryActionText : palette.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(index == selectedPromptIndex ? palette.primaryActionFill : palette.surface.opacity(0.4))
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Select prompt mode \(option.label)")
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 8) {
                    Text(">")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundStyle(palette.accent)
                    Text(String(prompt.prefix(typedCount)))
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(palette.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)
                    Rectangle()
                        .fill(palette.textPrimary)
                        .frame(width: 6, height: 15)
                        .opacity(typedCount < prompt.count ? 1 : 0.34)
                }

                VStack(alignment: .leading, spacing: 6) {
                    ResponseLine(width: 0.84, palette: palette, active: appeared, delay: 0)
                    ResponseLine(width: 0.62, palette: palette, active: appeared, delay: 0.07)
                    ResponseLine(width: 0.74, palette: palette, active: appeared, delay: 0.14)
                }
            }
            .padding(13)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(palette.background.opacity(palette.isDark ? 0.5 : 0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(palette.border, lineWidth: 1)
            )
        }
        .task(id: prompt) {
            await animateTyping()
        }
    }

    @MainActor
    private func animateTyping() async {
        typedCount = reduceMotion ? prompt.count : 0
        guard !reduceMotion else { return }

        for count in 0...prompt.count {
            typedCount = count
            try? await Task.sleep(nanoseconds: 16_000_000)
        }
    }
}

private struct ResponseLine: View {
    let width: CGFloat
    let palette: OpenSpaceOnboardingPalette
    let active: Bool
    let delay: Double

    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            palette.accent.opacity(0.18),
                            palette.textPrimary.opacity(0.20),
                            palette.textMuted.opacity(0.12),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: proxy.size.width * width, height: 8)
                .opacity(active ? 1 : 0)
                .offset(x: active ? 0 : -12)
                .animation(.easeOut(duration: 0.34).delay(delay), value: active)
        }
        .frame(height: 8)
    }
}

private struct PromptQueueVisual: View {
    let palette: OpenSpaceOnboardingPalette
    let queuedPromptCount: Int
    let appeared: Bool
    let onAddQueuedPrompt: () -> Void

    var body: some View {
        VStack(spacing: 9) {
            ForEach(Array(PromptQueueItem.samples.prefix(queuedPromptCount).enumerated()), id: \.element.id) { index, item in
                QueueRow(item: item, index: index, palette: palette, appeared: appeared)
            }

            Color.clear
                .frame(height: 16)
                .id("queueLast")
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }
}

private struct QueueRow: View {
    let item: PromptQueueItem
    let index: Int
    let palette: OpenSpaceOnboardingPalette
    let appeared: Bool

    var body: some View {
        HStack(spacing: 10) {
            VStack(spacing: 3) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                if index < PromptQueueItem.samples.count - 1 {
                    Rectangle()
                        .fill(palette.border.opacity(0.72))
                        .frame(width: 1, height: 20)
                }
            }
            .frame(width: 12)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(item.status.rawValue)
                        .font(.system(size: 8.5, weight: .semibold, design: .monospaced))
                        .tracking(-0.24)
                        .foregroundStyle(statusColor)
                    Text(item.title)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(palette.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }

                Text(item.detail)
                    .font(.system(size: 9.5, weight: .regular, design: .monospaced))
                    .foregroundStyle(palette.textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
            }

            Spacer(minLength: 4)

            Image(systemName: index == 0 ? "hourglass" : "text.line.first.and.arrowtriangle.forward")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(index == 0 ? palette.accent : palette.textMuted)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(palette.surface.opacity(index == 0 ? 0.5 : 0.3))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(index == 0 ? palette.accent.opacity(0.34) : palette.border, lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.spring(response: 0.38, dampingFraction: 0.8).delay(Double(index) * 0.055), value: appeared)
    }

    private var statusColor: Color {
        switch item.status {
        case .running: palette.accent
        case .next: palette.warning
        case .queued: palette.textSecondary
        case .ready: palette.success
        }
    }
}

private struct ReasoningControlVisual: View {
    let palette: OpenSpaceOnboardingPalette
    @Binding var reasoningLevel: Double
    let appeared: Bool

    private var percentage: Int {
        Int((reasoningLevel * 100).rounded())
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(palette.border.opacity(0.75), lineWidth: 1)
                        .frame(width: 76, height: 76)
                    Circle()
                        .trim(from: 0, to: reasoningLevel)
                        .stroke(palette.accent, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 76, height: 76)
                        .animation(.spring(response: 0.42, dampingFraction: 0.74), value: reasoningLevel)
                    Text("\(percentage)%")
                        .font(.system(size: 17, weight: .semibold, design: .monospaced))
                        .tracking(-0.24)
                        .foregroundStyle(palette.textPrimary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(reasoningLabel.uppercased())
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .tracking(-0.24)
                        .foregroundStyle(palette.accent)
                    Text("Set thinking before run.")
                        .font(.system(size: 10.5, weight: .regular, design: .monospaced))
                        .foregroundStyle(palette.textMuted)
                        .lineLimit(2)
                }
                Spacer(minLength: 4)
            }

            Slider(value: $reasoningLevel, in: 0...1)
                .tint(palette.accent)
                .accessibilityLabel("Reasoning level")
                .accessibilityValue("\(percentage) percent")

            HStack(spacing: 7) {
                ReasoningPresetButton(title: "FAST", value: 0.22, level: $reasoningLevel, palette: palette)
                ReasoningPresetButton(title: "BALANCED", value: 0.62, level: $reasoningLevel, palette: palette)
                ReasoningPresetButton(title: "DEEP", value: 0.9, level: $reasoningLevel, palette: palette)
            }

            HStack(alignment: .bottom, spacing: 7) {
                ForEach(0..<8, id: \.self) { index in
                    let normalizedIndex = Double(index + 1) / 8
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(normalizedIndex <= reasoningLevel ? palette.accent : palette.textMuted.opacity(0.22))
                        .frame(height: 12 + CGFloat(index) * 4)
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(y: appeared ? 1 : 0.35, anchor: .bottom)
                        .animation(.spring(response: 0.42, dampingFraction: 0.8).delay(Double(index) * 0.035), value: appeared)
                }
            }
            .frame(height: 44)
        }
        .padding(.horizontal, 4)
        .frame(maxHeight: .infinity, alignment: .center)
    }

    private var reasoningLabel: String {
        switch reasoningLevel {
        case ..<0.38: "Fast answer"
        case ..<0.76: "Balanced plan"
        default: "Deep reasoning"
        }
    }
}

private struct ReasoningPresetButton: View {
    let title: String
    let value: Double
    @Binding var level: Double
    let palette: OpenSpaceOnboardingPalette

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.36, dampingFraction: 0.76)) {
                level = value
            }
        } label: {
            Text(title)
                .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                .tracking(-0.24)
                .foregroundStyle(abs(level - value) < 0.08 ? palette.primaryActionText : palette.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(abs(level - value) < 0.08 ? palette.primaryActionFill : palette.surface.opacity(0.4))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(abs(level - value) < 0.08 ? palette.primaryActionFill.opacity(0.3) : palette.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct WorkspaceReadyVisual: View {
    let page: OnboardingPage
    let palette: OpenSpaceOnboardingPalette
    let appeared: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(palette.accent)
                        .frame(width: 7, height: 7)
                        .shadow(color: palette.accent.opacity(0.45), radius: 8)

                    Image(systemName: "gearshape")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(palette.textMuted)

                    Text("WORKSPACE READY")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .tracking(-0.24)
                        .foregroundStyle(palette.textMuted)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(palette.surface.opacity(0.5))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(palette.border, lineWidth: 1)
                )
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
                .animation(.spring(response: 0.48, dampingFraction: 0.82).delay(0.05), value: appeared)

                Text(page.headline)
                    .font(.system(size: 56, weight: .regular))
                    .tracking(-1.6)
                    .foregroundStyle(palette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 14)
                    .animation(.spring(response: 0.52, dampingFraction: 0.8).delay(0.12), value: appeared)

                Text(page.body)
                    .font(.system(size: 19, weight: .regular))
                    .foregroundStyle(palette.textSecondary)
                    .lineSpacing(4)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .minimumScaleFactor(0.82)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)
                    .animation(.spring(response: 0.52, dampingFraction: 0.8).delay(0.20), value: appeared)

                HStack(spacing: 6) {
                    ForEach(Array(page.highlights.enumerated()), id: \.element.id) { index, highlight in
                        Text(highlight.title.uppercased())
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .tracking(-0.24)
                            .foregroundStyle(palette.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(palette.surface.opacity(0.3))
                            )
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(palette.border, lineWidth: 1)
                            )
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 8)
                            .animation(.spring(response: 0.46, dampingFraction: 0.8).delay(0.28 + Double(index) * 0.05), value: appeared)
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Onboarding") {
    OnboardingView(
        store: Store(initialState: OnboardingFeature.State()) {
            OnboardingFeature()
        },
        appTheme: .constant(.system)
    )
}
