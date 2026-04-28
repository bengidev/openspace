//
//  WorkspaceIOSProviderPopupState.swift
//  OpenSpace
//
//  iPhone-focused provider popup routing state.
//

import SwiftUI

enum WorkspaceIOSProviderPopup: Identifiable {
    case picker
    case connection(AIProvider)

    var id: String {
        switch self {
        case .picker:
            "picker"
        case let .connection(provider):
            "connection-\(provider.id)"
        }
    }
}
