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
        #if os(iOS)
            UIDevice.current.userInterfaceIdiom == .pad ? .ipad : .ios
        #else
            .ios
        #endif
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
