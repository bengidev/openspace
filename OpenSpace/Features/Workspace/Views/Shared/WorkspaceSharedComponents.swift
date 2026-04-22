//
//  WorkspaceSharedComponents.swift
//  OpenSpace
//
//  Created by Codex on 22/04/26.
//

import SwiftUI

struct WorkspaceRegularShell: View {
  let context: WorkspaceRenderContext
  let bindings: WorkspaceViewBindings

  var body: some View {
    HStack(spacing: 0) {
      WorkspaceSidebar(context: context, bindings: bindings)
        .frame(width: context.sidebarWidth)
        .background(WorkspacePalette.sidebarBackground)

      Rectangle()
        .fill(WorkspacePalette.border)
        .frame(width: 1)

      WorkspaceMainContent(context: context, bindings: bindings)
    }
    .frame(maxWidth: .infinity, minHeight: context.minimumShellHeight, alignment: .topLeading)
    .workspaceShellStyle(cornerRadius: context.shellCornerRadius)
  }
}

struct WorkspaceCompactShell: View {
  let context: WorkspaceRenderContext
  let bindings: WorkspaceViewBindings

  var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 16) {
        WorkspaceCompactHeader(replayOnboarding: bindings.replayOnboarding)
        WorkspaceCompactNavigation(selectedDestination: bindings.selectedDestination)
      }
      .padding(.horizontal, 18)
      .padding(.top, 18)
      .padding(.bottom, 12)
      .background(WorkspacePalette.sidebarBackground)

      Rectangle()
        .fill(WorkspacePalette.border)
        .frame(height: 1)

      WorkspaceMainContent(context: context, bindings: bindings)
    }
    .workspaceShellStyle(cornerRadius: context.shellCornerRadius)
  }
}

struct WorkspaceMainContent: View {
  let context: WorkspaceRenderContext
  let bindings: WorkspaceViewBindings

  private var selectedDestination: WorkspaceDestination {
    bindings.selectedDestination.wrappedValue
  }

  var body: some View {
    VStack(alignment: .leading, spacing: context.mainSectionSpacing) {
      WorkspaceMainHeader(
        title: selectedDestination.rawValue,
        subtitle: selectedDestination.subtitle
      )

      VStack(spacing: context.usesSidebar ? 22 : 18) {
        VStack(spacing: 8) {
          Text(selectedDestination.heroTitle)
            .font(context.heroTitleFont)
            .foregroundStyle(WorkspacePalette.primaryText)
            .multilineTextAlignment(.center)

          Text(selectedDestination.heroBody)
            .font(.subheadline)
            .foregroundStyle(WorkspacePalette.secondaryText)
            .multilineTextAlignment(.center)
            .frame(maxWidth: context.heroCopyMaxWidth)
        }

        WorkspaceComposerCard(
          destination: selectedDestination,
          selectedModel: bindings.selectedModel,
          selectedPrompt: bindings.selectedPrompt,
          selectedStyleChips: bindings.selectedStyleChips,
          toneValue: bindings.toneValue,
          isRandomized: bindings.isRandomized,
          isPromptFocused: bindings.isPromptFocused
        )
        .frame(maxWidth: context.composerMaxWidth)
      }
      .frame(maxWidth: .infinity)
      .padding(.top, context.usesSidebar ? 20 : 4)

      WorkspaceQuickPromptSection(
        highlightedQuickPrompt: bindings.highlightedQuickPrompt,
        selectedPrompt: bindings.selectedPrompt,
        isPromptFocused: bindings.isPromptFocused
      )
      .frame(maxWidth: context.quickPromptMaxWidth)
      .frame(maxWidth: .infinity, alignment: .center)

      if context.usesSidebar {
        Spacer(minLength: 0)
      }
    }
    .padding(.horizontal, context.mainHorizontalPadding)
    .padding(.vertical, context.mainVerticalPadding)
  }
}

private struct WorkspaceSidebar: View {
  let context: WorkspaceRenderContext
  let bindings: WorkspaceViewBindings

  private let sectionOrder: [WorkspaceSidebarSection] = [.create, .library, .support]

  private var selectedDestination: WorkspaceDestination {
    bindings.selectedDestination.wrappedValue
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 22) {
      HStack(spacing: 10) {
        ZStack {
          Circle()
            .fill(
              LinearGradient(
                colors: [
                  WorkspacePalette.accent.opacity(0.95),
                  Color(red: 0.95, green: 0.76, blue: 0.49),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )

          Image(systemName: "sparkles")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.white)
        }
        .frame(width: 30, height: 30)

        VStack(alignment: .leading, spacing: 2) {
          Text("OpenSpace")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(WorkspacePalette.primaryText)

          Text("Creative workspace")
            .font(.caption)
            .foregroundStyle(WorkspacePalette.secondaryText)
        }

        Spacer(minLength: 0)

        Button {} label: {
          Image(systemName: "chevron.left.chevron.right")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(WorkspacePalette.secondaryText)
            .frame(width: 28, height: 28)
            .background(Circle().fill(Color.white.opacity(0.78)))
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Toggle workspace sidebar")
      }

      ForEach(sectionOrder, id: \.self) { section in
        VStack(alignment: .leading, spacing: 8) {
          Text(section.rawValue.uppercased())
            .font(.caption2.weight(.semibold))
            .foregroundStyle(WorkspacePalette.tertiaryText)
            .tracking(0.8)

          ForEach(WorkspaceDestination.allCases.filter { $0.section == section }, id: \.self) { destination in
            WorkspaceSidebarRow(
              title: destination.rawValue,
              symbolName: destination.systemImage,
              isSelected: destination == selectedDestination
            ) {
              bindings.selectedDestination.wrappedValue = destination
            }
          }
        }
      }

      Spacer(minLength: 0)

      Button(action: bindings.replayOnboarding) {
        HStack(spacing: 8) {
          Image(systemName: "arrow.counterclockwise")
            .font(.system(size: 12, weight: .semibold))

          Text("Replay onboarding")
            .font(.caption.weight(.semibold))
        }
        .foregroundStyle(WorkspacePalette.primaryText)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Capsule().fill(Color.white.opacity(0.88)))
        .contentShape(Capsule())
      }
      .buttonStyle(.plain)

      HStack(spacing: 10) {
        Circle()
          .fill(Color(red: 0.87, green: 0.69, blue: 0.57))
          .overlay(
            Text("BT")
              .font(.caption.weight(.bold))
              .foregroundStyle(Color.white)
          )
          .frame(width: 34, height: 34)

        VStack(alignment: .leading, spacing: 2) {
          Text("Bambang Tri")
            .font(.caption.weight(.semibold))
            .foregroundStyle(WorkspacePalette.primaryText)

          Text("My workspace")
            .font(.caption2)
            .foregroundStyle(WorkspacePalette.secondaryText)
        }

        Spacer(minLength: 0)

        Image(systemName: "chevron.right")
          .font(.system(size: 10, weight: .bold))
          .foregroundStyle(WorkspacePalette.tertiaryText)
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 10)
      .background(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .fill(Color.white.opacity(0.75))
      )
    }
    .padding(18)
    .accessibilityIdentifier("\(context.variant.identifierPrefix).sidebar")
  }
}

private struct WorkspaceSidebarRow: View {
  let title: String
  let symbolName: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 10) {
        Image(systemName: symbolName)
          .font(.system(size: 13, weight: .medium))
          .frame(width: 16)

        Text(title)
          .font(.caption.weight(.medium))

        Spacer(minLength: 0)
      }
      .foregroundStyle(isSelected ? WorkspacePalette.primaryText : WorkspacePalette.secondaryText)
      .padding(.horizontal, 12)
      .padding(.vertical, 10)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .fill(isSelected ? WorkspacePalette.sidebarSelection : Color.clear)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .stroke(isSelected ? WorkspacePalette.cardStroke : Color.clear, lineWidth: 1)
      )
      .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    .buttonStyle(.plain)
    .accessibilityAddTraits(isSelected ? [.isSelected] : [])
  }
}

private struct WorkspaceCompactHeader: View {
  let replayOnboarding: () -> Void

  var body: some View {
    HStack(spacing: 12) {
      HStack(spacing: 10) {
        ZStack {
          Circle()
            .fill(
              LinearGradient(
                colors: [
                  WorkspacePalette.accent,
                  Color(red: 0.95, green: 0.76, blue: 0.49),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )

          Image(systemName: "sparkles")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.white)
        }
        .frame(width: 32, height: 32)

        VStack(alignment: .leading, spacing: 2) {
          Text("OpenSpace")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(WorkspacePalette.primaryText)

          Text("Workspace")
            .font(.caption)
            .foregroundStyle(WorkspacePalette.secondaryText)
        }
      }

      Spacer(minLength: 0)

      Button(action: replayOnboarding) {
        Text("Replay")
          .font(.caption.weight(.semibold))
          .foregroundStyle(WorkspacePalette.primaryText)
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .background(Capsule().fill(Color.white.opacity(0.86)))
          .contentShape(Capsule())
      }
      .buttonStyle(.plain)
    }
  }
}

private struct WorkspaceCompactNavigation: View {
  @Binding var selectedDestination: WorkspaceDestination

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(WorkspaceDestination.allCases.filter { $0.section != .support }, id: \.self) { destination in
          Button {
            selectedDestination = destination
          } label: {
            HStack(spacing: 8) {
              Image(systemName: destination.systemImage)
                .font(.system(size: 12, weight: .medium))

              Text(destination.rawValue)
                .font(.caption.weight(.semibold))
            }
            .foregroundStyle(
              destination == selectedDestination
                ? WorkspacePalette.primaryText
                : WorkspacePalette.secondaryText
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
              Capsule()
                .fill(destination == selectedDestination ? Color.white.opacity(0.92) : Color.white.opacity(0.54))
            )
            .contentShape(Capsule())
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.bottom, 2)
    }
    .scrollClipDisabled()
  }
}

private struct WorkspaceMainHeader: View {
  let title: String
  let subtitle: String

  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      VStack(alignment: .leading, spacing: 3) {
        Text(title)
          .font(.title3.weight(.semibold))
          .foregroundStyle(WorkspacePalette.primaryText)

        Text(subtitle)
          .font(.caption)
          .foregroundStyle(WorkspacePalette.secondaryText)
      }

      Spacer(minLength: 0)

      Button {} label: {
        Text("Report Bug")
          .font(.caption.weight(.semibold))
          .foregroundStyle(WorkspacePalette.secondaryText)
          .padding(.horizontal, 12)
          .padding(.vertical, 9)
          .background(Capsule().fill(Color.white.opacity(0.76)))
          .overlay(
            Capsule()
              .stroke(WorkspacePalette.cardStroke, lineWidth: 1)
          )
          .contentShape(Capsule())
      }
      .buttonStyle(.plain)
    }
  }
}

private struct WorkspaceComposerCard: View {
  let destination: WorkspaceDestination
  @Binding var selectedModel: WorkspaceModel
  @Binding var selectedPrompt: String
  @Binding var selectedStyleChips: Set<WorkspaceStyleChip>
  @Binding var toneValue: Double
  @Binding var isRandomized: Bool
  @FocusState.Binding var isPromptFocused: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack(spacing: 8) {
        Button {
          selectedPrompt = ""
          isPromptFocused = true
        } label: {
          HStack(spacing: 8) {
            Image(systemName: "plus")
            Text("Start new chat")
          }
          .font(.caption.weight(.medium))
          .foregroundStyle(WorkspacePalette.secondaryText)
          .padding(.horizontal, 12)
          .padding(.vertical, 10)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
              .fill(WorkspacePalette.panelSecondary)
          )
          .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
              .stroke(WorkspacePalette.cardStroke, lineWidth: 1)
          )
          .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)

        Menu {
          Picker("Model", selection: $selectedModel) {
            ForEach(WorkspaceModel.allCases) { model in
              Text(model.rawValue).tag(model)
            }
          }
        } label: {
          HStack(spacing: 6) {
            Text(selectedModel.rawValue)
            Image(systemName: "chevron.down")
              .font(.system(size: 10, weight: .semibold))
          }
          .font(.caption.weight(.semibold))
          .foregroundStyle(WorkspacePalette.primaryText)
          .padding(.horizontal, 12)
          .padding(.vertical, 10)
          .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
              .fill(Color.white)
          )
          .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
              .stroke(WorkspacePalette.cardStroke, lineWidth: 1)
          )
          .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)

        Button {} label: {
          Image(systemName: "slider.horizontal.3")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(WorkspacePalette.secondaryText)
            .frame(width: 38, height: 38)
            .background(
              RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
            )
            .overlay(
              RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(WorkspacePalette.cardStroke, lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Workspace controls")
      }

      ZStack(alignment: .topLeading) {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .fill(Color.white)
          .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
              .stroke(WorkspacePalette.cardStroke, lineWidth: 1)
          )

        if selectedPrompt.isEmpty {
          Text(destination.composerPlaceholder)
            .font(.subheadline)
            .foregroundStyle(WorkspacePalette.tertiaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .allowsHitTesting(false)
        }

        TextField("", text: $selectedPrompt, axis: .vertical)
          .textFieldStyle(.plain)
          .font(.subheadline)
          .foregroundStyle(WorkspacePalette.primaryText)
          .focused($isPromptFocused)
          .lineLimit(3...6)
          .padding(.horizontal, 14)
          .padding(.vertical, 14)
      }
      .frame(minHeight: 82, maxHeight: 120, alignment: .topLeading)
      .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
      .onTapGesture {
        isPromptFocused = true
      }

      WorkspaceChipScroller(
        items: WorkspaceStyleChip.allCases,
        selectedItems: $selectedStyleChips
      )

      HStack(alignment: .center, spacing: 12) {
        VStack(alignment: .leading, spacing: 8) {
          Text("Render tone")
            .font(.caption.weight(.semibold))
            .foregroundStyle(WorkspacePalette.secondaryText)

          HStack(spacing: 10) {
            Text("Artistic")
              .font(.caption2.weight(.medium))
              .foregroundStyle(WorkspacePalette.secondaryText)

            Slider(value: $toneValue, in: 0...1)
              .tint(WorkspacePalette.accent)

            Text("Realistic")
              .font(.caption2.weight(.medium))
              .foregroundStyle(WorkspacePalette.secondaryText)
          }
        }

        Spacer(minLength: 0)

        WorkspaceSecondaryPill(
          title: "Random",
          systemImage: "die.face.5",
          isSelected: isRandomized
        ) {
          isRandomized.toggle()
        }

        WorkspaceSecondaryPill(
          title: "Prompt Library",
          systemImage: "books.vertical"
        ) {}
      }
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .fill(WorkspacePalette.panelBackground)
    )
    .overlay(
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .stroke(WorkspacePalette.cardStroke, lineWidth: 1)
    )
    .shadow(color: WorkspacePalette.shadow, radius: 18, x: 0, y: 10)
  }
}

private struct WorkspaceChipScroller: View {
  let items: [WorkspaceStyleChip]
  @Binding var selectedItems: Set<WorkspaceStyleChip>

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(items, id: \.self) { item in
          Button {
            if selectedItems.contains(item) {
              selectedItems.remove(item)
            } else {
              selectedItems.insert(item)
            }
          } label: {
            HStack(spacing: 6) {
              if selectedItems.contains(item) {
                Image(systemName: "checkmark")
                  .font(.system(size: 10, weight: .bold))
              }

              Text(item.rawValue)
                .font(.caption.weight(.medium))
            }
            .foregroundStyle(
              selectedItems.contains(item)
                ? WorkspacePalette.primaryText
                : WorkspacePalette.secondaryText
            )
            .padding(.horizontal, 11)
            .padding(.vertical, 8)
            .background(
              Capsule()
                .fill(selectedItems.contains(item) ? WorkspacePalette.accentSoft : WorkspacePalette.panelSecondary)
            )
            .overlay(
              Capsule()
                .stroke(
                  selectedItems.contains(item) ? WorkspacePalette.accent.opacity(0.4) : WorkspacePalette.cardStroke,
                  lineWidth: 1
                )
            )
            .contentShape(Capsule())
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.bottom, 2)
    }
    .scrollClipDisabled()
  }
}

private struct WorkspaceSecondaryPill: View {
  let title: String
  let systemImage: String
  var isSelected = false
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 7) {
        Image(systemName: systemImage)
          .font(.system(size: 12, weight: .semibold))

        Text(title)
          .font(.caption.weight(.medium))
      }
      .foregroundStyle(isSelected ? WorkspacePalette.primaryText : WorkspacePalette.secondaryText)
      .padding(.horizontal, 11)
      .padding(.vertical, 9)
      .background(
        Capsule()
          .fill(isSelected ? WorkspacePalette.accentSoft : Color.white)
      )
      .overlay(
        Capsule()
          .stroke(isSelected ? WorkspacePalette.accent.opacity(0.4) : WorkspacePalette.cardStroke, lineWidth: 1)
      )
      .contentShape(Capsule())
    }
    .buttonStyle(.plain)
  }
}

private struct WorkspaceQuickPromptSection: View {
  @Binding var highlightedQuickPrompt: WorkspaceQuickPrompt?
  @Binding var selectedPrompt: String
  @FocusState.Binding var isPromptFocused: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Quick prompts")
        .font(.footnote.weight(.semibold))
        .foregroundStyle(WorkspacePalette.primaryText)

      LazyVGrid(
        columns: [
          GridItem(.adaptive(minimum: 132), spacing: 8),
        ],
        alignment: .leading,
        spacing: 8
      ) {
        ForEach(WorkspaceQuickPrompt.allCases, id: \.self) { prompt in
          Button {
            highlightedQuickPrompt = prompt
            selectedPrompt = prompt.rawValue
            isPromptFocused = true
          } label: {
            Text(prompt.rawValue)
              .font(.caption.weight(.medium))
              .foregroundStyle(
                highlightedQuickPrompt == prompt
                  ? WorkspacePalette.primaryText
                  : WorkspacePalette.secondaryText
              )
              .padding(.horizontal, 12)
              .padding(.vertical, 10)
              .frame(maxWidth: .infinity, alignment: .center)
              .background(
                Capsule()
                  .fill(highlightedQuickPrompt == prompt ? WorkspacePalette.accentSoft : Color.white.opacity(0.92))
              )
              .overlay(
                Capsule()
                  .stroke(
                    highlightedQuickPrompt == prompt ? WorkspacePalette.accent.opacity(0.4) : WorkspacePalette.cardStroke,
                    lineWidth: 1
                  )
              )
              .contentShape(Capsule())
          }
          .buttonStyle(.plain)
        }
      }

      Button {
        highlightedQuickPrompt = nil
        selectedPrompt = ""
        isPromptFocused = true
      } label: {
        Label("Refresh prompts", systemImage: "arrow.clockwise")
          .font(.caption.weight(.medium))
          .foregroundStyle(WorkspacePalette.secondaryText)
          .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
    }
  }
}

private extension View {
  func workspaceShellStyle(cornerRadius: CGFloat) -> some View {
    self
      .background(
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
          .fill(
            LinearGradient(
              colors: [
                WorkspacePalette.shellTop,
                WorkspacePalette.shellBottom,
              ],
              startPoint: .top,
              endPoint: .bottom
            )
          )
      )
      .overlay(
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
          .stroke(WorkspacePalette.shellStroke, lineWidth: 1)
      )
      .clipShape(.rect(cornerRadius: cornerRadius))
      .shadow(color: Color.black.opacity(0.22), radius: 36, x: 0, y: 26)
  }
}
