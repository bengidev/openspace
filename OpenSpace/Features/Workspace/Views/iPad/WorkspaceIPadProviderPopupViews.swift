//
//  WorkspaceIPadProviderPopupViews.swift
//  OpenSpace
//
//  iPad-focused provider picker and connection popup views.
//

import SwiftUI

// MARK: - WorkspaceIPadProviderPickerPopup

struct WorkspaceIPadProviderPickerPopup: View {
    // MARK: Internal

    let providers: [AIProvider]
    let selectedProviderID: String?
    let selectProvider: (AIProvider) -> Void
    let dismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            WorkspaceIPadProviderPickerHeader(dismiss: dismiss)
                .padding(.bottom, headerBottomPadding)

            WorkspaceIPadProviderSearchField(searchText: $searchText)
                .padding(.bottom, searchBottomPadding)

            providerList
        }
        .padding(.top, popupTopPadding)
        .padding(.horizontal, popupHorizontalPadding)
        .padding(.bottom, popupBottomPadding)
        .frame(width: popupWidth, height: popupHeight, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(WorkspaceIPadProviderPickerPalette.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(WorkspaceIPadProviderPickerPalette.stroke, lineWidth: 1)
        )
        .compositingGroup()
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.36), radius: 30, x: 0, y: 22)
        .borderBeamOverlay(
            border: WorkspaceIPadProviderPickerPalette.stroke,
            beam: [ThemeColor.accent, ThemeColor.accent100, ThemeColor.accent200],
            beamBlur: 12,
            cornerRadius: 18
        )
    }

    // MARK: Private

    @State private var searchText = ""

    private var popupTopPadding: CGFloat {
        24
    }

    private var popupHorizontalPadding: CGFloat {
        24
    }

    private var popupBottomPadding: CGFloat {
        22
    }

    private var headerBottomPadding: CGFloat {
        20
    }

    private var searchBottomPadding: CGFloat {
        14
    }

    private var providerList: some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVStack(alignment: .leading, spacing: rowSpacing) {
                if filteredProviders.isEmpty {
                    WorkspaceIPadProviderEmptyState(searchText: searchText)
                        .frame(maxWidth: .infinity, minHeight: emptyStateMinHeight)
                } else {
                    ForEach(filteredProviders) { provider in
                        WorkspaceIPadProviderPickerRow(
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
        6
    }

    private var emptyStateMinHeight: CGFloat {
        120
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
        320
    }

    private var popupHeight: CGFloat {
        420
    }
}

// MARK: - WorkspaceIPadProviderPickerHeader

struct WorkspaceIPadProviderPickerHeader: View {
    let dismiss: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            Text("Connect provider")
                .font(.system(size: titleFontSize, weight: .semibold))
                .foregroundStyle(WorkspaceIPadProviderPickerPalette.primaryText)

            Spacer(minLength: 16)

            Button(action: dismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: closeIconSize, weight: .light))
                    .foregroundStyle(WorkspaceIPadProviderPickerPalette.icon)
                    .frame(width: closeButtonSize, height: closeButtonSize)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close provider picker")
        }
    }

    private var titleFontSize: CGFloat {
        23
    }

    private var closeIconSize: CGFloat {
        18
    }

    private var closeButtonSize: CGFloat {
        34
    }
}

// MARK: - WorkspaceIPadProviderSearchField

struct WorkspaceIPadProviderSearchField: View {
    @Binding var searchText: String

    var body: some View {
        HStack(spacing: fieldSpacing) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: iconSize, weight: .regular))
                .foregroundStyle(WorkspaceIPadProviderPickerPalette.icon)
                .accessibilityHidden(true)

            TextField("Search providers", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: textFontSize, weight: .regular))
                .foregroundStyle(WorkspaceIPadProviderPickerPalette.primaryText)
                .tint(WorkspaceIPadProviderPickerPalette.secondaryText)
                .focused($isSearchFocused)
                .onAppear {
                }
        }
        .padding(.horizontal, horizontalPadding)
        .frame(height: fieldHeight)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(WorkspaceIPadProviderPickerPalette.fieldBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(WorkspaceIPadProviderPickerPalette.stroke.opacity(0.74), lineWidth: 1)
        )
        .accessibilityLabel("Search providers")
    }

    @FocusState private var isSearchFocused: Bool

    private var fieldSpacing: CGFloat {
        10
    }

    private var iconSize: CGFloat {
        18
    }

    private var textFontSize: CGFloat {
        17
    }

    private var horizontalPadding: CGFloat {
        14
    }

    private var fieldHeight: CGFloat {
        48
    }
}

// MARK: - WorkspaceIPadProviderPickerRow

struct WorkspaceIPadProviderPickerRow: View {
    let provider: AIProvider
    let isSelected: Bool
    let select: () -> Void

    var body: some View {
        Button(action: select) {
            HStack(alignment: .center, spacing: rowSpacing) {
                WorkspaceIPadProviderIcon(provider: provider)

                VStack(alignment: .leading, spacing: 4) {
                    Text(provider.name)
                        .font(.system(size: titleFontSize, weight: .semibold))
                        .foregroundStyle(WorkspaceIPadProviderPickerPalette.primaryText)
                        .lineLimit(1)

                    Text(providerSummary)
                        .font(.system(size: summaryFontSize, weight: .regular))
                        .foregroundStyle(WorkspaceIPadProviderPickerPalette.secondaryText)
                        .lineLimit(1)
                }

                Spacer(minLength: trailingSpacerMinLength)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(WorkspaceIPadProviderPickerPalette.badgeText)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(WorkspaceIPadProviderPickerPalette.selectedIndicatorBackground)
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
        12
    }

    private var titleFontSize: CGFloat {
        17
    }

    private var summaryFontSize: CGFloat {
        12
    }

    private var trailingSpacerMinLength: CGFloat {
        10
    }

    private var horizontalPadding: CGFloat {
        10
    }

    private var verticalPadding: CGFloat {
        8
    }

    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(
                isSelected
                    ? WorkspaceIPadProviderPickerPalette.selectedBackground
                    : Color.clear
            )
    }

    private var rowStroke: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(
                isSelected
                    ? WorkspaceIPadProviderPickerPalette.selectedStroke
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

// MARK: - WorkspaceIPadProviderIcon

struct WorkspaceIPadProviderIcon: View {
    let provider: AIProvider

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(WorkspaceIPadProviderPickerPalette.iconBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(WorkspaceIPadProviderPickerPalette.stroke, lineWidth: 1)
                )

            Text(initials)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(WorkspaceIPadProviderPickerPalette.icon)
                .lineLimit(1)
        }
        .frame(width: iconSize, height: iconSize)
        .accessibilityHidden(true)
    }

    private var iconSize: CGFloat {
        34
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

// MARK: - WorkspaceIPadProviderEmptyState

struct WorkspaceIPadProviderEmptyState: View {
    let searchText: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 24, weight: .regular))
                .foregroundStyle(WorkspaceIPadProviderPickerPalette.icon)

            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(WorkspaceIPadProviderPickerPalette.primaryText)

            Text(message)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(WorkspaceIPadProviderPickerPalette.secondaryText)
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

// MARK: - WorkspaceIPadProviderConnectionPopup

struct WorkspaceIPadProviderConnectionPopup: View {
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
            WorkspaceIPadProviderConnectionNavigation(dismiss: dismiss, back: back)
                .padding(.top, popupTopPadding)
                .padding(.horizontal, popupHorizontalPadding)
                .padding(.bottom, 10)

            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: bodySpacing) {
                    titleBlock

                    Text(instructionText)
                        .font(.system(size: instructionFontSize, weight: .regular))
                        .foregroundStyle(WorkspaceIPadProviderPickerPalette.secondaryText)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)

                    WorkspaceIPadProviderConnectionMethodPicker(
                        methods: provider.availableConnectionMethods,
                        selectedMethod: $selectedMethod
                    )

                    connectionDetails
                }
                .padding(.horizontal, popupHorizontalPadding)
                .padding(.bottom, scrollContentBottomPadding)
            }
            .frame(maxHeight: .infinity)

            WorkspaceIPadProviderConnectionFooter(
                title: continueButtonTitle,
                isDisabled: isContinueDisabled,
                action: continueConnection
            )
        }
        .frame(width: popupWidth, height: popupHeight, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(WorkspaceIPadProviderPickerPalette.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(WorkspaceIPadProviderPickerPalette.stroke, lineWidth: 1)
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
        26
    }

    private var popupHorizontalPadding: CGFloat {
        22
    }

    private var bodySpacing: CGFloat {
        12
    }

    private var instructionFontSize: CGFloat {
        15
    }

    private var scrollContentBottomPadding: CGFloat {
        22
    }

    private var titleBlock: some View {
        HStack(spacing: 16) {
            WorkspaceIPadProviderIcon(provider: provider)
                .frame(width: titleIconSize, height: titleIconSize)

            Text("Connect \(provider.name)")
                .font(.system(size: titleFontSize, weight: .semibold))
                .foregroundStyle(WorkspaceIPadProviderPickerPalette.primaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
        }
    }

    private var titleIconSize: CGFloat {
        34
    }

    private var titleFontSize: CGFloat {
        22
    }

    @ViewBuilder
    private var connectionDetails: some View {
        switch selectedMethod {
        case .apiKey:
            VStack(alignment: .leading, spacing: 9) {
                Text("\(provider.name) API key")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(WorkspaceIPadProviderPickerPalette.secondaryText)

                SecureField("API key", text: $apiKey)
                    .textFieldStyle(.plain)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(WorkspaceIPadProviderPickerPalette.primaryText)
                    .tint(WorkspaceIPadProviderPickerPalette.secondaryText)
                    .focused($isAPIKeyFocused)
                    .padding(.horizontal, 18)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(WorkspaceIPadProviderPickerPalette.fieldBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(WorkspaceIPadProviderPickerPalette.stroke.opacity(0.82), lineWidth: 1)
                    )
                    .accessibilityLabel("\(provider.name) API key")
                    .onAppear {
                    }

                Text("Use \(provider.preferredAPIKeyName) from \(provider.name).")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(WorkspaceIPadProviderPickerPalette.icon)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }

        case .webAuthentication:
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "safari")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(WorkspaceIPadProviderPickerPalette.secondaryText)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Authorize in browser")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(WorkspaceIPadProviderPickerPalette.primaryText)

                        Text("OpenSpace will continue through \(provider.name) in your browser, then return after authorization.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(WorkspaceIPadProviderPickerPalette.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(WorkspaceIPadProviderPickerPalette.fieldBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(WorkspaceIPadProviderPickerPalette.stroke.opacity(0.82), lineWidth: 1)
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
        318
    }

    private var popupHeight: CGFloat {
        560
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

// MARK: - WorkspaceIPadProviderConnectionFooter

struct WorkspaceIPadProviderConnectionFooter: View {
    let title: String
    let isDisabled: Bool
    let action: () -> Void

    private var horizontalPadding: CGFloat {
        22
    }

    private var buttonHeight: CGFloat {
        46
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(WorkspaceIPadProviderPickerPalette.primaryButtonText)
                .frame(maxWidth: .infinity)
                .frame(height: buttonHeight)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(WorkspaceIPadProviderPickerPalette.primaryButtonBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(WorkspaceIPadProviderPickerPalette.primaryButtonStroke, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.56 : 1)
        .accessibilityLabel(title)
        .padding(.horizontal, horizontalPadding)
        .padding(.top, 10)
        .padding(.bottom, 16)
        .background(
            WorkspaceIPadProviderPickerPalette.background
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(WorkspaceIPadProviderPickerPalette.stroke.opacity(0.62))
                        .frame(height: 1)
                }
        )
    }
}

// MARK: - WorkspaceIPadProviderConnectionNavigation

struct WorkspaceIPadProviderConnectionNavigation: View {
    let dismiss: () -> Void
    let back: () -> Void

    var body: some View {
        HStack {
            Button(action: back) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(WorkspaceIPadProviderPickerPalette.icon)
                    .frame(width: 38, height: 38)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back to providers")

            Spacer(minLength: 16)

            Button(action: dismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(WorkspaceIPadProviderPickerPalette.icon)
                    .frame(width: 38, height: 38)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close provider connection")
        }
    }
}

// MARK: - WorkspaceIPadProviderConnectionMethodPicker

struct WorkspaceIPadProviderConnectionMethodPicker: View {
    let methods: [AIProviderConnectionMethod]
    @Binding var selectedMethod: AIProviderConnectionMethod

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Connection method")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(WorkspaceIPadProviderPickerPalette.secondaryText)

            VStack(spacing: 8) {
                ForEach(methods) { method in
                    WorkspaceIPadProviderConnectionMethodRow(
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

// MARK: - WorkspaceIPadProviderConnectionMethodRow

struct WorkspaceIPadProviderConnectionMethodRow: View {
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
                                ? WorkspaceIPadProviderPickerPalette.primaryButtonBackground
                                : WorkspaceIPadProviderPickerPalette.stroke,
                            lineWidth: 1.6
                        )
                        .frame(width: 20, height: 20)

                    if isSelected {
                        Circle()
                            .fill(WorkspaceIPadProviderPickerPalette.primaryButtonBackground)
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.top, 1)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 3) {
                    Text(method.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WorkspaceIPadProviderPickerPalette.primaryText)

                    Text(method.description)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(WorkspaceIPadProviderPickerPalette.secondaryText)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? WorkspaceIPadProviderPickerPalette.selectedBackground : WorkspaceIPadProviderPickerPalette.fieldBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        isSelected
                            ? WorkspaceIPadProviderPickerPalette.selectedStroke
                            : WorkspaceIPadProviderPickerPalette.stroke.opacity(0.74),
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

// MARK: - WorkspaceIPadCenteredProviderPopupOverlay

struct WorkspaceIPadCenteredProviderPopupOverlay<Content: View>: View {
    let dismiss: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            Button(action: dismissFromCenter) {
                Rectangle()
                    .fill(Color.black.opacity(isPresented ? 0.62 : 0))
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

// MARK: - WorkspaceIPadProviderPickerPalette

enum WorkspaceIPadProviderPickerPalette {
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

#if DEBUG
    private struct WorkspaceIPadProviderPickerPopupPreview: View {
        @State private var selectedProviderID = WorkspacePreviewSupport.defaultProviders.first?.id

        var body: some View {
            WorkspaceIPadProviderPickerPopup(
                providers: WorkspacePreviewSupport.defaultProviders,
                selectedProviderID: selectedProviderID,
                selectProvider: { provider in
                    selectedProviderID = provider.id
                },
                dismiss: { }
            )
            .workspaceComponentPreviewSurface()
        }
    }

    private struct WorkspaceIPadProviderSearchFieldPreview: View {
        @State private var searchText = ""

        var body: some View {
            WorkspaceIPadProviderSearchField(searchText: $searchText)
                .frame(width: 320)
                .workspaceComponentPreviewSurface()
        }
    }

    private struct WorkspaceIPadProviderPickerRowsPreview: View {
        @State private var selectedProviderID = WorkspacePreviewSupport.defaultProviders.first?.id

        var body: some View {
            VStack(spacing: 8) {
                ForEach(WorkspacePreviewSupport.defaultProviders) { provider in
                    WorkspaceIPadProviderPickerRow(
                        provider: provider,
                        isSelected: provider.id == selectedProviderID
                    ) {
                        selectedProviderID = provider.id
                    }
                }
            }
            .frame(width: 320)
            .workspaceComponentPreviewSurface()
        }
    }

    private struct WorkspaceIPadProviderConnectionPopupPreview: View {
        var body: some View {
            WorkspaceIPadProviderConnectionPopup(
                provider: WorkspacePreviewSupport.defaultProviders[0],
                dismiss: { },
                back: { },
                connect: { _ in }
            )
            .workspaceComponentPreviewSurface()
        }
    }

    private struct WorkspaceIPadProviderConnectionMethodPickerPreview: View {
        @State private var selectedMethod: AIProviderConnectionMethod = .apiKey

        var body: some View {
            WorkspaceIPadProviderConnectionMethodPicker(
                methods: WorkspacePreviewSupport.defaultProviders[0].availableConnectionMethods,
                selectedMethod: $selectedMethod
            )
            .frame(width: 320)
            .workspaceComponentPreviewSurface()
        }
    }

    #Preview("Provider Picker Popup Component") {
        WorkspaceIPadProviderPickerPopupPreview()
    }

    #Preview("Provider Picker Header Component") {
        WorkspaceIPadProviderPickerHeader(dismiss: { })
            .frame(width: 320)
            .workspaceComponentPreviewSurface()
    }

    #Preview("Provider Search Field Component") {
        WorkspaceIPadProviderSearchFieldPreview()
    }

    #Preview("Provider Picker Rows Component") {
        WorkspaceIPadProviderPickerRowsPreview()
    }

    #Preview("Provider Empty State Component") {
        WorkspaceIPadProviderEmptyState(searchText: "OpenRouter")
            .frame(width: 320)
            .workspaceComponentPreviewSurface()
    }

    #Preview("Provider Connection Popup Component") {
        WorkspaceIPadProviderConnectionPopupPreview()
    }

    #Preview("Provider Connection Navigation Component") {
        WorkspaceIPadProviderConnectionNavigation(dismiss: { }, back: { })
            .frame(width: 320)
            .workspaceComponentPreviewSurface()
    }

    #Preview("Provider Connection Method Component") {
        WorkspaceIPadProviderConnectionMethodPickerPreview()
    }

    #Preview("Provider Connection Footer Component") {
        WorkspaceIPadProviderConnectionFooter(
            title: "Continue",
            isDisabled: false,
            action: { }
        )
        .frame(width: 320)
        .workspaceComponentPreviewSurface()
    }
#endif
