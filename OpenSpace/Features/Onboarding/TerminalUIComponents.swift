import SwiftUI

// MARK: - Terminal Badge

struct TerminalBadge: View {
    let text: String

    @Environment(\.terminalColors) private var colors

    var body: some View {
        Text("[ \(text) ]")
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundStyle(colors.textDim)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(colors.divider.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(colors.divider.opacity(0.5), lineWidth: 1)
                    )
            )
    }
}

// MARK: - Status Dot

struct StatusDot: View {
    let label: String

    @Environment(\.terminalColors) private var colors
    @State private var pulse = false

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(colors.accent)
                .frame(width: 7, height: 7)
                .monochromeGlow(intensity: 0.6)
                .scaleEffect(pulse ? 1.3 : 1.0)
                .opacity(pulse ? 0.7 : 1.0)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)

            Text(label)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(colors.textDim)
        }
        .onAppear { pulse = true }
    }
}

// MARK: - Terminal Divider

struct TerminalDivider: View {
    @Environment(\.terminalColors) private var colors

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(colors.divider.opacity(0.5))
                .frame(height: 1)

            Text(" * ")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(colors.textFaint)

            Rectangle()
                .fill(colors.divider.opacity(0.5))
                .frame(height: 1)
        }
    }
}

// MARK: - Terminal Step Card

struct TerminalStepCard: View {
    let step: OnboardingStep
    let index: Int
    let visibleCount: Int
    let isActive: Bool

    @Environment(\.terminalColors) private var colors

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isActive ? colors.accent.opacity(0.1) : colors.backgroundElevated.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(isActive ? colors.accent.opacity(0.3) : colors.border.opacity(0.3), lineWidth: 1)
                    )

                Image(systemName: step.symbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isActive ? colors.accent : colors.textDim)
                    .monochromeGlow(intensity: isActive ? 0.4 : 0)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text(step.headline)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundStyle(isActive ? colors.textPrimary : colors.textDim)

                Text(step.body)
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundStyle(colors.textDim)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            if isActive {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(colors.textFaint)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(colors.backgroundElevated.opacity(isActive ? 0.7 : 0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(isActive ? colors.accent.opacity(0.4) : colors.border.opacity(0.4), lineWidth: 1)
                )
        )
        .opacity(index < visibleCount ? 1.0 : 0.0)
        .offset(y: index < visibleCount ? 0 : 6)
        .animation(.spring(response: 0.35, dampingFraction: 0.75).delay(Double(index) * 0.1), value: visibleCount)
    }
}

// MARK: - Terminal Progress Bar

struct TerminalProgressBar: View {
    let progress: Double

    @Environment(\.terminalColors) private var colors

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(colors.border.opacity(0.3))
                    .frame(height: 2)

                Rectangle()
                    .fill(colors.accent)
                    .frame(width: geometry.size.width * progress, height: 2)
                    .monochromeGlow(intensity: 0.5)
                    .animation(.easeInOut(duration: 0.4), value: progress)
            }
        }
        .frame(height: 2)
    }
}

// MARK: - Terminal Button

struct TerminalButton: View {
    let title: String
    let action: () -> Void

    @Environment(\.terminalColors) private var colors
    @State private var isHovered = false
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(colors.accentInverse)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(colors.accent)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(colors.accent.opacity(0.5), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .monochromeGlow(intensity: isHovered ? 0.5 : 0.2)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Terminal Phase Header

struct TerminalPhaseHeader: View {
    let phase: String

    @Environment(\.terminalColors) private var colors

    var body: some View {
        HStack(spacing: 6) {
            Rectangle()
                .fill(colors.accent)
                .frame(width: 3, height: 12)
                .monochromeGlow(intensity: 0.5)

            Text(phase)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(colors.textDim)
                .tracking(2)
        }
    }
}
