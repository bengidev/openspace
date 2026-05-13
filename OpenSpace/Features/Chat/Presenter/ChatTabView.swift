import ComposableArchitecture
import SwiftUI
import UIKit

struct ChatTabView: View {
    @Bindable var store: StoreOf<ChatTab>

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
                            .accessibilityLabel("New conversation")
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityHidden(store.isSidebarVisible)

                ChatSidebarOverlay(
                    store: store,
                    width: sidebarWidth(for: proxy.size.width),
                    isVisible: store.isSidebarVisible
                )
                .zIndex(1)
                .ignoresSafeArea(.container, edges: .vertical)
            }
            .contentShape(Rectangle())
            .simultaneousGesture(sidebarSwipeGesture(in: proxy.size))
        }
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

    private func sidebarWidth(for availableWidth: CGFloat) -> CGFloat {
        min(max(availableWidth - 48, 308), 354)
    }

    private func sidebarSwipeGesture(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 18, coordinateSpace: .local)
            .onEnded { value in
                let translation = value.translation
                let mostlyHorizontal = abs(translation.width) > abs(translation.height) * 1.4
                guard mostlyHorizontal else { return }

                if store.isSidebarVisible {
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

private struct ChatSidebarOverlay: View {
    @Bindable var store: StoreOf<ChatTab>
    let width: CGFloat
    let isVisible: Bool

    @Environment(\.palette) private var palette
    private let hiddenShadowPadding: CGFloat = 28

    var body: some View {
        HStack(spacing: 0) {
            ChatSidebarView(store: store, safeAreaInsets: keyWindowSafeAreaInsets)
                .frame(width: width)
                .frame(maxHeight: .infinity)
                .clipped()
                .compositingGroup()
                .shadow(
                    color: .black.opacity(sidebarShadowOpacity),
                    radius: 10,
                    x: 5,
                    y: 0
                )
                .offset(x: isVisible ? 0 : -(width + hiddenShadowPadding))

            Color.clear
                .contentShape(Rectangle())
                .accessibilityHidden(true)
                .onTapGesture {
                    store.send(.sidebarDismissed)
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .clipped()
        .animation(.spring(response: 0.26, dampingFraction: 0.84), value: isVisible)
        .allowsHitTesting(isVisible)
        .accessibilityHidden(!isVisible)
    }

    private var sidebarShadowOpacity: Double {
        guard isVisible else { return 0 }
        return palette.isDark ? 0.18 : 0.08
    }

    private var keyWindowSafeAreaInsets: EdgeInsets {
        guard let insets = UIApplication.shared.openSpaceKeyWindow?.safeAreaInsets else {
            return EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        }

        return EdgeInsets(
            top: insets.top,
            leading: insets.left,
            bottom: insets.bottom,
            trailing: insets.right
        )
    }
}

private extension UIApplication {
    var openSpaceKeyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
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
