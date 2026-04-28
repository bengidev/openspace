//
//  WorkspacePlatformViewFactory.swift
//  OpenSpace
//
//  Abstract-factory facade for selecting platform-owned workspace shells.
//

import SwiftUI

enum WorkspacePlatformViewFactory {
    @ViewBuilder
    static func makeShell(
        for variant: WorkspacePlatformVariant,
        context: WorkspaceRenderContext,
        bindings: WorkspaceViewBindings
    ) -> some View {
        switch variant {
        case .ios:
            WorkspaceIOSShell(context: context, bindings: bindings)
        case .ipad:
            WorkspaceIPadShell(context: context, bindings: bindings)
        case .mac:
            WorkspaceMacShell(context: context, bindings: bindings)
        }
    }
}
