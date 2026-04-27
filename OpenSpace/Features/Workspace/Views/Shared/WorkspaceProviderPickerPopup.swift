import SwiftUI

// MARK: - WorkspaceProviderPickerPopup

struct WorkspaceProviderPickerPopup: View {
    // MARK: Internal

    let providers: [AIProvider]
    let selectedProviderID: String?
    let selectProvider: (AIProvider) -> Void
    let dismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            WorkspaceProviderPickerHeader(dismiss: dismiss)
                .padding(.bottom, headerBottomPadding)

            WorkspaceProviderSearchField(searchText: $searchText)
                .padding(.bottom, searchBottomPadding)

            providerList
        }
        .padding(.top, popupTopPadding)
        .padding(.horizontal, popupHorizontalPadding)
        .padding(.bottom, popupBottomPadding)
        .frame(width: popupWidth, height: popupHeight, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(WorkspaceProviderPickerPalette.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(WorkspaceProviderPickerPalette.stroke, lineWidth: 1)
        )
        .compositingGroup()
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.36), radius: 30, x: 0, y: 22)
    }

    // MARK: Private

    @State private var searchText = ""

    private var popupTopPadding: CGFloat {
        #if os(macOS)
            26
        #else
            24
        #endif
    }

    private var popupHorizontalPadding: CGFloat {
        #if os(macOS)
            28
        #else
            24
        #endif
    }

    private var popupBottomPadding: CGFloat {
        #if os(macOS)
            24
        #else
            22
        #endif
    }

    private var headerBottomPadding: CGFloat {
        #if os(macOS)
            20
        #else
            20
        #endif
    }

    private var searchBottomPadding: CGFloat {
        #if os(macOS)
            16
        #else
            14
        #endif
    }

    private var providerList: some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVStack(alignment: .leading, spacing: rowSpacing) {
                if filteredProviders.isEmpty {
                    WorkspaceProviderEmptyState(searchText: searchText)
                        .frame(maxWidth: .infinity, minHeight: emptyStateMinHeight)
                } else {
                    ForEach(filteredProviders) { provider in
                        WorkspaceProviderPickerRow(
                            provider: provider,
                            isSelected: provider.id == selectedProviderID
                        ) {
                            dismiss()
                            selectProvider(provider)
                        }
                    }
                }
            }
            .padding(.vertical, 2)
        }
        .frame(maxHeight: .infinity)
    }

    private var rowSpacing: CGFloat {
        #if os(macOS)
            6
        #else
            6
        #endif
    }

    private var emptyStateMinHeight: CGFloat {
        #if os(macOS)
            130
        #else
            120
        #endif
    }

    private var filteredProviders: [AIProvider] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return providers }

        return providers.filter { provider in
            provider.name.localizedCaseInsensitiveContains(query)
                || provider.id.localizedCaseInsensitiveContains(query)
                || provider.env.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    private var popupWidth: CGFloat {
        #if os(macOS)
            500
        #else
            320
        #endif
    }

    private var popupHeight: CGFloat {
        #if os(macOS)
            460
        #else
            420
        #endif
    }
}

// MARK: - WorkspaceProviderPickerHeader

private struct WorkspaceProviderPickerHeader: View {
    let dismiss: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            Text("Connect provider")
                .font(.system(size: titleFontSize, weight: .semibold))
                .foregroundStyle(WorkspaceProviderPickerPalette.primaryText)

            Spacer(minLength: 16)

            Button(action: dismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: closeIconSize, weight: .light))
                    .foregroundStyle(WorkspaceProviderPickerPalette.icon)
                    .frame(width: closeButtonSize, height: closeButtonSize)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close provider picker")
        }
    }

    private var titleFontSize: CGFloat {
        #if os(macOS)
            24
        #else
            23
        #endif
    }

    private var closeIconSize: CGFloat {
        #if os(macOS)
            18
        #else
            18
        #endif
    }

    private var closeButtonSize: CGFloat {
        #if os(macOS)
            34
        #else
            34
        #endif
    }
}

// MARK: - WorkspaceProviderSearchField

private struct WorkspaceProviderSearchField: View {
    @Binding var searchText: String

    var body: some View {
        HStack(spacing: fieldSpacing) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: iconSize, weight: .regular))
                .foregroundStyle(WorkspaceProviderPickerPalette.icon)
                .accessibilityHidden(true)

            TextField("Search providers", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: textFontSize, weight: .regular))
                .foregroundStyle(WorkspaceProviderPickerPalette.primaryText)
                .tint(WorkspaceProviderPickerPalette.secondaryText)
                .focused($isSearchFocused)
                .onAppear {
                    #if os(macOS)
                        isSearchFocused = true
                    #endif
                }
        }
        .padding(.horizontal, horizontalPadding)
        .frame(height: fieldHeight)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(WorkspaceProviderPickerPalette.fieldBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(WorkspaceProviderPickerPalette.stroke.opacity(0.74), lineWidth: 1)
        )
        .accessibilityLabel("Search providers")
    }

    @FocusState private var isSearchFocused: Bool

    private var fieldSpacing: CGFloat {
        #if os(macOS)
            10
        #else
            10
        #endif
    }

    private var iconSize: CGFloat {
        #if os(macOS)
            17
        #else
            18
        #endif
    }

    private var textFontSize: CGFloat {
        #if os(macOS)
            16
        #else
            17
        #endif
    }

    private var horizontalPadding: CGFloat {
        #if os(macOS)
            14
        #else
            14
        #endif
    }

    private var fieldHeight: CGFloat {
        #if os(macOS)
            44
        #else
            48
        #endif
    }
}

// MARK: - WorkspaceProviderPickerRow

private struct WorkspaceProviderPickerRow: View {
    let provider: AIProvider
    let isSelected: Bool
    let select: () -> Void

    var body: some View {
        Button(action: select) {
            HStack(alignment: .center, spacing: rowSpacing) {
                WorkspaceProviderIcon(provider: provider)

                VStack(alignment: .leading, spacing: 4) {
                    Text(provider.name)
                        .font(.system(size: titleFontSize, weight: .semibold))
                        .foregroundStyle(WorkspaceProviderPickerPalette.primaryText)
                        .lineLimit(1)

                    Text(providerSummary)
                        .font(.system(size: summaryFontSize, weight: .regular))
                        .foregroundStyle(WorkspaceProviderPickerPalette.secondaryText)
                        .lineLimit(1)
                }

                Spacer(minLength: trailingSpacerMinLength)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(WorkspaceProviderPickerPalette.badgeText)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(WorkspaceProviderPickerPalette.selectedIndicatorBackground)
                        )
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(rowBackground)
            .overlay(rowStroke)
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(provider.name)
        .accessibilityValue(isSelected ? "Selected" : providerSummary)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private var rowSpacing: CGFloat {
        #if os(macOS)
            12
        #else
            12
        #endif
    }

    private var titleFontSize: CGFloat {
        #if os(macOS)
            16
        #else
            17
        #endif
    }

    private var summaryFontSize: CGFloat {
        #if os(macOS)
            12
        #else
            12
        #endif
    }

    private var trailingSpacerMinLength: CGFloat {
        #if os(macOS)
            10
        #else
            10
        #endif
    }

    private var horizontalPadding: CGFloat {
        #if os(macOS)
            10
        #else
            10
        #endif
    }

    private var verticalPadding: CGFloat {
        #if os(macOS)
            8
        #else
            8
        #endif
    }

    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(
                isSelected
                    ? WorkspaceProviderPickerPalette.selectedBackground
                    : Color.clear
            )
    }

    private var rowStroke: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(
                isSelected
                    ? WorkspaceProviderPickerPalette.selectedStroke
                    : Color.clear,
                lineWidth: 1
            )
    }

    private var providerSummary: String {
        var details: [String] = []

        if provider.api != nil {
            details.append("API access")
        }

        if provider.npm != nil {
            details.append("Package integration")
        }

        if !provider.env.isEmpty {
            details.append("\(provider.env.count) environment key\(provider.env.count == 1 ? "" : "s")")
        }

        if details.isEmpty, provider.doc != nil {
            details.append("Documentation available")
        }

        return details.isEmpty ? "Provider from models.dev catalog" : details.joined(separator: " • ")
    }
}

// MARK: - WorkspaceProviderIcon

private struct WorkspaceProviderIcon: View {
    let provider: AIProvider

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(WorkspaceProviderPickerPalette.iconBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(WorkspaceProviderPickerPalette.stroke, lineWidth: 1)
                )

            Text(initials)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(WorkspaceProviderPickerPalette.icon)
                .lineLimit(1)
        }
        .frame(width: iconSize, height: iconSize)
        .accessibilityHidden(true)
    }

    private var iconSize: CGFloat {
        #if os(macOS)
            32
        #else
            34
        #endif
    }

    private var initials: String {
        let words = provider.name
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
            .prefix(2)
            .compactMap(\.first)

        let value = String(words).uppercased()
        return value.isEmpty ? String(provider.name.prefix(1)).uppercased() : value
    }
}

// MARK: - WorkspaceProviderEmptyState

private struct WorkspaceProviderEmptyState: View {
    let searchText: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 24, weight: .regular))
                .foregroundStyle(WorkspaceProviderPickerPalette.icon)

            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(WorkspaceProviderPickerPalette.primaryText)

            Text(message)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(WorkspaceProviderPickerPalette.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
        }
        .padding(.vertical, 24)
    }

    private var title: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "No providers available"
            : "No matching providers"
    }

    private var message: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "OpenSpace could not load provider choices yet."
            : "Try a different provider name or API keyword."
    }
}

// MARK: - WorkspaceProviderConnectionPopup

struct WorkspaceProviderConnectionPopup: View {
    // MARK: Lifecycle

    init(
        provider: AIProvider,
        dismiss: @escaping () -> Void,
        back: @escaping () -> Void,
        connect: @escaping (AIProvider) -> Void
    ) {
        self.provider = provider
        self.dismiss = dismiss
        self.back = back
        self.connect = connect
        _selectedMethod = State(initialValue: provider.availableConnectionMethods.first ?? .apiKey)
    }

    // MARK: Internal

    let provider: AIProvider
    let dismiss: () -> Void
    let back: () -> Void
    let connect: (AIProvider) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            WorkspaceProviderConnectionNavigation(dismiss: dismiss, back: back)
                .padding(.top, popupTopPadding)
                .padding(.horizontal, popupHorizontalPadding)
                .padding(.bottom, 10)

            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: bodySpacing) {
                    titleBlock

                    Text(instructionText)
                        .font(.system(size: instructionFontSize, weight: .regular))
                        .foregroundStyle(WorkspaceProviderPickerPalette.secondaryText)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)

                    WorkspaceProviderConnectionMethodPicker(
                        methods: provider.availableConnectionMethods,
                        selectedMethod: $selectedMethod
                    )

                    connectionDetails
                }
                .padding(.horizontal, popupHorizontalPadding)
                .padding(.bottom, scrollContentBottomPadding)
            }
            .frame(maxHeight: .infinity)

            WorkspaceProviderConnectionFooter(
                title: continueButtonTitle,
                isDisabled: isContinueDisabled,
                action: continueConnection
            )
        }
        .frame(width: popupWidth, height: popupHeight, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(WorkspaceProviderPickerPalette.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(WorkspaceProviderPickerPalette.stroke, lineWidth: 1)
        )
        .compositingGroup()
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.36), radius: 30, x: 0, y: 22)
    }

    // MARK: Private

    @Environment(\.openURL) private var openURL
    @FocusState private var isAPIKeyFocused: Bool
    @State private var apiKey = ""
    @State private var selectedMethod: AIProviderConnectionMethod

    private var popupTopPadding: CGFloat {
        #if os(macOS)
            22
        #else
            26
        #endif
    }

    private var popupHorizontalPadding: CGFloat {
        #if os(macOS)
            28
        #else
            22
        #endif
    }

    private var bodySpacing: CGFloat {
        #if os(macOS)
            13
        #else
            12
        #endif
    }

    private var instructionFontSize: CGFloat {
        #if os(macOS)
            14
        #else
            15
        #endif
    }

    private var scrollContentBottomPadding: CGFloat {
        #if os(macOS)
            18
        #else
            22
        #endif
    }

    private var titleBlock: some View {
        HStack(spacing: 16) {
            WorkspaceProviderIcon(provider: provider)
                .frame(width: titleIconSize, height: titleIconSize)

            Text("Connect \(provider.name)")
                .font(.system(size: titleFontSize, weight: .semibold))
                .foregroundStyle(WorkspaceProviderPickerPalette.primaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
        }
    }

    private var titleIconSize: CGFloat {
        #if os(macOS)
            34
        #else
            34
        #endif
    }

    private var titleFontSize: CGFloat {
        #if os(macOS)
            22
        #else
            22
        #endif
    }

    @ViewBuilder
    private var connectionDetails: some View {
        switch selectedMethod {
        case .apiKey:
            VStack(alignment: .leading, spacing: 9) {
                Text("\(provider.name) API key")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(WorkspaceProviderPickerPalette.secondaryText)

                SecureField("API key", text: $apiKey)
                    .textFieldStyle(.plain)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(WorkspaceProviderPickerPalette.primaryText)
                    .tint(WorkspaceProviderPickerPalette.secondaryText)
                    .focused($isAPIKeyFocused)
                    .padding(.horizontal, 18)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(WorkspaceProviderPickerPalette.fieldBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(WorkspaceProviderPickerPalette.stroke.opacity(0.82), lineWidth: 1)
                    )
                    .accessibilityLabel("\(provider.name) API key")
                    .onAppear {
                        #if os(macOS)
                            isAPIKeyFocused = true
                        #endif
                    }

                Text("Use \(provider.preferredAPIKeyName) from \(provider.name).")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(WorkspaceProviderPickerPalette.icon)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }

        case .webAuthentication:
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "safari")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(WorkspaceProviderPickerPalette.secondaryText)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Authorize in browser")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(WorkspaceProviderPickerPalette.primaryText)

                        Text("OpenSpace will continue through \(provider.name) in your browser, then return after authorization.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(WorkspaceProviderPickerPalette.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(WorkspaceProviderPickerPalette.fieldBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(WorkspaceProviderPickerPalette.stroke.opacity(0.82), lineWidth: 1)
                )
            }
        }
    }

    private var instructionText: String {
        switch selectedMethod {
        case .apiKey:
            "Enter your \(provider.name) API key to use \(provider.name) models in OpenSpace."
        case .webAuthentication:
            "Sign in with \(provider.name) in your browser to use \(provider.name) models in OpenSpace."
        }
    }

    private var continueButtonTitle: String {
        switch selectedMethod {
        case .apiKey:
            "Continue"
        case .webAuthentication:
            "Continue with Web Auth"
        }
    }

    private var isContinueDisabled: Bool {
        selectedMethod == .apiKey && apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var popupWidth: CGFloat {
        #if os(macOS)
            500
        #else
            318
        #endif
    }

    private var popupHeight: CGFloat {
        #if os(macOS)
            560
        #else
            560
        #endif
    }

    private func continueConnection() {
        switch selectedMethod {
        case .apiKey:
            connect(provider)
        case .webAuthentication:
            if let url = provider.webAuthenticationURL {
                openURL(url)
            }
            connect(provider)
        }
    }
}

// MARK: - WorkspaceProviderConnectionFooter

private struct WorkspaceProviderConnectionFooter: View {
    let title: String
    let isDisabled: Bool
    let action: () -> Void

    private var horizontalPadding: CGFloat {
        #if os(macOS)
            34
        #else
            26
        #endif
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(WorkspaceProviderPickerPalette.primaryButtonText)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(WorkspaceProviderPickerPalette.primaryButtonBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(WorkspaceProviderPickerPalette.primaryButtonStroke, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.56 : 1)
        .accessibilityLabel(title)
        .padding(.horizontal, horizontalPadding)
        .padding(.top, 12)
        .padding(.bottom, 18)
        .background(
            WorkspaceProviderPickerPalette.background
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(WorkspaceProviderPickerPalette.stroke.opacity(0.62))
                        .frame(height: 1)
                }
        )
    }
}

// MARK: - WorkspaceProviderConnectionNavigation

private struct WorkspaceProviderConnectionNavigation: View {
    let dismiss: () -> Void
    let back: () -> Void

    var body: some View {
        HStack {
            Button(action: back) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(WorkspaceProviderPickerPalette.icon)
                    .frame(width: 38, height: 38)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back to providers")

            Spacer(minLength: 16)

            Button(action: dismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(WorkspaceProviderPickerPalette.icon)
                    .frame(width: 38, height: 38)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close provider connection")
        }
    }
}

// MARK: - WorkspaceProviderConnectionMethodPicker

private struct WorkspaceProviderConnectionMethodPicker: View {
    let methods: [AIProviderConnectionMethod]
    @Binding var selectedMethod: AIProviderConnectionMethod

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Connection method")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(WorkspaceProviderPickerPalette.secondaryText)

            VStack(spacing: 8) {
                ForEach(methods) { method in
                    WorkspaceProviderConnectionMethodRow(
                        method: method,
                        isSelected: method == selectedMethod
                    ) {
                        selectedMethod = method
                    }
                }
            }
        }
    }
}

// MARK: - WorkspaceProviderConnectionMethodRow

private struct WorkspaceProviderConnectionMethodRow: View {
    let method: AIProviderConnectionMethod
    let isSelected: Bool
    let select: () -> Void

    var body: some View {
        Button(action: select) {
            HStack(alignment: .top, spacing: 13) {
                ZStack {
                    Circle()
                        .stroke(
                            isSelected
                                ? WorkspaceProviderPickerPalette.primaryButtonBackground
                                : WorkspaceProviderPickerPalette.stroke,
                            lineWidth: 1.6
                        )
                        .frame(width: 20, height: 20)

                    if isSelected {
                        Circle()
                            .fill(WorkspaceProviderPickerPalette.primaryButtonBackground)
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.top, 1)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 3) {
                    Text(method.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WorkspaceProviderPickerPalette.primaryText)

                    Text(method.description)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(WorkspaceProviderPickerPalette.secondaryText)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? WorkspaceProviderPickerPalette.selectedBackground : WorkspaceProviderPickerPalette.fieldBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        isSelected
                            ? WorkspaceProviderPickerPalette.selectedStroke
                            : WorkspaceProviderPickerPalette.stroke.opacity(0.74),
                        lineWidth: 1
                    )
            )
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(method.title)
        .accessibilityValue(isSelected ? "Selected" : method.description)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

// MARK: - WorkspaceCenteredProviderPopupOverlay

struct WorkspaceCenteredProviderPopupOverlay<Content: View>: View {
    let dismiss: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            Button(action: dismissFromCenter) {
                Rectangle()
                    .fill(Color.black.opacity(isPresented ? 0.56 : 0))
                    .ignoresSafeArea()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss provider popup")

            content()
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
                .scaleEffect(isPresented ? 1 : 0.92, anchor: .center)
                .opacity(isPresented ? 1 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .onAppear {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                isPresented = true
            }
        }
    }

    // MARK: Private

    @State private var isPresented = false

    private func dismissFromCenter() {
        withAnimation(.easeInOut(duration: 0.16)) {
            isPresented = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            dismiss()
        }
    }
}

// MARK: - WorkspaceProviderPickerPalette

private enum WorkspaceProviderPickerPalette {
    static let background = Color(hex: "1C1B19")
    static let fieldBackground = Color(hex: "24231F")
    static let iconBackground = Color(hex: "24231F")
    static let stroke = Color(hex: "3A372F")
    static let selectedStroke = Color(hex: "6E6044")
    static let selectedBackground = Color(hex: "2A241D")
    static let selectedIndicatorBackground = Color(hex: "3B3325")
    static let primaryText = Color(hex: "F2F0EA")
    static let secondaryText = Color(hex: "CBBF96")
    static let icon = Color(hex: "AFA68B")
    static let badgeText = Color(hex: "EFE1B2")
    static let primaryButtonBackground = Color(hex: "EBDDAE")
    static let primaryButtonStroke = Color(hex: "6A6450")
    static let primaryButtonText = Color(hex: "151515")
}
