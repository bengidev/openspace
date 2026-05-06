import Combine
import SwiftUI

// MARK: - Monochrome Glow Modifier

struct MonochromeGlow: ViewModifier {
    let intensity: Double

    func body(content: Content) -> some View {
        content
            .shadow(color: Color.white.opacity(0.5 * intensity), radius: 2, x: 0, y: 0)
            .shadow(color: Color.white.opacity(0.25 * intensity), radius: 6, x: 0, y: 0)
            .shadow(color: Color.white.opacity(0.1 * intensity), radius: 12, x: 0, y: 0)
    }
}

extension View {
    func monochromeGlow(intensity: Double = 1.0) -> some View {
        modifier(MonochromeGlow(intensity: intensity))
    }
}

// MARK: - CRT Scanline Overlay

struct CRTScanlineOverlay: View {
    let lineCount: Int
    let opacity: Double

    init(lineCount: Int = 120, opacity: Double = 0.18) {
        self.lineCount = lineCount
        self.opacity = opacity
    }

    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let lineHeight = height / CGFloat(lineCount)

            VStack(spacing: 0) {
                ForEach(0 ..< lineCount, id: \.self) { index in
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: lineHeight * 0.5)
                        .opacity(index % 2 == 0 ? opacity : opacity * 0.3)
                    if index < lineCount - 1 {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: lineHeight * 0.5)
                    }
                }
            }
            .allowsHitTesting(false)
        }
    }
}

// MARK: - CRT Vignette Overlay

struct CRTVignetteOverlay: View {
    @Environment(\.terminalColors) private var colors

    var body: some View {
        GeometryReader { geometry in
            RadialGradient(
                colors: [
                    Color.clear,
                    colors.vignetteColor,
                ],
                center: .center,
                startRadius: geometry.size.width * 0.35,
                endRadius: geometry.size.width * 0.75
            )
            .allowsHitTesting(false)
        }
    }
}

// MARK: - Grid Background

struct TerminalGridBackground: View {
    let spacing: CGFloat

    init(spacing: CGFloat = 40) {
        self.spacing = spacing
    }

    @Environment(\.terminalColors) private var colors

    var body: some View {
        GeometryReader { geometry in
            let cols = Int(geometry.size.width / spacing) + 1
            let rows = Int(geometry.size.height / spacing) + 1

            Canvas { context, _ in
                for col in 0 ..< cols {
                    let x = CGFloat(col) * spacing
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                    context.stroke(
                        path,
                        with: .color(colors.gridLine.opacity(0.15)),
                        lineWidth: 0.5
                    )
                }

                for row in 0 ..< rows {
                    let y = CGFloat(row) * spacing
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    context.stroke(
                        path,
                        with: .color(colors.gridLine.opacity(0.15)),
                        lineWidth: 0.5
                    )
                }
            }
            .allowsHitTesting(false)
        }
    }
}

// MARK: - CRT Noise Overlay

struct CRTNoiseOverlay: View {
    let opacity: Double

    init(opacity: Double = 0.04) {
        self.opacity = opacity
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.05, paused: false)) { _ in
            Canvas { context, size in
                let pixelSize: CGFloat = 2
                let cols = Int(size.width / pixelSize) + 1
                let rows = Int(size.height / pixelSize) + 1

                for row in 0 ..< rows {
                    for col in 0 ..< cols {
                        if Double.random(in: 0 ... 1) < 0.08 {
                            let rect = CGRect(
                                x: CGFloat(col) * pixelSize,
                                y: CGFloat(row) * pixelSize,
                                width: pixelSize,
                                height: pixelSize
                            )
                            context.fill(
                                Path(rect),
                                with: .color(
                                    Color.white.opacity(Double.random(in: 0.1 ... 0.35))
                                )
                            )
                        }
                    }
                }
            }
            .opacity(opacity)
            .allowsHitTesting(false)
        }
    }
}

// MARK: - CRT Flicker Modifier

struct CRTFlicker: ViewModifier {
    @State private var flickerOpacity = 1.0

    func body(content: Content) -> some View {
        content
            .opacity(flickerOpacity)
            .onAppear {
                startFlicker()
            }
    }

    private func startFlicker() {
        Task { @MainActor in
            while !Task.isCancelled {
                let delay = Double.random(in: 3.0 ... 8.0)
                try? await Task.sleep(for: .seconds(delay))

                withAnimation(.linear(duration: 0.02)) {
                    flickerOpacity = Double.random(in: 0.92 ... 0.98)
                }

                try? await Task.sleep(for: .seconds(0.04))

                withAnimation(.linear(duration: 0.02)) {
                    flickerOpacity = 1.0
                }
            }
        }
    }
}

extension View {
    func crtFlicker() -> some View {
        modifier(CRTFlicker())
    }
}

// MARK: - Typing Text Effect

struct TerminalTypingText: View {
    let text: String
    let typingInterval: TimeInterval
    let fontSize: CGFloat
    let weight: Font.Weight
    let glitchEnabled: Bool
    let onComplete: (() -> Void)?

    @Environment(\.terminalColors) private var colors
    @State private var displayedCharacters = 0
    @State private var timerCancellable: AnyCancellable?

    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    @State private var glitchOpacity: Double = 0

    init(
        text: String,
        typingInterval: TimeInterval = 0.025,
        fontSize: CGFloat = 13,
        weight: Font.Weight = .medium,
        glitchEnabled: Bool = false,
        onComplete: (() -> Void)? = nil
    ) {
        self.text = text
        self.typingInterval = typingInterval
        self.fontSize = fontSize
        self.weight = weight
        self.glitchEnabled = glitchEnabled
        self.onComplete = onComplete
    }

    var body: some View {
        let displayedText = String(text.prefix(displayedCharacters))

        if glitchEnabled {
            ZStack {
                Text(displayedText)
                    .font(.system(size: fontSize, weight: weight, design: .monospaced))
                    .foregroundStyle(colors.textPrimary)
                    .monochromeGlow(intensity: 0.5)
                    .offset(x: offsetX, y: offsetY)

                Text(displayedText)
                    .font(.system(size: fontSize, weight: weight, design: .monospaced))
                    .foregroundStyle(colors.textPrimary)
                    .opacity(glitchOpacity * 0.4)
                    .offset(x: -offsetX * 1.5, y: offsetY * 0.5)
                    .blendMode(.difference)

                Text(displayedText)
                    .font(.system(size: fontSize, weight: weight, design: .monospaced))
                    .foregroundStyle(colors.textDim)
                    .opacity(glitchOpacity * 0.4)
                    .offset(x: offsetX * 1.2, y: -offsetY)
                    .blendMode(.difference)
            }
            .onAppear {
                startTyping()
                startGlitchLoop()
            }
            .onDisappear {
                timerCancellable?.cancel()
            }
            .onChange(of: text) { _, _ in
                displayedCharacters = 0
                startTyping()
            }
        } else {
            Text(displayedText)
                .font(.system(size: fontSize, weight: weight, design: .monospaced))
                .onAppear {
                    startTyping()
                }
                .onDisappear {
                    timerCancellable?.cancel()
                }
                .onChange(of: text) { _, _ in
                    displayedCharacters = 0
                    startTyping()
                }
        }
    }

    private func startTyping() {
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: typingInterval, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if displayedCharacters < text.count {
                    displayedCharacters += 1
                } else {
                    timerCancellable?.cancel()
                    onComplete?()
                }
            }
    }

    @MainActor
    private func startGlitchLoop() {
        Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(Double.random(in: 2.0 ... 5.0)))
                triggerGlitch()
            }
        }
    }

    private func triggerGlitch() {
        withAnimation(.linear(duration: 0.05)) {
            offsetX = CGFloat.random(in: -3 ... 3)
            offsetY = CGFloat.random(in: -1 ... 1)
            glitchOpacity = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.linear(duration: 0.05)) {
                offsetX = CGFloat.random(in: -4 ... 4)
                offsetY = CGFloat.random(in: -2 ... 2)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.linear(duration: 0.05)) {
                offsetX = 0
                offsetY = 0
                glitchOpacity = 0
            }
        }
    }
}

// MARK: - Blinking Cursor

struct BlinkingCursor: View {
    @Environment(\.terminalColors) private var colors

    @State private var isVisible = true

    var body: some View {
        Rectangle()
            .fill(colors.accent)
            .frame(width: 8, height: 16)
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isVisible)
            .onAppear { isVisible.toggle() }
    }
}

// MARK: - Glitch Text Effect (Monochrome)

struct GlitchText: View {
    let text: String
    var fontSize: CGFloat = 28
    var weight: Font.Weight = .bold
    var glitchIntensity: CGFloat = 1.0
    var tracking: CGFloat = 0

    @Environment(\.terminalColors) private var colors
    @State private var shift: CGFloat = 0
    @State private var isGlitching = false

    var body: some View {
        ZStack(alignment: .leading) {
            Text(text)
                .font(.system(size: fontSize, weight: weight, design: .monospaced))
                .foregroundStyle(colors.textPrimary)
                .tracking(tracking)
                .offset(x: shift, y: 0)

            Text(text)
                .font(.system(size: fontSize, weight: weight, design: .monospaced))
                .foregroundStyle(Color.gray)
                .tracking(tracking)
                .opacity(isGlitching ? 0.7 : 0.35)
                .offset(x: 4 * glitchIntensity + shift, y: 1)

            Text(text)
                .font(.system(size: fontSize, weight: weight, design: .monospaced))
                .foregroundStyle(Color.black.opacity(0.6))
                .tracking(tracking)
                .opacity(isGlitching ? 0.6 : 0.25)
                .offset(x: -3 * glitchIntensity + shift, y: -1)
        }
        .fixedSize(horizontal: true, vertical: true)
        .onAppear {
            startGlitchLoop()
        }
    }

    @MainActor
    private func startGlitchLoop() {
        Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(Double.random(in: 0.5 ... 1.5)))
                triggerGlitch()
            }
        }
    }

    private func triggerGlitch() {
        withAnimation(.linear(duration: 0.05)) {
            shift = CGFloat.random(in: -2 ... 2) * glitchIntensity
            isGlitching = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.linear(duration: 0.05)) {
                shift = CGFloat.random(in: -3 ... 3) * glitchIntensity
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.linear(duration: 0.1)) {
                shift = 0
                isGlitching = false
            }
        }
    }
}

// MARK: - Terminal Prompt

struct TerminalPrompt: View {
    @Environment(\.terminalColors) private var colors
    @State private var visibleCount = 0

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { index in
                Text(">")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(colors.textPrimary)
                    .monochromeGlow(intensity: 0.4)
                    .opacity(visibleCount > index ? 1 : 0)
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        Task {
            while !Task.isCancelled {
                for i in 1...3 {
                    visibleCount = i
                    try? await Task.sleep(for: .seconds(0.12))
                }
                try? await Task.sleep(for: .seconds(0.35))
                for i in (0...2).reversed() {
                    visibleCount = i
                    try? await Task.sleep(for: .seconds(0.12))
                }
                try? await Task.sleep(for: .seconds(0.25))
            }
        }
    }
}

// MARK: - Terminal Cursor

struct TerminalCursor: View {
    @Environment(\.terminalColors) private var colors
    @State private var isVisible = true

    var body: some View {
        Rectangle()
            .fill(colors.textPrimary)
            .frame(width: 6, height: 20)
            .opacity(isVisible ? 1 : 0)
            .animation(.easeInOut(duration: 0.1), value: isVisible)
            .onAppear {
                Task { @MainActor in
                    while !Task.isCancelled {
                        try? await Task.sleep(for: .seconds(0.53))
                        isVisible.toggle()
                    }
                }
            }
    }
}
