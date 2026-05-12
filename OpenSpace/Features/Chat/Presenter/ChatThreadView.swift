import ComposableArchitecture
import SwiftUI

struct ChatThreadView: View {
    @Bindable var store: StoreOf<ChatTab>

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(store.messages) { message in
                    MessageRow(message: message)
                }
                .listRowBackground(palette.background)
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .background(palette.background)
        }
    }
}

struct MessageRow: View {
    let message: Message

    @Environment(\.palette) private var palette

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                switch message {
                case let .text(textMsg):
                    Text(textMsg.content)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(message.role == .user ? palette.primaryActionText : palette.textPrimary)
                default:
                    Text("Unsupported message type")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(palette.textMuted)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(message.role == .user ? palette.primaryActionFill : palette.elevatedSurface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            if message.role == .assistant {
                Spacer()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}
