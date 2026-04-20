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
      Image(systemName: "sparkles.rectangle.stack.fill")
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(Color(red: 0.08, green: 0.13, blue: 0.15))
        .frame(width: 38, height: 38)
        .background(Circle().fill(Color.white.opacity(0.5)))

      Text("OpenSpace")
        .font(.headline.weight(.semibold))
        .foregroundStyle(Color(red: 0.08, green: 0.13, blue: 0.15))
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
