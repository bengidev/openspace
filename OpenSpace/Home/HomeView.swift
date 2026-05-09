//
//  HomeView.swift
//  OpenSpace
//
//  Created by Bambang Tri Rahmat Doni on 07/05/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let palette = OpenSpacePalette.resolve(colorScheme)

        ZStack {
            palette.background
                .ignoresSafeArea()

            PixelGridBackground(palette: palette, spacing: 20, dotSize: 1.0, opacity: palette.isDark ? 0.06 : 0.04)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                FactoryBadge(title: "Workspace ready", systemImage: "checkmark.seal", palette: palette)

                Text("OpenSpace")
                    .font(.system(size: 42, weight: .regular))
                    .tracking(-1.2)
                    .foregroundStyle(palette.textPrimary)

                Text(
                    "Your AI-native command center. Deploy specialized agents to handle code, review, test, and ship — all within your existing workflow without context switching."
                )
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(palette.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: 420)

                HStack(spacing: 10) {
                    ForEach(["AGENTS", "PROMPTS", "MODELS", "REVIEW", "SHIP"], id: \.self) { item in
                        Text(item)
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .tracking(-0.24)
                            .foregroundStyle(palette.textSecondary)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 7)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(palette.surface.opacity(0.5))
                            )
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(palette.border, lineWidth: 1)
                            )
                    }
                }
                .minimumScaleFactor(0.7)
            }
            .padding(28)
        }
    }
}

#Preview {
    HomeView()
}
