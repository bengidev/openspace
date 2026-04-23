//
//  WorkspaceMacContentViews.swift
//  OpenSpace
//
//  Created by Codex on 23/04/26.
//

import SwiftUI

struct WorkspaceMacMainContent: View {
  let context: WorkspaceRenderContext
  let bindings: WorkspaceViewBindings

  private var selectedDestination: WorkspaceDestination {
    bindings.selectedDestination.wrappedValue
  }

  var body: some View {
    VStack(alignment: .leading, spacing: context.mainSectionSpacing) {
      WorkspaceMacUtilityBar(context: context, bindings: bindings)
        .accessibilityIdentifier("\(context.variant.identifierPrefix).topbar")

      VStack(spacing: context.heroSectionSpacing) {
        WorkspaceMacHeroOrb()
        WorkspaceMacHeroHeading(context: context, destination: selectedDestination)

        Text(selectedDestination.heroBody)
          .font(.body)
          .foregroundStyle(WorkspacePalette.secondaryText)
          .multilineTextAlignment(.center)
          .frame(maxWidth: context.heroCopyMaxWidth)

        WorkspaceMacComposerCard(
          context: context,
          destination: selectedDestination,
          selectedWritingStyle: bindings.selectedWritingStyle,
          citationEnabled: bindings.citationEnabled,
          selectedPrompt: bindings.selectedPrompt,
          isPromptFocused: bindings.isPromptFocused
        )
        .frame(maxWidth: context.composerMaxWidth)
        .accessibilityIdentifier("\(context.variant.identifierPrefix).composer")

        WorkspaceMacQuickPromptSection(
          context: context,
          highlightedQuickPrompt: bindings.highlightedQuickPrompt,
          selectedPrompt: bindings.selectedPrompt,
          isPromptFocused: bindings.isPromptFocused
        )
        .frame(maxWidth: context.quickPromptMaxWidth)
        .accessibilityIdentifier("\(context.variant.identifierPrefix).examples")
      }
      .frame(maxWidth: .infinity)
      .padding(.top, context.heroTopSpacing)

      Spacer(minLength: 0)
    }
    .padding(.horizontal, context.mainHorizontalPadding)
    .padding(.vertical, context.mainVerticalPadding)
  }
}

private struct WorkspaceMacUtilityBar: View {
  @Environment(\.colorScheme) private var colorScheme
  let context: WorkspaceRenderContext
  let bindings: WorkspaceViewBindings

  var body: some View {
    HStack(spacing: context.contentTopBarSpacing) {
      Menu {
        Picker("Model", selection: bindings.selectedModel) {
          ForEach(WorkspaceModel.allCases) { model in
            Text(model.rawValue).tag(model)
          }
        }
      } label: {
        HStack(spacing: 8) {
          Image(systemName: "sparkles")
            .font(.system(size: 12, weight: .semibold))

          Text(bindings.selectedModel.wrappedValue.rawValue)
            .lineLimit(1)

          Image(systemName: "chevron.down")
            .font(.system(size: 10, weight: .semibold))
        }
        .font(.subheadline.weight(.medium))
        .foregroundStyle(WorkspacePalette.primaryText)
        .padding(.horizontal, 15)
        .padding(.vertical, 11)
        .background(Capsule().fill(WorkspacePalette.panelBackground(for: colorScheme)))
        .overlay(
          Capsule()
            .stroke(WorkspacePalette.cardStroke(for: colorScheme), lineWidth: 1)
        )
      }
      .buttonStyle(.plain)

      Spacer(minLength: 0)

      WorkspaceMacBarButton(title: "Search thread", systemImage: "magnifyingglass")
      WorkspaceMacBarButton(title: "Invite", systemImage: "person.badge.plus")

      Button {} label: {
        HStack(spacing: 8) {
          Image(systemName: "plus")
          Text("New Thread")
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(WorkspacePalette.primaryButtonForeground(for: colorScheme))
        .padding(.horizontal, 17)
        .padding(.vertical, 11)
        .background(Capsule().fill(WorkspacePalette.primaryButtonBackground(for: colorScheme)))
      }
      .buttonStyle(.plain)
      .accessibilityLabel("New thread")
    }
  }
}

private struct WorkspaceMacBarButton: View {
  @Environment(\.colorScheme) private var colorScheme
  let title: String
  let systemImage: String

  var body: some View {
    Button {} label: {
      HStack(spacing: 8) {
        Image(systemName: systemImage)
          .font(.system(size: 13, weight: .medium))

        Text(title)
          .font(.subheadline.weight(.medium))
      }
      .foregroundStyle(WorkspacePalette.primaryText)
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(Capsule().fill(WorkspacePalette.panelBackground(for: colorScheme)))
      .overlay(
        Capsule()
          .stroke(WorkspacePalette.cardStroke(for: colorScheme), lineWidth: 1)
      )
    }
    .buttonStyle(.plain)
    .accessibilityLabel(title)
  }
}

private struct WorkspaceMacHeroOrb: View {
  var body: some View {
    Circle()
      .fill(
        RadialGradient(
          colors: [
            Color.white.opacity(0.75),
            WorkspacePalette.orbCore,
            WorkspacePalette.orbEdge,
          ],
          center: .topLeading,
          startRadius: 2,
          endRadius: 42
        )
      )
      .overlay(Circle().stroke(Color.white.opacity(0.55), lineWidth: 1))
      .frame(width: 54, height: 54)
      .shadow(color: WorkspacePalette.orbEdge.opacity(0.24), radius: 18, x: 0, y: 12)
      .shadow(color: WorkspacePalette.orbCore.opacity(0.16), radius: 28, x: 0, y: 0)
      .overlay(Circle().stroke(ThemeColor.accent100.opacity(0.34), lineWidth: 1))
      .accessibilityHidden(true)
  }
}

private struct WorkspaceMacHeroHeading: View {
  let context: WorkspaceRenderContext
  let destination: WorkspaceDestination

  var body: some View {
    VStack(spacing: 2) {
      Text(destination.heroFirstLine)
        .font(context.heroTitleFont)
        .foregroundStyle(WorkspacePalette.primaryText)
        .multilineTextAlignment(.center)
        .lineLimit(1)
        .minimumScaleFactor(0.8)

      HStack(spacing: 0) {
        if !destination.heroSecondLineLeading.isEmpty {
          Text(destination.heroSecondLineLeading)
            .foregroundStyle(WorkspacePalette.primaryText)
        }

        Text(destination.heroAccentText)
          .foregroundStyle(
            LinearGradient(
              colors: [
                WorkspacePalette.accentGradientStart,
                WorkspacePalette.accentGradientEnd,
              ],
              startPoint: .leading,
              endPoint: .trailing
            )
          )
      }
      .font(context.heroTitleFont)
      .frame(maxWidth: .infinity, alignment: .center)
      .lineLimit(1)
      .minimumScaleFactor(0.8)
    }
    .frame(maxWidth: 900)
    .fixedSize(horizontal: false, vertical: true)
  }
}

private struct WorkspaceMacComposerCard: View {
  @Environment(\.colorScheme) private var colorScheme
  let context: WorkspaceRenderContext
  let destination: WorkspaceDestination
  @Binding var selectedWritingStyle: WorkspaceWritingStyle
  @Binding var citationEnabled: Bool
  @Binding var selectedPrompt: String
  @FocusState.Binding var isPromptFocused: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      ZStack(alignment: .topLeading) {
        if selectedPrompt.isEmpty {
          Text(destination.composerPlaceholder)
            .font(.title3)
            .foregroundStyle(WorkspacePalette.tertiaryText(for: colorScheme))
            .padding(.horizontal, 2)
            .allowsHitTesting(false)
        }

        TextField("", text: $selectedPrompt, axis: .vertical)
          .textFieldStyle(.plain)
          .font(.title3)
          .foregroundStyle(WorkspacePalette.primaryText)
          .focused($isPromptFocused)
          .lineLimit(4...8)
      }
      .frame(minHeight: 104, alignment: .topLeading)
      .contentShape(Rectangle())
      .onTapGesture {
        isPromptFocused = true
      }

      Divider()
        .overlay(WorkspacePalette.cardStroke(for: colorScheme))

      HStack(alignment: .center, spacing: 12) {
        HStack(spacing: 10) {
          WorkspaceMacSurfaceChip(title: "Attach", systemImage: "paperclip")

          Menu {
            Picker("Writing style", selection: $selectedWritingStyle) {
              ForEach(WorkspaceWritingStyle.allCases) { style in
                Text(style.rawValue).tag(style)
              }
            }
          } label: {
            HStack(spacing: 8) {
              Text(selectedWritingStyle.rawValue)
              Image(systemName: "chevron.down")
                .font(.system(size: 10, weight: .semibold))
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(WorkspacePalette.primaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Capsule().fill(WorkspacePalette.panelBackground(for: colorScheme)))
            .overlay(
              Capsule()
                .stroke(WorkspacePalette.cardStroke(for: colorScheme), lineWidth: 1)
            )
          }
          .buttonStyle(.plain)
        }

        Spacer(minLength: 0)

        HStack(spacing: 8) {
          Toggle("", isOn: $citationEnabled)
            .labelsHidden()
            .toggleStyle(.switch)
            .tint(WorkspacePalette.accentGradientEnd)
            .scaleEffect(0.84)

          Text("Citation")
            .font(.subheadline.weight(.medium))
            .foregroundStyle(WorkspacePalette.primaryText)
        }

        Button {} label: {
          Image(systemName: "arrow.up")
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(WorkspacePalette.primaryButtonForeground(for: colorScheme))
            .frame(width: 42, height: 42)
            .background(Circle().fill(WorkspacePalette.primaryButtonBackground(for: colorScheme)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Send prompt")
      }
    }
    .padding(18)
    .background(
      RoundedRectangle(cornerRadius: 22, style: .continuous)
        .fill(WorkspacePalette.panelBackground(for: colorScheme))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 22, style: .continuous)
        .stroke(WorkspacePalette.cardStroke(for: colorScheme), lineWidth: 1)
    )
    .shadow(color: WorkspacePalette.shadow(for: colorScheme), radius: 18, x: 0, y: 14)
  }
}

private struct WorkspaceMacSurfaceChip: View {
  @Environment(\.colorScheme) private var colorScheme
  let title: String
  let systemImage: String

  var body: some View {
    Button {} label: {
      HStack(spacing: 8) {
        Image(systemName: systemImage)
          .font(.system(size: 13, weight: .semibold))

        Text(title)
          .font(.subheadline.weight(.medium))
      }
      .foregroundStyle(WorkspacePalette.primaryText)
      .padding(.horizontal, 14)
      .padding(.vertical, 10)
      .background(Capsule().fill(WorkspacePalette.panelBackground(for: colorScheme)))
      .overlay(
        Capsule()
          .stroke(WorkspacePalette.cardStroke(for: colorScheme), lineWidth: 1)
      )
    }
    .buttonStyle(.plain)
    .accessibilityLabel(title)
  }
}

private struct WorkspaceMacQuickPromptSection: View {
  @Environment(\.colorScheme) private var colorScheme
  let context: WorkspaceRenderContext
  @Binding var highlightedQuickPrompt: WorkspaceQuickPrompt?
  @Binding var selectedPrompt: String
  @FocusState.Binding var isPromptFocused: Bool

  private var columns: [GridItem] {
    [GridItem(.adaptive(minimum: context.exampleGridMinWidth), spacing: 14)]
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("GET STARTED WITH AN EXAMPLE BELOW")
        .font(.caption.weight(.semibold))
        .tracking(1.2)
        .foregroundStyle(WorkspacePalette.secondaryText)

      LazyVGrid(columns: columns, alignment: .leading, spacing: 14) {
        ForEach(WorkspaceQuickPrompt.allCases) { prompt in
          Button {
            highlightedQuickPrompt = prompt
            selectedPrompt = prompt.rawValue
            isPromptFocused = true
          } label: {
            VStack(alignment: .leading, spacing: 18) {
              Text(prompt.rawValue)
                .font(.headline.weight(.medium))
                .foregroundStyle(WorkspacePalette.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

              Spacer(minLength: 0)

              Image(systemName: prompt.symbolName)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(
                  highlightedQuickPrompt == prompt
                    ? WorkspacePalette.accentGradientEnd
                    : WorkspacePalette.primaryText
                )
            }
            .padding(16)
            .frame(minHeight: 128, alignment: .topLeading)
            .background(
              RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                  highlightedQuickPrompt == prompt
                    ? WorkspacePalette.sidebarSelection(for: colorScheme)
                    : WorkspacePalette.panelSecondary(for: colorScheme)
                )
            )
            .overlay(
              RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                  highlightedQuickPrompt == prompt
                    ? WorkspacePalette.accentGradientEnd.opacity(0.28)
                    : WorkspacePalette.cardStroke(for: colorScheme),
                  lineWidth: 1
                )
            )
          }
          .buttonStyle(.plain)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview("Mac Workspace Content") {
  WorkspacePreviewSupport.preview(
    variant: .mac,
    size: CGSize(width: 1280, height: 820),
    selectedDestination: .home,
    selectedPrompt: "Plan the next three steps for the release candidate.",
    highlightedQuickPrompt: .articleSummary
  ) { context, bindings in
    WorkspaceMacMainContent(context: context, bindings: bindings)
      .frame(width: 1160, height: context.minimumShellHeight, alignment: .topLeading)
      .padding(24)
  }
  .workspacePreviewSurface(size: CGSize(width: 1240, height: 820))
}
