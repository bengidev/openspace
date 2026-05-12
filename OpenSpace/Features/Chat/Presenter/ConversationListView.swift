import ComposableArchitecture
import SwiftUI

struct ConversationListView: View {
    @Bindable var store: StoreOf<ConversationList>

    @Environment(\.palette) private var palette

    var body: some View {
        ZStack {
            palette.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("Conversations")
                        .font(.system(size: 28, weight: .regular))
                        .foregroundStyle(palette.textPrimary)
                        .tracking(-1.2)

                    Spacer()

                    Button(action: { store.send(.createConversationTapped) }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundStyle(palette.accent)
                            .font(.system(size: 20, weight: .semibold))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .frame(height: 60)

                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(palette.textMuted)
                        .font(.system(size: 15, weight: .regular))

                    TextField("Search", text: $store.searchQuery.sending(\.searchQueryChanged))
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(palette.textPrimary)

                    if !store.searchQuery.isEmpty {
                        Button(action: { store.send(.searchQueryChanged("")) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(palette.textMuted)
                                .font(.system(size: 18))
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(palette.surface.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(palette.border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                if store.conversations.isEmpty {
                    Spacer()

                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 48, weight: .light))
                            .foregroundStyle(palette.textMuted)

                        Text("No conversations yet")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(palette.textSecondary)

                        Text("Tap the pencil icon to start a new chat.")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(palette.textMuted)
                    }

                    Spacer()
                } else {
                    List {
                        ForEach(store.conversations) { conversation in
                            Button(action: { store.send(.conversationSelected(conversation)) }) {
                                ConversationRow(conversation: conversation)
                            }
                            .listRowBackground(palette.background)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let conversation = store.conversations[index]
                                store.send(.deleteConversationTapped(conversation.id))
                            }
                        }
                    }
                    .listStyle(.plain)
                    .background(palette.background)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

struct ConversationRow: View {
    let conversation: Conversation

    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(palette.surface.opacity(0.5))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "bubble.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(palette.textMuted)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(palette.textPrimary)
                    .lineLimit(1)

                Text(formattedDate(conversation.updatedAt))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(palette.textMuted)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(palette.textMuted)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(palette.backgroundSecondary)
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(palette.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    ConversationListView(
        store: Store(initialState: ConversationList.State()) {
            ConversationList()
        }
    )
    .environment(\.palette, OpenSpacePalette.resolve(.dark))
}
