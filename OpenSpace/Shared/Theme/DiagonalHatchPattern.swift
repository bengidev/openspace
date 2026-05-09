import SwiftUI

struct DiagonalHatchPattern: View {
    let palette: OpenSpacePalette
    var spacing: CGFloat = 10
    var opacity = 0.025

    var body: some View {
        Canvas { context, size in
            for x in stride(from: -size.height, through: size.width, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: size.height))
                path.addLine(to: CGPoint(x: x + size.height, y: 0))
                context.stroke(path, with: .color(palette.textPrimary.opacity(opacity)), lineWidth: 1)
            }
        }
        .allowsHitTesting(false)
    }
}
