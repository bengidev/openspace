import ComposableArchitecture
import SwiftUI

struct ChatSidebarView: View {
    @Bindable var store: StoreOf<ChatTab>

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(palette.accent)

                Text("OpenSpace")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)

                Spacer()

                Button(action: { store.send(.sidebarDismissed) }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(palette.textMuted)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(palette.textMuted)
                    .font(.system(size: 15))

                TextField(
                    "Search conversations",
                    text: Binding(
                        get: { store.conversationList.searchQuery },
                        set: { store.send(.conversationList(.searchQueryChanged($0))) }
                    )
                )
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(palette.textPrimary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(palette.surface.opacity(0.5))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(palette.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.bottom, 12)

            Button(action: { store.send(.newConversationTapped) }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("New Chat")
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(palette.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(palette.elevatedSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(palette.border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)

            List {
                ForEach(store.conversationList.conversations) { conversation in
                    Button(action: {
                        store.send(.conversationList(.conversationSelected(conversation)))
                    }) {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(palette.surface.opacity(0.5))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(systemName: "bubble.left")
                                        .font(.system(size: 16))
                                        .foregroundStyle(palette.textMuted)
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(conversation.title)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(palette.textPrimary)
                                    .lineLimit(1)

                                Text(formattedDate(conversation.updatedAt))
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundStyle(palette.textMuted)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(
                        store.conversationList.selectedConversation?.id == conversation.id
                            ? palette.accent.opacity(0.15)
                            : palette.background
                    )
                    .listRowSeparator(.hidden)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let conversation = store.conversationList.conversations[index]
                        store.send(.conversationList(.deleteConversationTapped(conversation.id)))
                    }
                }
            }
            .listStyle(.plain)
            .background(palette.background)

            Spacer()

            Button(action: { store.send(.settingsTapped) }) {
                HStack(spacing: 12) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18))
                        .foregroundStyle(palette.textMuted)

                    Text("Settings")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(palette.textPrimary)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
        .background(palette.background)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
