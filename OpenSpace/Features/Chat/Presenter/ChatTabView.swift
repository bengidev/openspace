import ComposableArchitecture
import SwiftUI

struct ChatTabView: View {
    @Bindable var store: StoreOf<ChatTab>

    @Environment(\.palette) private var palette

    var body: some View {
        ZStack {
            palette.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { store.send(.sidebarToggleTapped) }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(palette.textPrimary)
                    }

                    Spacer()

                    if let conversation = store.conversationList.selectedConversation {
                        Text(conversation.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(palette.textPrimary)
                            .lineLimit(1)

                        Spacer()
                    } else {
                        Spacer()
                    }

                    if store.conversationList.selectedConversation != nil {
                        Button(action: { store.send(.newConversationTapped) }) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 20))
                                .foregroundStyle(palette.accent)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                if store.conversationList.selectedConversation == nil && store.messages.isEmpty {
                    WelcomeView(store: store)
                } else {
                    ChatThreadView(store: store)
                }

                InputComposerView(store: store)
            }

            if store.isSidebarVisible {
                HStack(spacing: 0) {
                    ChatSidebarView(store: store)
                        .frame(width: 300)
                        .background(palette.background)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 4, y: 0)

                    Spacer()
                }
                .transition(.move(edge: .leading))
                .zIndex(1)
            }
        }
        .animation(.default, value: store.isSidebarVisible)
        .onAppear {
            store.send(.conversationList(.onAppear))
        }
        .sheet(
            isPresented: Binding(
                get: { store.showSettings },
                set: { isPresented in
                    if !isPresented {
                        store.send(.dismissSettings)
                    }
                }
            )
        ) {
            SettingsTabView()
        }
    }
}

#Preview {
    ChatTabView(
        store: Store(initialState: ChatTab.State()) {
            ChatTab()
        }
    )
    .environment(\.palette, OpenSpacePalette.resolve(.dark))
}
