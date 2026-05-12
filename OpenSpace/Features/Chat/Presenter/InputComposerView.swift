import ComposableArchitecture
import SwiftUI

struct InputComposerView: View {
    @Bindable var store: StoreOf<ChatTab>

    @Environment(\.palette) private var palette
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                TextField("Ask anything...", text: Binding(
                    get: { store.draftMessage },
                    set: { store.send(.draftMessageChanged($0)) }
                ), axis: .vertical)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(palette.textPrimary)
                    .lineLimit(1...6)
                    .focused($isFocused)

                Button(action: { store.send(.sendMessageTapped) }) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(store.draftMessage.isEmpty ? palette.textMuted : palette.primaryActionText)
                        .frame(width: 32, height: 32)
                        .background(store.draftMessage.isEmpty ? palette.surface : palette.primaryActionFill)
                        .clipShape(Circle())
                }
                .disabled(store.draftMessage.isEmpty || store.isSending)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(palette.elevatedSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(palette.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 16)

            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 14))
                        .foregroundStyle(palette.textMuted)

                    let modelName = store.conversationList.selectedConversation?.modelID ?? "Default Model"
                    Text(modelName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(palette.textSecondary)
                }

                Spacer()

                Image(systemName: "mic")
                    .font(.system(size: 16))
                    .foregroundStyle(palette.textMuted)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .background(palette.background)
    }
}
