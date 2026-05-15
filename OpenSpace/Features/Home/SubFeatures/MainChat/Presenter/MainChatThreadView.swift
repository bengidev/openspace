import ComposableArchitecture
import SwiftUI
import Combine

struct MainChatThreadView: View {
    @Bindable var store: StoreOf<MainChat>

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                List {
                    ForEach(store.messages) { message in
                        MainChatMessageRow(message: message)
                            .id(message.id)
                    }
                    .listRowBackground(palette.background)
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .background(palette.background)
                .onChange(of: store.messages.count) { _, _ in
                    scrollToLast(proxy: proxy, animate: true)
                }
                .onChange(of: store.threadEngine.currentPartialText.count) { _, _ in
                    scrollToLast(proxy: proxy, animate: false)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { _ in
                    scrollToLast(proxy: proxy, animate: false)
                }
            }
        }
    }

    private func scrollToLast(proxy: ScrollViewProxy, animate: Bool) {
        if let lastId = store.messages.last?.id {
            if animate {
                withAnimation(.easeOut(duration: 0.15)) {
                    proxy.scrollTo(lastId, anchor: .bottom)
                }
            } else {
                proxy.scrollTo(lastId, anchor: .bottom)
            }
        }
    }
}

struct MainChatMessageRow: View {
    let message: ChatMessage

    @Environment(\.palette) private var palette

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                switch message {
                case let .text(textMessage):
                    Text(textMessage.content)
                        .font(
                            message.role == .assistant
                                ? .system(size: 15, weight: .regular, design: .monospaced)
                                : .system(size: 15, weight: .regular)
                        )
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
