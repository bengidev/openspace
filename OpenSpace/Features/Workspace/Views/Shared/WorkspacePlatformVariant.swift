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

    // MARK: Internal

    static var current: WorkspacePlatformVariant {
        UIDevice.current.userInterfaceIdiom == .pad ? .ipad : .ios
    }

    var identifierPrefix: String {
        switch self {
        case .ios:
            "workspace.ios"
        case .ipad:
            "workspace.ipad"
        }
    }
}
