import ComposableArchitecture
import SwiftUI

struct ChatTabView: View {
    @Bindable var store: StoreOf<ChatTab>

    @Environment(\.palette) private var palette
    @FocusState private var isComposerFocused: Bool

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
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissComposerKeyboard()
                }

                if store.conversationList.selectedConversation == nil && store.messages.isEmpty {
                    KeyboardAwareWelcomeContent(
                        store: store,
                        isComposerFocused: $isComposerFocused,
                        dismissKeyboard: dismissComposerKeyboard
                    )
                } else {
                    ChatThreadView(store: store)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            dismissComposerKeyboard()
                        }

                    InputComposerView(
                        store: store,
                        isComposerFocused: $isComposerFocused
                    )
                }
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

    private func dismissComposerKeyboard() {
        isComposerFocused = false
    }
}

private enum ChatScrollAnchor: Hashable {
    case composer
}

private struct KeyboardAwareWelcomeContent: View {
    @Bindable var store: StoreOf<ChatTab>
    let isComposerFocused: FocusState<Bool>.Binding
    let dismissKeyboard: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(spacing: 0) {
                        WelcomeView(store: store)
                            .frame(minHeight: welcomeMinHeight(for: proxy.size.height))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                dismissKeyboard()
                            }

                        InputComposerView(
                            store: store,
                            isComposerFocused: isComposerFocused
                        )
                        .id(ChatScrollAnchor.composer)
                    }
                    .frame(maxWidth: .infinity)
                }
                .scrollDismissesKeyboard(.interactively)
                .scrollDisabled(!isComposerFocused.wrappedValue)
                .scrollIndicators(isComposerFocused.wrappedValue ? .visible : .hidden)
                .onChange(of: isComposerFocused.wrappedValue) { _, isFocused in
                    guard isFocused else { return }
                    scrollComposerIntoView(with: scrollProxy)
                }
            }
        }
    }

    private func welcomeMinHeight(for availableHeight: CGFloat) -> CGFloat {
        max(availableHeight - 170, 420)
    }

    private func scrollComposerIntoView(with proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.easeOut(duration: 0.22)) {
                proxy.scrollTo(ChatScrollAnchor.composer, anchor: .bottom)
            }
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
