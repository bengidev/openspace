import ComposableArchitecture
import Foundation
import SwiftUI

struct InputComposerView: View {
    @Bindable var store: StoreOf<ChatTab>
    let isComposerFocused: FocusState<Bool>.Binding

    var body: some View {
        VStack(spacing: 8) {
            ComposerPromptPanel(
                store: store,
                isComposerFocused: isComposerFocused
            )
            ComposerContextRail(
                store: store,
                dismissKeyboard: dismissKeyboard
            )
        }
        .frame(maxWidth: 620)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }

    private func dismissKeyboard() {
        isComposerFocused.wrappedValue = false
    }
}

private struct ComposerPromptPanel: View {
    @Bindable var store: StoreOf<ChatTab>
    let isComposerFocused: FocusState<Bool>.Binding

    @Environment(\.palette) private var palette
    @State private var sendFeedbackTrigger = false

    private var canSend: Bool {
        !store.draftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !store.isSending
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField(
                "Ask anything... @files, $skills, /commands",
                text: Binding(
                    get: { store.draftMessage },
                    set: { store.send(.draftMessageChanged($0)) }
                ),
                axis: .vertical
            )
            .frame(minHeight: 50)
            .font(.system(size: 15, weight: .regular))
            .foregroundStyle(palette.textPrimary)
            .lineLimit(1...5)
            .textInputAutocapitalization(.sentences)
            .focused(isComposerFocused)

            HStack(spacing: 6) {
                ComposerIconButton(
                    systemImage: "plus",
                    accessibilityLabel: "Add attachment",
                    action: {
                        dismissKeyboard()
                        store.send(.attachmentTapped)
                    }
                )

                ComposerMenuChip(
                    title: store.selectedModel.title,
                    systemImage: "bolt.fill",
                    minWidth: 104,
                    dismissKeyboard: dismissKeyboard
                ) {
                    ForEach(ComposerModelOption.allCases) { model in
                        Button {
                            dismissKeyboard()
                            store.send(.composerModelSelected(model))
                        } label: {
                            Label(
                                model.title,
                                systemImage: store.selectedModel == model ? "checkmark" : "circle"
                            )
                        }
                    }
                }
                .accessibilityLabel("Model, \(store.selectedModel.title)")

                ComposerMenuChip(
                    title: store.reasoningLevel.title,
                    systemImage: "circle.hexagongrid",
                    minWidth: 86,
                    dismissKeyboard: dismissKeyboard
                ) {
                    ForEach(ComposerReasoningLevel.allCases) { level in
                        Button {
                            dismissKeyboard()
                            store.send(.reasoningLevelSelected(level))
                        } label: {
                            Label(
                                level.title,
                                systemImage: store.reasoningLevel == level ? "checkmark" : "circle"
                            )
                        }
                    }
                }
                .accessibilityLabel("Reasoning, \(store.reasoningLevel.title)")

                Spacer(minLength: 4)

                ComposerIconButton(
                    systemImage: "mic",
                    accessibilityLabel: "Start voice input",
                    action: {
                        dismissKeyboard()
                        store.send(.microphoneTapped)
                    }
                )

                ComposerSendButton(canSend: canSend, action: send)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 10)
        .composerGlass(cornerRadius: 28, shadowOpacity: 0.16)
        .sensoryFeedback(.success, trigger: sendFeedbackTrigger)
    }

    private func send() {
        guard canSend else { return }
        dismissKeyboard()
        sendFeedbackTrigger.toggle()
        store.send(.sendMessageTapped)
    }

    private func dismissKeyboard() {
        isComposerFocused.wrappedValue = false
    }
}

private struct ComposerContextRail: View {
    @Bindable var store: StoreOf<ChatTab>
    let dismissKeyboard: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            ComposerMenuChip(
                title: store.executionScope.title,
                systemImage: "laptopcomputer",
                minWidth: 106,
                dismissKeyboard: dismissKeyboard
            ) {
                ForEach(ComposerExecutionScope.allCases) { scope in
                    Button {
                        dismissKeyboard()
                        store.send(.executionScopeSelected(scope))
                    } label: {
                        Label(
                            scope.title,
                            systemImage: store.executionScope == scope ? "checkmark" : "circle"
                        )
                    }
                }
            }
            .accessibilityLabel("Execution scope, \(store.executionScope.title)")

            ComposerMenuChip(
                title: store.toolPolicy.title,
                systemImage: "shield",
                displaysTitle: false,
                isSignal: true,
                minWidth: 52,
                dismissKeyboard: dismissKeyboard
            ) {
                ForEach(ComposerToolPolicy.allCases) { policy in
                    Button {
                        dismissKeyboard()
                        store.send(.toolPolicySelected(policy))
                    } label: {
                        Label(
                            policy.title,
                            systemImage: store.toolPolicy == policy ? "checkmark" : "circle"
                        )
                    }
                }
            }
            .accessibilityLabel("Tool approval policy, \(store.toolPolicy.title)")

            Spacer(minLength: 10)

            ComposerMenuChip(
                title: store.selectedBranch.title,
                systemImage: "point.3.connected.trianglepath.dotted",
                minWidth: 92,
                dismissKeyboard: dismissKeyboard
            ) {
                ForEach(ComposerBranch.allCases) { branch in
                    Button {
                        dismissKeyboard()
                        store.send(.branchSelected(branch))
                    } label: {
                        Label(
                            branch.title,
                            systemImage: store.selectedBranch == branch ? "checkmark" : "circle"
                        )
                    }
                }
            }
            .accessibilityLabel("Workspace branch, \(store.selectedBranch.title)")

            ComposerIconButton(
                systemImage: "quote.bubble",
                isChip: true,
                accessibilityLabel: "Open context notes",
                action: {
                    dismissKeyboard()
                    store.send(.contextNotesTapped)
                }
            )
        }
        .padding(.horizontal, 2)
    }
}

private struct ComposerMenuChip<MenuItems: View>: View {
    let title: String
    let systemImage: String?
    let displaysTitle: Bool
    let isSignal: Bool
    let minWidth: CGFloat
    let dismissKeyboard: () -> Void
    let menuItems: MenuItems

    @Environment(\.palette) private var palette

    init(
        title: String,
        systemImage: String? = nil,
        displaysTitle: Bool = true,
        isSignal: Bool = false,
        minWidth: CGFloat = 0,
        dismissKeyboard: @escaping () -> Void = {},
        @ViewBuilder menuItems: () -> MenuItems
    ) {
        self.title = title
        self.systemImage = systemImage
        self.displaysTitle = displaysTitle
        self.isSignal = isSignal
        self.minWidth = minWidth
        self.dismissKeyboard = dismissKeyboard
        self.menuItems = menuItems()
    }

    var body: some View {
        Menu {
            menuItems
        } label: {
            HStack(spacing: 5) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 12, weight: .semibold))
                        .accessibilityHidden(true)
                }

                if displaysTitle {
                    Text(title)
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .semibold))
                    .accessibilityHidden(true)
            }
            .foregroundStyle(isSignal ? palette.accent : palette.textSecondary)
            .frame(minWidth: minWidth)
            .frame(height: 30)
            .padding(.horizontal, displaysTitle ? 10 : 8)
            .composerGlass(cornerRadius: 16, shadowOpacity: 0.06)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            TapGesture().onEnded {
                dismissKeyboard()
            }
        )
    }
}

private struct ComposerIconButton: View {
    let systemImage: String
    var isChip = false
    let accessibilityLabel: String
    let action: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(palette.textMuted)
                .frame(width: isChip ? 36 : 30, height: 30)
                .background {
                    if isChip {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(palette.surface.opacity(palette.isDark ? 0.24 : 0.62))
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

private struct ComposerSendButton: View {
    let canSend: Bool
    let action: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.up")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(canSend ? palette.primaryActionText : palette.textMuted)
                .frame(width: 34, height: 34)
                .background(canSend ? palette.primaryActionFill : palette.inverseSurface.opacity(0.08))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(!canSend)
        .accessibilityLabel("Send message")
    }
}

private struct ComposerGlassChrome: ViewModifier {
    let cornerRadius: CGFloat
    let shadowOpacity: Double

    @Environment(\.palette) private var palette

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(palette.isDark ? palette.elevatedSurface.opacity(0.7) : palette.surface.opacity(0.72))
            }
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(palette.inverseSurface.opacity(palette.isDark ? 0.1 : 0.08), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(shadowOpacity), radius: 18, x: 0, y: 8)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

private extension View {
    func composerGlass(cornerRadius: CGFloat, shadowOpacity: Double) -> some View {
        modifier(ComposerGlassChrome(cornerRadius: cornerRadius, shadowOpacity: shadowOpacity))
    }
}
