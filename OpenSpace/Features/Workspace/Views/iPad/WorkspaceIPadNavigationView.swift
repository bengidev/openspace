//
//  WorkspaceIPadNavigationView.swift
//  OpenSpace
//
//  Created by Codex on 23/04/26.
//

import SwiftUI

struct WorkspaceIPadIconRail: View {
  @Environment(\.colorScheme) private var colorScheme
  let context: WorkspaceRenderContext
  let bindings: WorkspaceViewBindings

  private var selectedDestination: WorkspaceDestination {
    bindings.selectedDestination.wrappedValue
  }

  private var primaryDestinations: [WorkspaceDestination] {
    WorkspaceDestination.allCases.filter { $0.navigationPlacement == .primary }
  }

  private var utilityDestinations: [WorkspaceDestination] {
    WorkspaceDestination.allCases.filter { $0.navigationPlacement == .utility }
  }

  var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 14) {
        WorkspaceIPadRailBrandButton()

        VStack(spacing: context.railItemSpacing) {
          ForEach(primaryDestinations, id: \.self) { destination in
            WorkspaceIPadRailButton(
              title: destination.rawValue,
              systemImage: destination.systemImage,
              isSelected: destination == selectedDestination
            ) {
              bindings.selectedDestination.wrappedValue = destination
            }
          }
        }
      }

      Spacer(minLength: 0)

      VStack(spacing: context.railItemSpacing) {
        Button(action: bindings.replayOnboarding) {
          Image(systemName: "arrow.counterclockwise")
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(WorkspacePalette.secondaryText)
            .frame(width: 42, height: 42)
            .background(
              RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(WorkspacePalette.panelSecondary(for: colorScheme))
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Replay onboarding")

        ForEach(utilityDestinations, id: \.self) { destination in
          WorkspaceIPadRailButton(
            title: destination.rawValue,
            systemImage: destination.systemImage,
            isSelected: destination == selectedDestination
          ) {
            bindings.selectedDestination.wrappedValue = destination
          }
        }
      }
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 14)
    .accessibilityIdentifier("\(context.variant.identifierPrefix).rail")
  }
}

struct WorkspaceIPadCompactNavigation: View {
  @Environment(\.colorScheme) private var colorScheme
  @Binding var selectedDestination: WorkspaceDestination

  private var destinations: [WorkspaceDestination] {
    WorkspaceDestination.allCases.filter { $0.navigationPlacement == .primary }
  }

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(destinations, id: \.self) { destination in
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
                .fill(
                  destination == selectedDestination
                    ? WorkspacePalette.sidebarSelection(for: colorScheme)
                    : WorkspacePalette.panelSecondary(for: colorScheme)
                )
            )
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.bottom, 2)
    }
    .scrollClipDisabled()
  }
}

private struct WorkspaceIPadRailBrandButton: View {
  var body: some View {
    ZStack {
      Circle()
        .fill(
          RadialGradient(
            colors: [
              Color.white.opacity(0.92),
              WorkspacePalette.sidebarSelection(for: .light),
            ],
            center: .center,
            startRadius: 2,
            endRadius: 24
          )
        )

      Image(systemName: "sparkle")
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(WorkspacePalette.primaryText)
    }
    .frame(width: 36, height: 36)
    .accessibilityLabel("OpenSpace home")
  }
}

private struct WorkspaceIPadRailButton: View {
  @Environment(\.colorScheme) private var colorScheme
  let title: String
  let systemImage: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(systemName: systemImage)
        .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
        .foregroundStyle(isSelected ? WorkspacePalette.accentGradientEnd : WorkspacePalette.secondaryText)
        .frame(width: 38, height: 38)
        .background(
          RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(isSelected ? WorkspacePalette.sidebarSelection(for: colorScheme) : Color.clear)
        )
        .overlay(
          RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(isSelected ? WorkspacePalette.cardStroke(for: colorScheme) : Color.clear, lineWidth: 1)
        )
    }
    .buttonStyle(.plain)
    .accessibilityLabel(title)
    .accessibilityAddTraits(isSelected ? [.isSelected] : [])
  }
}

#Preview("iPad Workspace Rail") {
  WorkspacePreviewSupport.preview(
    variant: .ipad,
    size: CGSize(width: 1024, height: 820),
    selectedDestination: .agents
  ) { context, bindings in
    WorkspaceIPadIconRail(context: context, bindings: bindings)
      .frame(width: context.sidebarWidth, height: context.minimumShellHeight)
      .background(WorkspacePalette.sidebarBackground(for: .light))
      .padding(24)
  }
  .workspacePreviewSurface(size: CGSize(width: 240, height: 820))
}

#Preview("iPad Compact Navigation") {
  WorkspacePreviewSupport.preview(
    variant: .ipad,
    size: CGSize(width: 744, height: 1133),
    selectedDestination: .threads
  ) { _, bindings in
    WorkspaceIPadCompactNavigation(selectedDestination: bindings.selectedDestination)
      .padding(24)
  }
  .workspacePreviewSurface(size: CGSize(width: 744, height: 180))
}
