//
//  OnboardingIdentifierSupport.swift
//  OpenSpace
//
//  Created by Codex on 23/04/26.
//

import Foundation

extension String {
  var onboardingIdentifierSlug: String {
    lowercased()
      .map { character in
        character.isLetter || character.isNumber ? String(character) : "-"
      }
      .joined()
      .replacingOccurrences(of: "-+", with: "-", options: .regularExpression)
      .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
  }
}
