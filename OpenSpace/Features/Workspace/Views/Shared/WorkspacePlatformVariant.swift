//
//  WorkspacePlatformVariant.swift
//  OpenSpace
//
//  Created by Codex on 22/04/26.
//

import SwiftUI

enum WorkspacePlatformVariant {
  case ios
  case ipad
  case mac

  var identifierPrefix: String {
    switch self {
    case .ios:
      "workspace.ios"
    case .ipad:
      "workspace.ipad"
    case .mac:
      "workspace.mac"
    }
  }
}
