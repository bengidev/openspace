import SwiftUI

// MARK: - OnboardingView

struct OnboardingView: View {
    @State private var isComplete = false
    @State private var pulseScale = 1.0
    @State private var overrideColorScheme: ColorScheme?

    @Environment(\.colorScheme) private var systemColorScheme

    private var activeColorScheme: ColorScheme {
        overrideColorScheme ?? systemColorScheme
    }

    private var terminalColors: TerminalColorScheme {
        TerminalColorScheme(colorScheme: activeColorScheme)
    }

    var body: some View {
        ZStack {
            terminalColors.background
                .ignoresSafeArea()

            if isComplete {
                completionView
            } else {
                singleScreenContent
            }

            shaderOverlay
                .ignoresSafeArea()
                .allowsHitTesting(false)

            CRTNoiseOverlay(opacity: activeColorScheme == .dark ? 0.035 : 0.02)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .environment(\.terminalColors, terminalColors)
        .crtFlicker()
        .animation(.easeInOut(duration: 0.5), value: isComplete)
        .animation(.easeInOut(duration: 0.35), value: activeColorScheme)
    }

    // MARK: Shader Overlay

    @ViewBuilder
    private var shaderOverlay: some View {
        if #available(iOS 17.0, *) {
            TimelineView(.animation(minimumInterval: 0.033, paused: false)) { timeline in
                CRTScanlineOverlay(lineCount: 100, opacity: activeColorScheme == .dark ? 0.12 : 0.06)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .layerEffect(
                        ShaderLibrary.default.crtLayerEffect(
                            .float(timeline.date.timeIntervalSinceReferenceDate),
                            .float(activeColorScheme == .dark ? 0.35 : 0.2),
                            .float(0.08),
                            .float(activeColorScheme == .dark ? 0.008 : 0.004),
                            .float(activeColorScheme == .dark ? 1.2 : 0.6),
                            .float(activeColorScheme == .dark ? 0.04 : 0.02)
                        ),
                        maxSampleOffset: CGSize(width: 20, height: 20),
                        isEnabled: true
                    )
            }
        } else {
            CRTScanlineOverlay(lineCount: 100, opacity: 0.12)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            CRTVignetteOverlay()
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
    }

    // MARK: Single Screen Content

    private var singleScreenContent: some View {
        VStack(spacing: 0) {
            topBar

            OnboardingContentView(
                steps: OnboardingStep.allSteps,
                onComplete: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isComplete = true
                    }
                }
            )
        }
    }

    // MARK: Top Bar

    private var topBar: some View {
        HStack {
            HStack(spacing: 4) {
                TerminalPrompt()

                TerminalCursor()

                GlitchText(text: "OPENSPACE", fontSize: 13, weight: .semibold, glitchIntensity: 1.0, tracking: 3)
            }

            Spacer()

            HStack(spacing: 12) {
                themeToggleButton

                StatusDot(label: "ONLINE")

                Text("v1.0.0")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(terminalColors.textFaint)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(
            Rectangle()
                .fill(terminalColors.background.opacity(0.8))
                .overlay(
                    Rectangle()
                        .fill(terminalColors.border.opacity(0.3))
                        .frame(height: 1),
                    alignment: .bottom
                )
        )
    }

    // MARK: Theme Toggle

    private var themeToggleButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                if let override = overrideColorScheme {
                    overrideColorScheme = override == .dark ? .light : .dark
                } else {
                    overrideColorScheme = systemColorScheme == .dark ? .light : .dark
                }
            }
        } label: {
            Image(systemName: activeColorScheme == .dark ? "sun.max.fill" : "moon.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(terminalColors.textDim)
                .monochromeGlow(intensity: 0.3)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(terminalColors.backgroundElevated.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(terminalColors.border.opacity(0.4), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: Completion View

    private var completionView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64, weight: .bold))
                .foregroundStyle(terminalColors.accent)
                .monochromeGlow(intensity: 0.6)
                .scaleEffect(pulseScale)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        pulseScale = 1.08
                    }
                }

            VStack(spacing: 8) {
                Text("All Set")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundStyle(terminalColors.textPrimary)
                    .monochromeGlow(intensity: 0.3)

                Text("Your workspace is ready. Let's get to work.")
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .foregroundStyle(terminalColors.textDim)
                    .multilineTextAlignment(.center)
            }

            TerminalButton(title: "Enter Workspace") {
                // Transition to main app - will be handled by parent
            }
            .padding(.top, 16)

            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Preview

#Preview("Dark") {
    OnboardingView()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    OnboardingView()
        .preferredColorScheme(.light)
}
