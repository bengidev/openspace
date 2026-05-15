import SwiftUI

struct ThinkingIndicatorBubble: View {
    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: 8) {
            ThinkingDotMatrix()

            Text("Thinking")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(palette.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(palette.elevatedSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct ThinkingIndicatorRow: View {
    @Environment(\.palette) private var palette

    var body: some View {
        HStack {
            Spacer()
            ThinkingIndicatorBubble()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}

struct ThinkingDotMatrix: View {
    private let rows = 3
    private let cols = 3
    private let dotSize: CGFloat = 2.5
    private let gap: CGFloat = 2.5
    private let cycleDuration: Double = 1.7

    @Environment(\.palette) private var palette

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: false)) { timeline in
            let phase = (timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: cycleDuration)) / cycleDuration

            HStack(spacing: gap) {
                ForEach(0..<cols, id: \.self) { col in
                    VStack(spacing: gap) {
                        ForEach(0..<rows, id: \.self) { row in
                            let opacity = dotOpacity(row: row, col: col, phase: phase)
                            let isBright = opacity > 0.5

                            Circle()
                                .fill(palette.textMuted)
                                .frame(width: dotSize, height: dotSize)
                                .opacity(opacity)
                                .shadow(
                                    color: palette.textMuted.opacity(isBright ? 0.6 : 0),
                                    radius: isBright ? 3 : 0,
                                    x: 0,
                                    y: 0
                                )
                        }
                    }
                }
            }
        }
    }

    private func dotOpacity(row: Int, col: Int, phase: Double) -> Double {
        let baseOpacity = 0.08
        let strandOpacity = 1.0
        let nearStrandOpacity = 0.24

        let stepCount = 12.0
        let helixLoop = (2.0 * .pi) / (stepCount - 1)

        let diagonalAxis = Double(row + col)
        let phaseOffset = phase * stepCount * helixLoop + diagonalAxis * 0.82
        let strandPerpendicular = round(2.0 * sin(phaseOffset))
        let cellPerpendicular = Double(col - row)
        let distanceFromStrand = abs(cellPerpendicular - strandPerpendicular)

        if distanceFromStrand == 0 {
            return strandOpacity
        } else if distanceFromStrand == 1 {
            return nearStrandOpacity
        } else {
            return baseOpacity
        }
    }
}
