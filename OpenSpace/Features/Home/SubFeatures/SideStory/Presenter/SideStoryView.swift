import ComposableArchitecture
import SwiftUI

struct SideStoryView: View {
    @Bindable var store: StoreOf<SideStory>
    let modelTitle: String
    let branchTitle: String
    var safeAreaInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

    @Environment(\.palette) private var palette
    @FocusState private var isSearchFocused: Bool
    @State private var isConversationListExpanded = false

    private let collapsedConversationLimit = 8

    var body: some View {
        VStack(spacing: 0) {
            SidebarHeader()
                .padding(.horizontal, SidebarMetrics.horizontalPadding)
                .padding(.top, 14)
                .padding(.bottom, 13)
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissSearchKeyboard()
                }

            SidebarSearchField(
                query: Binding(
                    get: { store.conversationList.searchQuery },
                    set: { store.send(.conversationList(.searchQueryChanged($0))) }
                ),
                isFocused: $isSearchFocused
            )
            .padding(.horizontal, SidebarMetrics.horizontalPadding)
            .padding(.bottom, 14)

            SidebarActionRow(
                title: "New Chat",
                systemImage: "plus.square",
                action: {
                    dismissSearchKeyboard()
                    store.send(.newConversationTapped)
                }
            )
            .padding(.horizontal, SidebarMetrics.horizontalPadding)
            .padding(.bottom, 8)

            conversationContent

            SidebarWorkspaceRow(
                title: "OpenSpace",
                count: store.conversationList.conversations.count,
                onAdd: {
                    dismissSearchKeyboard()
                    store.send(.newConversationTapped)
                },
                onTap: dismissSearchKeyboard
            )
            .padding(.horizontal, SidebarMetrics.horizontalPadding)
            .padding(.top, 10)

            SidebarFooter(
                modelTitle: modelTitle,
                branchTitle: branchTitle,
                onSettings: {
                    dismissSearchKeyboard()
                    store.send(.settingsTapped)
                }
            )
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 12)
        }
        .padding(.top, safeAreaInsets.top)
        .padding(.bottom, safeAreaInsets.bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(sidebarBackground)
        .onChange(of: store.conversationList.searchQuery) { _, _ in
            if isConversationListExpanded {
                isConversationListExpanded = false
            }
        }
        .onChange(of: store.isSidebarVisible) { _, isVisible in
            guard !isVisible else { return }
            dismissSearchKeyboard()
        }
    }

    private var conversationContent: some View {
        Group {
            if store.conversationList.isLoading {
                SidebarLoadingRows()
                    .padding(.horizontal, SidebarMetrics.horizontalPadding)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        dismissSearchKeyboard()
                    }
            } else if store.conversationList.conversations.isEmpty {
                SidebarEmptyState(isSearching: !store.conversationList.searchQuery.isEmpty)
                    .padding(.horizontal, SidebarMetrics.horizontalPadding)
                    .frame(maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        dismissSearchKeyboard()
                    }
            } else {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(visibleConversations) { conversation in
                            SidebarConversationRow(
                                conversation: conversation,
                                isSelected: store.conversationList.selectedConversation?.id == conversation.id,
                                onSelect: {
                                    dismissSearchKeyboard()
                                    store.send(.conversationList(.conversationSelected(conversation)))
                                },
                                onDelete: {
                                    dismissSearchKeyboard()
                                    store.send(.conversationList(.deleteConversationTapped(conversation.id)))
                                }
                            )
                        }

                        if hiddenConversationCount > 0 {
                            SidebarShowMoreButton(
                                hiddenCount: hiddenConversationCount,
                                isExpanded: isConversationListExpanded,
                                action: {
                                    dismissSearchKeyboard()
                                    withAnimation(.spring(response: 0.24, dampingFraction: 0.82)) {
                                        isConversationListExpanded.toggle()
                                    }
                                }
                            )
                            .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, SidebarMetrics.horizontalPadding)
                    .padding(.bottom, 10)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissSearchKeyboard()
                }
            }
        }
    }

    private var sidebarBackground: some View {
        Rectangle()
            .fill(panelFill)
            .overlay(alignment: .trailing) {
                Rectangle()
                    .fill(edgeLine.opacity(palette.isDark ? 0.52 : 0.32))
                    .frame(width: 0.5)
            }
    }

    private var panelFill: Color {
        palette.isDark ? palette.background : Color.white
    }

    private var edgeLine: Color {
        palette.isDark ? palette.border : Color(hex: "d9d9d9")
    }

    private var visibleConversations: ArraySlice<Conversation> {
        let conversations = store.conversationList.conversations
        guard shouldCollapseConversations else {
            return conversations[...]
        }

        return conversations.prefix(collapsedConversationLimit)
    }

    private var hiddenConversationCount: Int {
        guard shouldShowMoreButton else { return 0 }
        return store.conversationList.conversations.count - collapsedConversationLimit
    }

    private var shouldCollapseConversations: Bool {
        !isConversationListExpanded
            && store.conversationList.searchQuery.isEmpty
            && store.conversationList.conversations.count > collapsedConversationLimit
    }

    private var shouldShowMoreButton: Bool {
        store.conversationList.searchQuery.isEmpty
            && store.conversationList.conversations.count > collapsedConversationLimit
    }

    private func dismissSearchKeyboard() {
        isSearchFocused = false
    }
}

private enum SidebarMetrics {
    static let horizontalPadding: CGFloat = 22
    static let rowInnerHorizontalPadding: CGFloat = 8
    static let rowIconWidth: CGFloat = 18
    static let rowTextGap: CGFloat = 10
    static let titleLeadingPadding = rowInnerHorizontalPadding + rowIconWidth + rowTextGap
}

private struct SidebarHeader: View {
    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(logoFill)
                    .overlay {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(logoStroke, lineWidth: 0.8)
                    }

                Image(systemName: "bubble.left.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(palette.accentText)
                    .accessibilityHidden(true)
            }
            .frame(width: 20, height: 20)

            Text("OpenSpace")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(palette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Spacer()
        }
    }

    private var logoFill: Color {
        palette.accent
    }

    private var logoStroke: Color {
        palette.isDark ? palette.accentSoft.opacity(0.42) : palette.accentSoft.opacity(0.24)
    }
}

private struct SidebarSearchField: View {
    @Binding var query: String
    let isFocused: FocusState<Bool>.Binding

    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(searchIcon)
                .accessibilityHidden(true)

            TextField("Search conversations", text: $query)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(palette.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .submitLabel(.search)
                .lineLimit(1)
                .focused(isFocused)
                .onSubmit {
                    isFocused.wrappedValue = false
                }

            Button(action: { query = "" }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(palette.textMuted)
                    .frame(width: 18, height: 22)
            }
            .buttonStyle(.plain)
            .opacity(query.isEmpty ? 0 : 1)
            .disabled(query.isEmpty)
            .accessibilityHidden(query.isEmpty)
            .accessibilityLabel("Clear search")
        }
        .frame(maxWidth: .infinity, minHeight: 34, maxHeight: 34, alignment: .leading)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(searchFill)
        )
        .clipped()
    }

    private var searchFill: Color {
        palette.isDark ? palette.elevatedSurface.opacity(0.58) : Color(hex: "f3f3f3")
    }

    private var searchIcon: Color {
        palette.isDark ? palette.textMuted : Color(hex: "a6a6a6")
    }
}

private struct SidebarActionRow: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(palette.textSecondary)
                    .frame(width: SidebarMetrics.rowIconWidth)

                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                    .lineLimit(1)

                Spacer()
            }
            .frame(height: 38)
            .padding(.horizontal, SidebarMetrics.rowInnerHorizontalPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct SidebarConversationRow: View {
    let conversation: Conversation
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isSelected ? palette.accent : Color.clear)
                        .frame(width: 7, height: 7)
                }
                .frame(width: SidebarMetrics.rowIconWidth)

                Text(conversation.title)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .medium, design: .monospaced))
                    .foregroundStyle(palette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.84)

                Spacer(minLength: 8)

                Text(Self.compactRelativeTime(from: conversation.updatedAt))
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(palette.textMuted)
                    .lineLimit(1)
                    .monospacedDigit()
            }
            .frame(height: 39)
            .padding(.horizontal, SidebarMetrics.rowInnerHorizontalPadding)
            .background(rowBackground)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
        .accessibilityLabel(conversation.title)
        .accessibilityValue(Self.compactRelativeTime(from: conversation.updatedAt))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(
                isSelected
                    ? selectedFill
                    : Color.clear
            )
    }

    private var selectedFill: Color {
        palette.isDark
            ? palette.elevatedSurface.opacity(0.86)
            : Color(hex: "f1f1f1")
    }

    private static func compactRelativeTime(from date: Date) -> String {
        let elapsed = max(0, Int(Date().timeIntervalSince(date)))

        if elapsed < 60 {
            return "now"
        } else if elapsed < 3_600 {
            return "\(elapsed / 60)m"
        } else if elapsed < 86_400 {
            return "\(elapsed / 3_600)h"
        } else if elapsed < 604_800 {
            return "\(elapsed / 86_400)d"
        }

        return date.formatted(.dateTime.month(.abbreviated).day())
    }
}

private struct SidebarShowMoreButton: View {
    let hiddenCount: Int
    let isExpanded: Bool
    let action: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(isExpanded ? "Show less" : "Show \(hiddenCount) more")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(palette.textMuted)

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(palette.textMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 30)
            .padding(.horizontal, SidebarMetrics.titleLeadingPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct SidebarWorkspaceRow: View {
    let title: String
    let count: Int
    let onAdd: () -> Void
    let onTap: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "point.3.connected.trianglepath.dotted")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(palette.textSecondary)
                .frame(width: SidebarMetrics.rowIconWidth)
                .accessibilityHidden(true)

            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(palette.textPrimary)
                .lineLimit(1)

            Text("[\(count)]")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(palette.textPrimary)
                .lineLimit(1)

            Spacer(minLength: 8)

            Button(action: onAdd) {
                Image(systemName: "plus")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(palette.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(controlFill)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("New conversation")
        }
        .frame(height: 40)
        .padding(.horizontal, SidebarMetrics.rowInnerHorizontalPadding)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }

    private var controlFill: Color {
        palette.isDark ? palette.elevatedSurface.opacity(0.72) : Color(hex: "f5f5f5")
    }
}

private struct SidebarLoadingRows: View {
    @Environment(\.palette) private var palette

    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<6, id: \.self) { index in
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(palette.elevatedSurface.opacity(index == 0 ? 0.72 : 0.46))
                    .frame(height: 42)
                    .redacted(reason: .placeholder)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

private struct SidebarEmptyState: View {
    let isSearching: Bool

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: isSearching ? "magnifyingglass" : "bubble.left.and.bubble.right")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(palette.textMuted)

            Text(isSearching ? "No matches" : "No conversations")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(palette.textSecondary)
                .lineLimit(1)

            Text(isSearching ? "Try another title." : "Start a new chat.")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(palette.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct SidebarFooter: View {
    let modelTitle: String
    let branchTitle: String
    let onSettings: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            Button(action: onSettings) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(controlFill)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 3) {
                Text("Connected")
                    .font(.system(size: 9, weight: .regular))
                    .foregroundStyle(palette.textMuted)
                    .lineLimit(1)

                Text("\(modelTitle) / \(branchTitle)")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(palette.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .padding(.bottom, 3)
        }
    }

    private var controlFill: Color {
        palette.isDark ? palette.elevatedSurface.opacity(0.76) : Color(hex: "f5f5f5")
    }
}
