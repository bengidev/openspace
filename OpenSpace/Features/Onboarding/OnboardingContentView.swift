import SwiftUI

// MARK: - OnboardingContentView

struct OnboardingContentView: View {
    let steps: [OnboardingStep]
    let onComplete: () -> Void

    @Environment(\.terminalColors) private var colors
    @State private var currentStep = 0
    @State private var showTitle = false
    @State private var showAction = false
    @State private var hasCompleted = false

    var body: some View {
        ZStack {
            TerminalGridBackground(spacing: 40)
                .opacity(0.4)

            VStack(alignment: .leading, spacing: 0) {
                headerSection
                    .padding(.horizontal, 24)
                    .padding(.top, 10)

                stepSection
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                actionSection
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                Spacer(minLength: 0)
            }
        }
        .onAppear {
            startAnimationSequence()
        }
    }

    // MARK: Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your AI Workspace")
                .font(.system(size: 30, weight: .bold, design: .monospaced))
                .foregroundStyle(colors.textPrimary)
                .minimumScaleFactor(0.9)
                .opacity(showTitle ? 1 : 0)
                .offset(y: showTitle ? 0 : 8)
                .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.2), value: showTitle)

            Text("Chat, create, and organize \u{2014} all in one place.")
                .font(.system(size: 16, weight: .regular, design: .monospaced))
                .foregroundStyle(colors.textDim)
                .minimumScaleFactor(0.9)
                .opacity(showTitle ? 1 : 0)
                .offset(y: showTitle ? 0 : 6)
                .animation(.easeOut(duration: 0.35).delay(0.25), value: showTitle)

            TerminalDivider()
                .padding(.top, 2)
        }
    }

    private var stepSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("GETTING STARTED")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(colors.textFaint)

                Spacer()

                HStack(spacing: 4) {
                    Text(String(format: "%02d", currentStep + 1))
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(colors.accent)

                    Text("/")
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .foregroundStyle(colors.textFaint)

                    Text(String(format: "%02d", steps.count))
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(colors.textFaint)
                }
            }
            .padding(.bottom, 16)

            if currentStep < steps.count {
                let step = steps[currentStep]

                Group {
                    switch step.pageType {
                    case .welcome:
                        WelcomePageView(step: step)
                    case .chat:
                        ChatPageView(step: step)
                    case .organize:
                        OrganizePageView(step: step)
                    case .ready:
                        ReadyPageView(step: step)
                    }
                }
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    )
                )
                .id(step.id)
            }
        }
    }

    private var actionSection: some View {
        HStack {
            Spacer()

            VStack(spacing: 24) {
                // Pagination dots — above button with space
                HStack(spacing: 8) {
                    ForEach(0 ..< steps.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentStep ? colors.accent : colors.border)
                            .frame(
                                width: index == currentStep ? 20 : 8,
                                height: 8
                            )
                            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentStep)
                    }
                }
                .opacity(showAction ? 1 : 0)

                if hasCompleted {
                    TerminalButton(title: "Get Started") {
                        onComplete()
                    }
                    .opacity(showAction ? 1 : 0)
                    .offset(y: showAction ? 0 : 12)
                    .animation(.spring(response: 0.4, dampingFraction: 0.75).delay(0.1), value: showAction)
                } else {
                    TerminalButton(title: "Continue") {
                        advanceStep()
                    }
                    .opacity(showAction ? 1 : 0)
                    .offset(y: showAction ? 0 : 12)
                    .animation(.spring(response: 0.4, dampingFraction: 0.75).delay(0.1), value: showAction)
                }
            }

            Spacer()
        }
    }

    // MARK: Animation

    private func startAnimationSequence() {
        showTitle = false
        currentStep = 0
        showAction = false
        hasCompleted = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            showTitle = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            showAction = true
        }
    }

    private func advanceStep() {
        if currentStep < steps.count - 1 {
            withAnimation(.easeInOut(duration: 0.35)) {
                currentStep += 1
            }
        } else {
            hasCompleted = true
        }
    }
}

// MARK: - Welcome Page

struct WelcomePageView: View {
    let step: OnboardingStep

    @Environment(\.terminalColors) private var colors
    @State private var appear = false

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                colors.accent.opacity(0.12),
                                colors.accent.opacity(0.03),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(colors.accent.opacity(0.25), lineWidth: 1)
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: step.symbol)
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(colors.accent)
                    .monochromeGlow(intensity: 0.5)
                    .scaleEffect(appear ? 1 : 0.5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: appear)
            }
            .frame(height: 100)

            VStack(spacing: 8) {
                Text(step.headline)
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundStyle(colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 6)
                    .animation(.spring(response: 0.4, dampingFraction: 0.75).delay(0.2), value: appear)

                Text(step.body)
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .foregroundStyle(colors.textDim)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 4)
                    .animation(.spring(response: 0.4, dampingFraction: 0.75).delay(0.3), value: appear)
            }
            .padding(.horizontal, 8)

            HStack(spacing: 8) {
                ForEach(Array(step.features.enumerated()), id: \.element) { index, feature in
                    Text(feature)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(colors.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(colors.accent.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .stroke(colors.accent.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 8)
                        .scaleEffect(appear ? 1 : 0.8)
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.7).delay(0.35 + Double(index) * 0.08),
                            value: appear
                        )
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(colors.backgroundElevated.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(colors.border.opacity(0.4), lineWidth: 1)
                )
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                appear = true
            }
        }
        .onDisappear {
            appear = false
        }
    }
}

// MARK: - Chat Page

struct ChatPageView: View {
    let step: OnboardingStep

    @Environment(\.terminalColors) private var colors
    @State private var showBubbles = false

    let messages = [
        (text: "How do I optimize this Swift code?", isUser: true, delay: 0.0),
        (text: "Here are 3 ways to improve performance...", isUser: false, delay: 0.15),
        (text: "Can you explain the memory layout?", isUser: true, delay: 0.3),
    ]

    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 10) {
                ForEach(Array(messages.enumerated()), id: \.offset) { index, message in
                    chatBubble(
                        text: message.text,
                        isUser: message.isUser,
                        index: index
                    )
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(colors.background.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(colors.border.opacity(0.3), lineWidth: 1)
                    )
            )

            VStack(spacing: 6) {
                Text(step.headline)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundStyle(colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(step.body)
                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                    .foregroundStyle(colors.textDim)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(.horizontal, 8)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(colors.backgroundElevated.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(colors.border.opacity(0.4), lineWidth: 1)
                )
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showBubbles = true
            }
        }
        .onDisappear {
            showBubbles = false
        }
    }

    private func chatBubble(text: String, isUser: Bool, index: Int) -> some View {
        HStack {
            if isUser { Spacer(minLength: 40) }

            Text(text)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(isUser ? colors.accentInverse : colors.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isUser ? colors.accent : colors.backgroundElevated.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(isUser ? colors.accent.opacity(0.5) : colors.border.opacity(0.3), lineWidth: 1)
                        )
                )
                .opacity(showBubbles ? 1 : 0)
                .offset(y: showBubbles ? 0 : 12)
                .scaleEffect(showBubbles ? 1 : 0.9)
                .animation(
                    .spring(response: 0.45, dampingFraction: 0.75).delay(Double(index) * 0.12),
                    value: showBubbles
                )

            if !isUser { Spacer(minLength: 40) }
        }
    }
}

// MARK: - Organize Page

struct OrganizePageView: View {
    let step: OnboardingStep

    @Environment(\.terminalColors) private var colors
    @State private var showItems = false

    let files = [
        (name: "Projects", type: "FOLDER", icon: "folder.fill"),
        (name: "Notes", type: "FOLDER", icon: "folder.fill"),
        (name: "Report", type: "PDF", icon: "doc.text.fill"),
        (name: "Design", type: "PNG", icon: "photo.fill"),
        (name: "Code", type: "SWIFT", icon: "chevron.left.forwardslash.chevron.right"),
        (name: "Draft", type: "MD", icon: "doc.plaintext.fill"),
    ]

    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    fileItem(file: files[0], index: 0)
                    fileItem(file: files[1], index: 1)
                }

                HStack(spacing: 6) {
                    fileItem(file: files[2], index: 2)
                    fileItem(file: files[3], index: 3)
                }

                HStack(spacing: 6) {
                    fileItem(file: files[4], index: 4)
                    fileItem(file: files[5], index: 5)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(colors.background.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(colors.border.opacity(0.3), lineWidth: 1)
                    )
            )

            VStack(spacing: 6) {
                Text(step.headline)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundStyle(colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(step.body)
                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                    .foregroundStyle(colors.textDim)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(.horizontal, 8)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(colors.backgroundElevated.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(colors.border.opacity(0.4), lineWidth: 1)
                )
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                showItems = true
            }
        }
        .onDisappear {
            showItems = false
        }
    }

    private func fileItem(file: (name: String, type: String, icon: String), index: Int) -> some View {
        HStack(spacing: 8) {
            Image(systemName: file.icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(colors.accent)
                .frame(width: 26, height: 26)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(colors.accent.opacity(0.08))
                )

            VStack(alignment: .leading, spacing: 1) {
                Text(file.name)
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(colors.textPrimary)

                Text(file.type)
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundStyle(colors.textFaint)
            }

            Spacer()
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(colors.backgroundElevated.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(colors.border.opacity(0.3), lineWidth: 1)
                )
        )
        .opacity(showItems ? 1 : 0)
        .offset(y: showItems ? 0 : 10)
        .scaleEffect(showItems ? 1 : 0.92)
        .animation(
            .spring(response: 0.4, dampingFraction: 0.75).delay(Double(index) * 0.06),
            value: showItems
        )
    }
}

// MARK: - Ready Page

struct ReadyPageView: View {
    let step: OnboardingStep

    @Environment(\.terminalColors) private var colors
    @State private var checkedItems = Set<Int>()
    @State private var appear = false

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                colors.accent.opacity(0.12),
                                colors.accent.opacity(0.03),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(colors.accent.opacity(0.25), lineWidth: 1)
                    )
                    .frame(width: 90, height: 90)

                Image(systemName: step.symbol)
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(colors.accent)
                    .monochromeGlow(intensity: 0.5)
                    .scaleEffect(appear ? 1 : 0.5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: appear)
            }
            .frame(height: 90)

            VStack(spacing: 6) {
                Text(step.headline)
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundStyle(colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(step.body)
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .foregroundStyle(colors.textDim)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 8)

            VStack(spacing: 6) {
                ForEach(Array(step.features.enumerated()), id: \.element) { index, feature in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(checkedItems.contains(index) ? colors.accent : colors.backgroundElevated.opacity(0.5))
                                .frame(width: 22, height: 22)
                                .overlay(
                                    Circle()
                                        .stroke(checkedItems.contains(index) ? colors.accent : colors.border.opacity(0.5), lineWidth: 1.5)
                                )

                            if checkedItems.contains(index) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(colors.accentInverse)
                                    .scaleEffect(checkedItems.contains(index) ? 1 : 0)
                                    .animation(.spring(response: 0.35, dampingFraction: 0.6), value: checkedItems)
                            }
                        }

                        Text(feature)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundStyle(checkedItems.contains(index) ? colors.textPrimary : colors.textDim)

                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(checkedItems.contains(index) ? colors.accent.opacity(0.06) : colors.background.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(checkedItems.contains(index) ? colors.accent.opacity(0.2) : colors.border.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 8)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.75).delay(0.2 + Double(index) * 0.1),
                        value: appear
                    )
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(index) * 0.25) {
                            checkedItems.insert(index)
                        }
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(colors.backgroundElevated.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(colors.border.opacity(0.4), lineWidth: 1)
                )
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                appear = true
            }
        }
        .onDisappear {
            appear = false
            checkedItems.removeAll()
        }
    }
}
