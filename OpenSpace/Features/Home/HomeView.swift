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
            
            VStack {
                Text("OpenSpace")
                    .font(.system(size: 42, weight: .regular))
                    .tracking(-1.2)
                    .foregroundStyle(palette.textPrimary)
                
                Text("Hi! How can i help you?")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundStyle(palette.textSecondary)
                    .lineLimit(1)
                    .padding(.top, 10)
                
                Text("Chat are End-to-end encrypted. Your data is safe.")
                    .font(.system(size: 8, weight: .regular))
                    .foregroundStyle(palette.textSecondary)
                    .padding(.top, 3)
                
                Text("Your data is safe.")
                    .font(.system(size: 8, weight: .regular))
                    .foregroundStyle(palette.textSecondary)
            }
            .minimumScaleFactor(0.7)
            .padding(28)
        }
    }
}

#Preview {
    HomeView()
}
