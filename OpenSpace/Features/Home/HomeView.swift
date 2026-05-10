//
//  HomeView.swift
//  OpenSpace
//
//  Created by Bambang Tri Rahmat Doni on 07/05/26.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let palette = OpenSpacePalette.resolve(colorScheme)

        ZStack {
            palette.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Text("Hi! How can I help you?")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundStyle(palette.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)

                Text("Chats are end-to-end encrypted.")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(palette.textSecondary)
                    .padding(.top, 10)

                Text("Your data is safe.")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(palette.textSecondary)
            }
            .padding(28)

            SpacerPetOverlay(palette: palette)
                .ignoresSafeArea(.keyboard)
        }
    }
}

#Preview {
    HomeView()
}
