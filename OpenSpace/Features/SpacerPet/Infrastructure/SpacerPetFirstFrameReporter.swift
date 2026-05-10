//
//  SpacerPetFirstFrameReporter.swift
//  OpenSpace
//

import SceneKit
import UIKit

extension Notification.Name {
    static let spacerPetSceneDidLoadFirstFrame = Notification.Name("SpacerPetSceneDidLoadFirstFrame")
}

final class SpacerPetFirstFrameLoadReporter: NSObject, SCNSceneRendererDelegate {
    private let loadIdentifier: UUID
    private let lock = NSLock()
    private var didReportFirstFrame = false

    init(loadIdentifier: UUID) {
        self.loadIdentifier = loadIdentifier
    }

    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        lock.lock()
        let shouldReport = !didReportFirstFrame
        didReportFirstFrame = true
        lock.unlock()

        guard shouldReport else {
            return
        }

        NotificationCenter.default.post(
            name: .spacerPetSceneDidLoadFirstFrame,
            object: loadIdentifier
        )
    }
}
