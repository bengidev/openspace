import SwiftUI

// MARK: - Attachment File

struct AttachmentFile: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let size: String
    let symbol: String
}

// MARK: - Attachment Preview

struct AttachmentPreview: View {
    let files: [AttachmentFile]
    let visibleCount: Int

    @Environment(\.terminalColors) private var colors

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("ATTACHMENTS")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(colors.textFaint)

                Spacer()

                Text("\(visibleCount) FILES")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(colors.textDim)
            }
            .padding(.bottom, 10)

            HStack(spacing: 10) {
                ForEach(Array(files.enumerated()), id: \.element.id) { index, file in
                    AttachmentCard(
                        file: file,
                        index: index,
                        visibleCount: visibleCount
                    )
                }
            }
        }
    }
}

// MARK: - Attachment Card

struct AttachmentCard: View {
    let file: AttachmentFile
    let index: Int
    let visibleCount: Int

    @Environment(\.terminalColors) private var colors
    @State private var isPressed = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(colors.backgroundElevated.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(colors.border.opacity(0.5), lineWidth: 1)
                )

            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(colors.backgroundElevated.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(colors.border.opacity(0.5), lineWidth: 1)
                        )

                    Image(systemName: file.symbol)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(colors.textPrimary)
                }
                .frame(width: 44, height: 44)

                VStack(spacing: 2) {
                    Text(file.name)
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(colors.textPrimary)
                        .lineLimit(1)

                    Text(file.type)
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(colors.textDim)

                    Text(file.size)
                        .font(.system(size: 9, weight: .regular, design: .monospaced))
                        .foregroundStyle(colors.textFaint)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .opacity(index < visibleCount ? 1.0 : 0.0)
        .offset(y: index < visibleCount ? 0 : 6)
        .animation(.spring(response: 0.35, dampingFraction: 0.75).delay(Double(index) * 0.08), value: visibleCount)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeInOut(duration: 0.05)) {
                    isPressed = false
                }
            }
        }
    }
}

// MARK: - Default Attachment Data

extension AttachmentFile {
    static let demoFiles: [AttachmentFile] = [
        AttachmentFile(name: "Report", type: "PDF", size: "2.4 MB", symbol: "doc.text"),
        AttachmentFile(name: "Design", type: "PNG", size: "1.8 MB", symbol: "photo"),
        AttachmentFile(name: "Notes", type: "MD", size: "12 KB", symbol: "doc.plaintext"),
    ]
}
