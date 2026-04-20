//
//  OnboardingMacHeaderView.swift
//  OpenSpace
//
//  Created by Codex on 18/04/26.
//

import SwiftUI

struct OnboardingMacHeaderView: View {
  var body: some View {
    HStack(spacing: 16) {
      HStack(spacing: 7) {
        Circle()
          .fill(Color(red: 0.95, green: 0.42, blue: 0.35))
        Circle()
          .fill(Color(red: 0.96, green: 0.74, blue: 0.26))
        Circle()
          .fill(Color(red: 0.35, green: 0.77, blue: 0.36))
      }
      .frame(width: 44, height: 12)

      Text("OpenSpace for macOS")
        .font(.caption.weight(.semibold))
        .foregroundStyle(Color(red: 0.12, green: 0.17, blue: 0.19))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.white.opacity(0.56)))

      Spacer()

      Text("ABSTRACT VIEW")
        .font(.caption2.monospaced().weight(.medium))
        .foregroundStyle(Color(red: 0.12, green: 0.17, blue: 0.19).opacity(0.72))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.white.opacity(0.42)))
    }
  }
}
