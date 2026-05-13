import ComposableArchitecture
import SwiftUI
import UIKit

struct MainChatView: View {
    @Bindable var store: StoreOf<MainChat>
    let isSidebarVisible: Bool

    @Environment(\.palette) private var palette
    @FocusState private var isComposerFocused: Bool

    private let sidebarSwipeActivationWidth: CGFloat = 34
    private let sidebarSwipeThreshold: CGFloat = 64

    var body: some View {
        GeometryReader { proxy in
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
                        .accessibilityLabel("Show sidebar")

                        Spacer()

                        if let conversation = store.selectedConversation {
                            Text(conversation.title)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(palette.textPrimary)
                                .lineLimit(1)

                            Spacer()
                        } else {
                            Spacer()
                        }

                        if store.selectedConversation != nil {
                            Button(action: { store.send(.newConversationTapped) }) {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 20))
                                    .foregroundStyle(palette.accent)
                            }
                            .accessibilityLabel("New conversation")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        dismissComposerKeyboard()
                    }

                    if store.selectedConversation == nil && store.messages.isEmpty {
                        KeyboardAwareWelcomeContent(
                            store: store,
                            isComposerFocused: $isComposerFocused,
                            dismissKeyboard: dismissComposerKeyboard
                        )
                    } else {
                        MainChatThreadView(store: store)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                dismissComposerKeyboard()
                            }

                        MainChatComposerView(
                            store: store,
                            isComposerFocused: $isComposerFocused
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityHidden(isSidebarVisible)
            }
            .contentShape(Rectangle())
            .simultaneousGesture(sidebarSwipeGesture(in: proxy.size))
        }
    }

    private func dismissComposerKeyboard() {
        isComposerFocused = false
    }

    private func sidebarSwipeGesture(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 18, coordinateSpace: .local)
            .onEnded { value in
                let translation = value.translation
                let mostlyHorizontal = abs(translation.width) > abs(translation.height) * 1.4
                guard mostlyHorizontal else { return }

                if isSidebarVisible {
                    guard translation.width < -sidebarSwipeThreshold else { return }
                    store.send(.sidebarDismissed)
                    return
                }

                let startedAtLeadingEdge = value.startLocation.x <= sidebarSwipeActivationWidth
                guard startedAtLeadingEdge, translation.width > sidebarSwipeThreshold else { return }
                store.send(.sidebarToggleTapped)
            }
    }
}

private enum MainChatScrollAnchor: Hashable {
    case composer
}

private struct KeyboardAwareWelcomeContent: View {
    @Bindable var store: StoreOf<MainChat>
    let isComposerFocused: FocusState<Bool>.Binding
    let dismissKeyboard: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(spacing: 0) {
                        MainChatWelcomeView(store: store)
                            .frame(minHeight: welcomeMinHeight(for: proxy.size.height))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                dismissKeyboard()
                            }

                        MainChatComposerView(
                            store: store,
                            isComposerFocused: isComposerFocused
                        )
                        .id(MainChatScrollAnchor.composer)
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
                proxy.scrollTo(MainChatScrollAnchor.composer, anchor: .bottom)
            }
        }
    }
}

#Preview {
    MainChatView(
        store: Store(initialState: MainChat.State()) {
            MainChat()
        },
        isSidebarVisible: false
    )
    .environment(\.palette, OpenSpacePalette.resolve(.dark))
}
