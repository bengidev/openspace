//
//  SpacerPetSceneCoordinator.swift
//  OpenSpace
//

import SceneKit
import UIKit

@MainActor
final class SpacerPetSceneCoordinator {
    private enum NodeName {
        static let idle = "idle"
        static let motion = "motion"
        static let arm = "arm"
        static let foot = "foot"
        static let antenna = "antenna"
        static let eye = "eye"
    }

    private let firstFrameLoadReporter: SpacerPetFirstFrameLoadReporter
    private let scene = SCNScene()
    private let rootNode = SCNNode()
    private let petNode = SCNNode()
    private let headNode = SCNNode()
    private let rearShellNode = SCNNode()
    private let leftSideRidgeNode = SCNNode()
    private let rightSideRidgeNode = SCNNode()
    private let topShellNode = SCNNode()
    private let bottomShellNode = SCNNode()
    private let faceGlassNode = SCNNode()
    private let leftCheekNode = SCNNode()
    private let rightCheekNode = SCNNode()
    private let antennaNode = SCNNode()
    private let antennaTipNode = SCNNode()
    private let leftEyeNode = SCNNode()
    private let rightEyeNode = SCNNode()
    private let mouthNode = SCNNode()
    private let leftArmNode = SCNNode()
    private let rightArmNode = SCNNode()
    private let leftFootNode = SCNNode()
    private let rightFootNode = SCNNode()
    private let scanBeamNode = SCNNode()
    private let shadowNode = SCNNode()

    private var lastMotion: SpacerPetMotion?
    private var lastMotionStartedAt: Date?
    private var lastExpression: SpacerPetExpression?
    private var lastIsDark: Bool?
    private var didBuildScene = false

    private let restingYaw: Float = -0.14
    private let restingPitch: Float = -0.03

    init(loadIdentifier: UUID) {
        firstFrameLoadReporter = SpacerPetFirstFrameLoadReporter(loadIdentifier: loadIdentifier)
    }

    func makeView() -> SCNView {
        buildSceneIfNeeded()

        let view = SCNView(frame: .zero)
        view.scene = scene
        view.backgroundColor = .clear
        view.isOpaque = false
        view.allowsCameraControl = false
        view.autoenablesDefaultLighting = false
        view.antialiasingMode = .multisampling4X
        view.preferredFramesPerSecond = 60
        view.isUserInteractionEnabled = false
        view.isPlaying = true
        view.delegate = firstFrameLoadReporter
        return view
    }

    func update(
        palette: OpenSpacePalette,
        motion: SpacerPetMotion,
        expression: SpacerPetExpression,
        motionStartedAt: Date,
        reduceMotion: Bool
    ) {
        if lastIsDark != palette.isDark {
            applyPalette(SpacerPetScenePalette(isDark: palette.isDark))
            lastIsDark = palette.isDark
        }

        if lastExpression != expression {
            applyExpression(expression)
            lastExpression = expression
        }

        guard lastMotion != motion || lastMotionStartedAt != motionStartedAt else {
            return
        }

        lastMotion = motion
        lastMotionStartedAt = motionStartedAt
        run(motion: motion, reduceMotion: reduceMotion)
    }

    private func buildSceneIfNeeded() {
        guard !didBuildScene else {
            return
        }

        didBuildScene = true
        buildScene()
    }

    private func buildScene() {
        scene.background.contents = UIColor.clear

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 35
        cameraNode.position = SCNVector3(0, 0.08, 4.25)
        cameraNode.look(at: SCNVector3(0, -0.08, 0.02))
        scene.rootNode.addChildNode(cameraNode)

        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 280
        scene.rootNode.addChildNode(ambientLight)

        let keyLight = SCNNode()
        keyLight.light = SCNLight()
        keyLight.light?.type = .directional
        keyLight.light?.intensity = 560
        keyLight.eulerAngles = SCNVector3(-0.75, 0.55, -0.45)
        scene.rootNode.addChildNode(keyLight)

        let fillLight = SCNNode()
        fillLight.light = SCNLight()
        fillLight.light?.type = .omni
        fillLight.light?.intensity = 80
        fillLight.position = SCNVector3(-1.8, 1.2, 2.2)
        scene.rootNode.addChildNode(fillLight)

        scene.rootNode.addChildNode(rootNode)
        rootNode.addChildNode(shadowNode)
        rootNode.addChildNode(petNode)
        rootNode.scale = SCNVector3(1.18, 1.18, 1.18)

        buildShadow()
        buildPet()
        applyPalette(SpacerPetScenePalette(isDark: false))
        applyExpression(.calm)
        run(motion: .idle, reduceMotion: false)
    }

    private func buildShadow() {
        let shadow = SCNPlane(width: 1.28, height: 0.24)
        shadow.cornerRadius = 0.12
        shadow.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.1)
        shadow.firstMaterial?.lightingModel = .constant
        shadowNode.geometry = shadow
        shadowNode.eulerAngles.x = -.pi / 2
        shadowNode.position = SCNVector3(0, -0.74, 0.04)
    }

    private func buildPet() {
        headNode.geometry = SCNBox(width: 1.14, height: 0.98, length: 0.44, chamferRadius: 0.09)
        headNode.position = SCNVector3(0, -0.03, 0)
        petNode.addChildNode(headNode)

        rearShellNode.geometry = SCNBox(width: 1.04, height: 0.84, length: 0.1, chamferRadius: 0.06)
        rearShellNode.position = SCNVector3(0, -0.03, -0.27)
        petNode.addChildNode(rearShellNode)

        leftSideRidgeNode.geometry = SCNBox(width: 0.032, height: 0.76, length: 0.32, chamferRadius: 0.014)
        rightSideRidgeNode.geometry = SCNBox(width: 0.032, height: 0.76, length: 0.32, chamferRadius: 0.014)
        leftSideRidgeNode.position = SCNVector3(-0.59, -0.03, 0.025)
        rightSideRidgeNode.position = SCNVector3(0.59, -0.03, 0.025)
        petNode.addChildNode(leftSideRidgeNode)
        petNode.addChildNode(rightSideRidgeNode)

        topShellNode.geometry = SCNBox(width: 0.76, height: 0.032, length: 0.32, chamferRadius: 0.014)
        bottomShellNode.geometry = SCNBox(width: 0.8, height: 0.038, length: 0.32, chamferRadius: 0.016)
        topShellNode.position = SCNVector3(0, 0.49, 0.04)
        bottomShellNode.position = SCNVector3(0, -0.54, 0.04)
        petNode.addChildNode(topShellNode)
        petNode.addChildNode(bottomShellNode)

        let facePlate = SCNNode(geometry: SCNBox(width: 0.82, height: 0.48, length: 0.018, chamferRadius: 0.028))
        facePlate.name = "facePlate"
        facePlate.position = SCNVector3(0, -0.05, 0.26)
        petNode.addChildNode(facePlate)

        faceGlassNode.geometry = SCNBox(width: 0.7, height: 0.34, length: 0.012, chamferRadius: 0.018)
        faceGlassNode.position = SCNVector3(0, -0.05, 0.275)
        petNode.addChildNode(faceGlassNode)

        let accentBar = SCNNode(geometry: SCNBox(width: 0.32, height: 0.04, length: 0.028, chamferRadius: 0.012))
        accentBar.name = "accentBar"
        accentBar.position = SCNVector3(-0.35, 0.33, 0.29)
        petNode.addChildNode(accentBar)

        leftCheekNode.geometry = SCNBox(width: 0.08, height: 0.04, length: 0.018, chamferRadius: 0.014)
        rightCheekNode.geometry = SCNBox(width: 0.08, height: 0.04, length: 0.018, chamferRadius: 0.014)
        leftCheekNode.position = SCNVector3(-0.34, -0.22, 0.3)
        rightCheekNode.position = SCNVector3(0.34, -0.22, 0.3)
        petNode.addChildNode(leftCheekNode)
        petNode.addChildNode(rightCheekNode)

        leftEyeNode.position = SCNVector3(-0.22, 0.02, 0.31)
        rightEyeNode.position = SCNVector3(0.22, 0.02, 0.31)
        mouthNode.position = SCNVector3(0, -0.24, 0.315)
        petNode.addChildNode(leftEyeNode)
        petNode.addChildNode(rightEyeNode)
        petNode.addChildNode(mouthNode)

        antennaNode.position = SCNVector3(0, 0.48, 0.03)
        antennaNode.eulerAngles.z = 0.04

        let baseNode = SCNNode(geometry: SCNCylinder(radius: 0.045, height: 0.026))
        baseNode.name = "antennaBase"

        let rodNode = SCNNode(geometry: SCNCylinder(radius: 0.012, height: 0.25))
        rodNode.name = "antennaRod"
        rodNode.position = SCNVector3(0, 0.13, 0)

        antennaTipNode.geometry = SCNSphere(radius: 0.058)
        antennaTipNode.position = SCNVector3(0, 0.28, 0)
        antennaTipNode.scale = SCNVector3(1, 0.92, 1)

        antennaNode.addChildNode(baseNode)
        antennaNode.addChildNode(rodNode)
        antennaNode.addChildNode(antennaTipNode)
        petNode.addChildNode(antennaNode)

        buildArm(leftArmNode, side: .left)
        buildArm(rightArmNode, side: .right)
        leftArmNode.position = SCNVector3(-0.62, 0.12, 0.03)
        rightArmNode.position = SCNVector3(0.62, 0.12, 0.03)
        petNode.addChildNode(leftArmNode)
        petNode.addChildNode(rightArmNode)

        leftFootNode.geometry = SCNBox(width: 0.28, height: 0.12, length: 0.22, chamferRadius: 0.035)
        rightFootNode.geometry = SCNBox(width: 0.28, height: 0.12, length: 0.22, chamferRadius: 0.035)
        leftFootNode.position = SCNVector3(-0.36, -0.62, 0.04)
        rightFootNode.position = SCNVector3(0.36, -0.62, 0.04)
        petNode.addChildNode(leftFootNode)
        petNode.addChildNode(rightFootNode)

        let scanBeam = SCNPlane(width: 0.08, height: 0.76)
        scanBeam.cornerRadius = 0.04
        scanBeamNode.geometry = scanBeam
        scanBeamNode.position = SCNVector3(0, -0.02, 0.33)
        scanBeamNode.isHidden = true
        petNode.addChildNode(scanBeamNode)
    }

    private func buildArm(_ armNode: SCNNode, side: SpacerPetSceneSide) {
        let upperArm = SCNNode(geometry: SCNBox(width: 0.075, height: 0.31, length: 0.095, chamferRadius: 0.026))
        upperArm.position = SCNVector3(0, 0.15, 0)

        let hand = SCNNode(geometry: SCNBox(width: 0.18, height: 0.14, length: 0.16, chamferRadius: 0.045))
        hand.position = SCNVector3(0, 0.34, 0.025)

        armNode.addChildNode(upperArm)
        armNode.addChildNode(hand)
        armNode.isHidden = true
        armNode.eulerAngles.z = side == .left ? -0.24 : 0.24
    }

    private func applyPalette(_ palette: SpacerPetScenePalette) {
        headNode.geometry?.materials = [
            material(palette.shell, roughness: 0.9),
            material(palette.side, roughness: 0.92),
            material(palette.side, roughness: 0.92),
            material(palette.top, roughness: 0.86),
            material(palette.under, roughness: 0.94),
            material(palette.shell, roughness: 0.9),
        ]

        node(named: "facePlate")?.geometry?.firstMaterial = material(palette.facePlate, roughness: 0.74)
        rearShellNode.geometry?.firstMaterial = material(palette.rear, roughness: 0.9)
        leftSideRidgeNode.geometry?.firstMaterial = material(palette.edge, roughness: 0.86)
        rightSideRidgeNode.geometry?.firstMaterial = material(palette.edge, roughness: 0.86)
        topShellNode.geometry?.firstMaterial = material(palette.highlight, roughness: 0.66)
        bottomShellNode.geometry?.firstMaterial = material(palette.under, roughness: 0.9)
        let faceGlassMaterial = material(
            palette.faceGlass,
            roughness: 0.68,
            metalness: 0.02,
            emission: palette.faceGlass.withAlphaComponent(0.02)
        )
        faceGlassMaterial.blendMode = .alpha
        faceGlassMaterial.transparency = 0.16
        faceGlassMaterial.writesToDepthBuffer = false
        faceGlassNode.geometry?.firstMaterial = faceGlassMaterial
        leftCheekNode.geometry?.firstMaterial = material(palette.cheek, roughness: 0.78, emission: palette.cheek.withAlphaComponent(0.04))
        rightCheekNode.geometry?.firstMaterial = material(palette.cheek, roughness: 0.78, emission: palette.cheek.withAlphaComponent(0.04))
        node(named: "accentBar")?.geometry?.firstMaterial = material(palette.accent, roughness: 0.82, emission: palette.accent.withAlphaComponent(0.08))
        antennaNode.childNodes.dropLast().forEach { node in
            node.geometry?.firstMaterial = material(palette.edge, roughness: 0.86)
        }
        antennaTipNode.geometry?.firstMaterial = material(palette.accent, roughness: 0.8, emission: palette.accent.withAlphaComponent(0.08))
        leftFootNode.geometry?.firstMaterial = material(palette.foot)
        rightFootNode.geometry?.firstMaterial = material(palette.foot)
        scanBeamNode.geometry?.firstMaterial = material(palette.accent.withAlphaComponent(0.34), emission: palette.accent.withAlphaComponent(0.28))

        [leftArmNode, rightArmNode].forEach { arm in
            arm.childNodes.first?.geometry?.firstMaterial = material(palette.edge)
            arm.childNodes.dropFirst().first?.geometry?.firstMaterial = material(palette.shell)
        }
    }

    private func applyExpression(_ expression: SpacerPetExpression) {
        let eyeMaterial = material(SpacerPetScenePalette.eye, roughness: 0.55)
        let accentEyeMaterial = material(SpacerPetScenePalette.accentEye, emission: SpacerPetScenePalette.accentEye.withAlphaComponent(0.2))

        switch expression {
        case .calm:
            setEye(leftEyeNode, width: 0.11, height: 0.18, material: eyeMaterial)
            setEye(rightEyeNode, width: 0.11, height: 0.18, material: eyeMaterial)
            setMouth(width: 0.16, height: 0.04)
        case .curious:
            setEye(leftEyeNode, width: 0.1, height: 0.15, material: eyeMaterial)
            setEye(rightEyeNode, width: 0.14, height: 0.2, material: eyeMaterial)
            setMouth(width: 0.09, height: 0.09, rounded: true)
        case .focused:
            setEye(leftEyeNode, width: 0.15, height: 0.1, material: eyeMaterial)
            setEye(rightEyeNode, width: 0.15, height: 0.1, material: eyeMaterial)
            setMouth(width: 0.18, height: 0.034)
        case .happy:
            setEye(leftEyeNode, width: 0.1, height: 0.16, material: eyeMaterial)
            setEye(rightEyeNode, width: 0.1, height: 0.16, material: eyeMaterial)
            setMouth(width: 0.24, height: 0.055)
        case .excited:
            setEye(leftEyeNode, width: 0.13, height: 0.21, material: eyeMaterial)
            setEye(rightEyeNode, width: 0.13, height: 0.21, material: eyeMaterial)
            setMouth(width: 0.26, height: 0.08)
        case .wink:
            setEye(leftEyeNode, width: 0.12, height: 0.19, material: eyeMaterial)
            setEye(rightEyeNode, width: 0.16, height: 0.032, material: eyeMaterial)
            setMouth(width: 0.22, height: 0.05)
        case .starry:
            setEye(leftEyeNode, width: 0.17, height: 0.17, material: accentEyeMaterial)
            setEye(rightEyeNode, width: 0.17, height: 0.17, material: accentEyeMaterial)
            setMouth(width: 0.26, height: 0.07)
        }
    }

    private func setEye(_ node: SCNNode, width: CGFloat, height: CGFloat, material: SCNMaterial) {
        node.geometry = SCNBox(width: width, height: height, length: 0.052, chamferRadius: min(width, height) * 0.22)
        node.geometry?.firstMaterial = material
    }

    private func setMouth(width: CGFloat, height: CGFloat, rounded: Bool = false) {
        mouthNode.geometry = SCNBox(width: width, height: height, length: 0.05, chamferRadius: rounded ? min(width, height) * 0.5 : 0.018)
        mouthNode.geometry?.firstMaterial = material(SpacerPetScenePalette.mouth, roughness: 0.7)
    }

    private func run(motion: SpacerPetMotion, reduceMotion: Bool) {
        petNode.removeAllActions()
        rootNode.removeAllActions()
        antennaNode.removeAllActions()
        leftArmNode.removeAllActions()
        rightArmNode.removeAllActions()
        leftEyeNode.removeAllActions()
        rightEyeNode.removeAllActions()
        leftFootNode.removeAllActions()
        rightFootNode.removeAllActions()
        scanBeamNode.removeAllActions()
        shadowNode.removeAllActions()

        resetPose(animated: true)

        guard !reduceMotion else {
            return
        }

        switch motion {
        case .idle:
            runIdle()
        case .lookAround:
            runLookAround()
        case .scootLeft:
            runScoot(direction: -1)
        case .scootRight:
            runScoot(direction: 1)
        case .settle:
            runSettle()
        case .jump:
            runJump()
        case .wave:
            runWave()
        case .highFive:
            runHighFive()
        case .spin:
            runWorldSpin()
        case .happyDance:
            runHappyDance()
        case .scan:
            runScan()
        }
    }

    private func resetPose(animated: Bool) {
        let updates = {
            self.petNode.position = SCNVector3Zero
            self.petNode.eulerAngles = SCNVector3(self.restingPitch, self.restingYaw, 0)
            self.petNode.scale = SCNVector3(1, 1, 1)
            self.rootNode.eulerAngles = SCNVector3Zero
            self.antennaNode.position = SCNVector3(0, 0.48, 0.03)
            self.antennaNode.eulerAngles = SCNVector3(0, 0, 0.04)
            self.leftArmNode.position = SCNVector3(-0.62, 0.12, 0.03)
            self.rightArmNode.position = SCNVector3(0.62, 0.12, 0.03)
            self.leftFootNode.position = SCNVector3(-0.36, -0.62, 0.04)
            self.rightFootNode.position = SCNVector3(0.36, -0.62, 0.04)
            self.leftArmNode.isHidden = true
            self.rightArmNode.isHidden = true
            self.leftArmNode.eulerAngles = SCNVector3(0, 0, 0.36)
            self.rightArmNode.eulerAngles = SCNVector3(0, 0, -0.36)
            self.leftArmNode.scale = SCNVector3(1, 1, 1)
            self.rightArmNode.scale = SCNVector3(1, 1, 1)
            self.leftEyeNode.scale = SCNVector3(1, 1, 1)
            self.rightEyeNode.scale = SCNVector3(1, 1, 1)
            self.scanBeamNode.isHidden = true
            self.scanBeamNode.opacity = 0
            self.shadowNode.scale = SCNVector3(1, 1, 1)
        }

        if animated {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.16
            updates()
            SCNTransaction.commit()
        } else {
            updates()
        }
    }

    private func runIdle() {
        let baseYaw = restingYaw
        let basePitch = restingPitch
        let duration: CGFloat = 2.4

        petNode.runAction(
            .repeatForever(
                .customAction(duration: TimeInterval(duration)) { node, elapsed in
                    let progress = Float(elapsed / duration)
                    let phase = progress * Float.pi * 2
                    node.position.y = sin(phase) * 0.035
                    node.position.z = cos(phase) * 0.018
                    node.eulerAngles.x = basePitch + cos(phase) * 0.018
                    node.eulerAngles.y = baseYaw + sin(phase * 0.72) * 0.08
                }
            ),
            forKey: NodeName.idle
        )

        runIdleFeet()
        runIdleBlink()

        antennaNode.runAction(
            .repeatForever(
                .sequence([
                    .rotateBy(x: 0, y: 0, z: 0.08, duration: 0.7),
                    .rotateBy(x: 0, y: 0, z: -0.08, duration: 0.7),
                ])
            ),
            forKey: NodeName.antenna
        )
    }

    private func runLookAround() {
        petNode.runAction(
            .sequence([
                .rotateTo(x: CGFloat(restingPitch), y: CGFloat(restingYaw - 0.36), z: -0.04, duration: 0.34),
                .rotateTo(x: CGFloat(restingPitch), y: CGFloat(restingYaw + 0.52), z: 0.04, duration: 0.52),
                .rotateTo(x: CGFloat(restingPitch), y: CGFloat(restingYaw), z: 0, duration: 0.34),
            ]),
            forKey: NodeName.motion
        )
    }

    private func runScoot(direction: Float) {
        runFootSteps(count: 4)
        petNode.runAction(
            .sequence([
                .rotateTo(x: CGFloat(restingPitch), y: CGFloat(restingYaw + (direction * 0.42)), z: CGFloat(direction) * 0.08, duration: 0.12),
                .rotateTo(x: CGFloat(restingPitch), y: CGFloat(restingYaw + (direction * 0.2)), z: CGFloat(direction) * -0.06, duration: 0.16),
                .rotateTo(x: CGFloat(restingPitch), y: CGFloat(restingYaw), z: 0, duration: 0.16),
            ]),
            forKey: NodeName.motion
        )
    }

    private func runSettle() {
        petNode.runAction(
            .sequence([
                .moveBy(x: 0, y: -0.05, z: 0, duration: 0.12),
                .moveBy(x: 0, y: 0.08, z: 0, duration: 0.16),
                .moveBy(x: 0, y: -0.03, z: 0, duration: 0.16),
            ]),
            forKey: NodeName.motion
        )
    }

    private func runJump() {
        leftArmNode.isHidden = false
        rightArmNode.isHidden = false
        leftArmNode.runAction(.rotateTo(x: -0.18, y: 0.1, z: 0.34, duration: 0.18), forKey: NodeName.arm)
        rightArmNode.runAction(.rotateTo(x: -0.18, y: -0.1, z: -0.34, duration: 0.18), forKey: NodeName.arm)

        petNode.runAction(
            .sequence([
                .group([
                    .moveBy(x: 0, y: 0.54, z: -0.08, duration: 0.28),
                    .rotateTo(x: -0.2, y: CGFloat(restingYaw + 0.24), z: 0, duration: 0.28),
                ]),
                .group([
                    .moveBy(x: 0, y: -0.54, z: 0.08, duration: 0.34),
                    .rotateTo(x: 0.06, y: CGFloat(restingYaw - 0.08), z: 0, duration: 0.34),
                ]),
                .rotateTo(x: CGFloat(restingPitch), y: CGFloat(restingYaw), z: 0, duration: 0.16),
            ]),
            forKey: NodeName.motion
        )

        shadowNode.runAction(
            .sequence([
                .scale(to: 0.68, duration: 0.28),
                .scale(to: 1.08, duration: 0.34),
                .scale(to: 1, duration: 0.16),
            ])
        )
    }

    private func runWave() {
        rightArmNode.isHidden = false
        leftArmNode.isHidden = true
        rightArmNode.position = SCNVector3(0.58, 0.14, 0.11)
        rightArmNode.runAction(
            .sequence([
                .rotateTo(x: -0.28, y: -0.18, z: -0.28, duration: 0.16),
                .repeat(
                    .sequence([
                        .rotateTo(x: -0.32, y: -0.36, z: -0.72, duration: 0.16),
                        .rotateTo(x: -0.22, y: 0.08, z: -0.08, duration: 0.16),
                    ]),
                    count: 4
                ),
                .rotateTo(x: 0, y: 0, z: -0.36, duration: 0.18),
            ]),
            forKey: NodeName.arm
        )
        petNode.runAction(
            .sequence([
                .rotateTo(x: CGFloat(restingPitch), y: CGFloat(restingYaw + 0.22), z: 0, duration: 0.22),
                .rotateTo(x: CGFloat(restingPitch), y: CGFloat(restingYaw), z: 0, duration: 0.28),
            ]),
            forKey: NodeName.motion
        )
    }

    private func runHighFive() {
        rightArmNode.isHidden = false
        rightArmNode.position = SCNVector3(0.56, 0.12, 0.14)
        rightArmNode.runAction(
            .sequence([
                .group([
                    .rotateTo(x: -0.52, y: -0.22, z: -0.2, duration: 0.18),
                    .moveBy(x: -0.02, y: 0.18, z: 0.06, duration: 0.18),
                ]),
                .group([
                    .moveBy(x: 0, y: 0.02, z: 0.13, duration: 0.1),
                    .scale(to: 1.08, duration: 0.1),
                ]),
                .group([
                    .moveBy(x: 0, y: -0.02, z: -0.13, duration: 0.16),
                    .scale(to: 1, duration: 0.16),
                ]),
                .group([
                    .rotateTo(x: 0, y: 0, z: -0.36, duration: 0.18),
                    .moveBy(x: 0.02, y: -0.18, z: -0.06, duration: 0.18),
                ]),
            ]),
            forKey: NodeName.arm
        )
        petNode.runAction(
            .sequence([
                .group([
                    .moveBy(x: 0, y: 0.12, z: 0.08, duration: 0.18),
                    .rotateTo(x: CGFloat(restingPitch - 0.08), y: CGFloat(restingYaw + 0.2), z: 0, duration: 0.18),
                ]),
                .group([
                    .moveBy(x: 0, y: -0.12, z: -0.08, duration: 0.22),
                    .rotateTo(x: CGFloat(restingPitch), y: CGFloat(restingYaw), z: 0, duration: 0.22),
                ]),
            ]),
            forKey: NodeName.motion
        )
    }

    private func runWorldSpin() {
        leftArmNode.isHidden = false
        rightArmNode.isHidden = false
        runFootSteps(count: 6)

        let duration: CGFloat = 1.36
        let baseYaw = restingYaw
        petNode.runAction(
            .customAction(duration: TimeInterval(duration)) { node, elapsed in
                let progress = Float(elapsed / duration)
                let angle = progress * Float.pi * 2
                let depth = cos(angle)
                let perspectiveScale = 1.0 + (depth * 0.08)

                node.eulerAngles.x = sin(angle) * 0.08
                node.eulerAngles.y = baseYaw + angle
                node.eulerAngles.z = sin(angle * 2) * 0.08
                node.position.x = sin(angle) * 0.28
                node.position.z = depth * 0.34 - 0.18
                node.position.y = max(0, sin(angle * 2) * 0.05)
                node.scale = SCNVector3(perspectiveScale, perspectiveScale, perspectiveScale)
            },
            forKey: NodeName.motion
        )
        shadowNode.runAction(
            .sequence([
                .scale(to: 0.82, duration: 0.34),
                .scale(to: 1.08, duration: 0.34),
                .scale(to: 0.9, duration: 0.34),
                .scale(to: 1, duration: 0.34),
            ]),
            forKey: NodeName.motion
        )
    }

    private func runHappyDance() {
        leftArmNode.isHidden = false
        rightArmNode.isHidden = false
        runFootSteps(count: 8)
        leftArmNode.runAction(
            .repeat(
                .sequence([
                    .rotateTo(x: 0.04, y: 0.12, z: 0.58, duration: 0.18),
                    .rotateTo(x: -0.1, y: -0.08, z: 0.12, duration: 0.18),
                ]),
                count: 4
            ),
            forKey: NodeName.arm
        )
        rightArmNode.runAction(
            .repeat(
                .sequence([
                    .rotateTo(x: -0.1, y: -0.12, z: -0.58, duration: 0.18),
                    .rotateTo(x: 0.04, y: 0.08, z: -0.12, duration: 0.18),
                ]),
                count: 4
            ),
            forKey: NodeName.arm
        )

        petNode.runAction(
            .repeat(
                .sequence([
                    .group([
                        .moveBy(x: -0.05, y: 0.08, z: 0, duration: 0.16),
                        .rotateTo(x: CGFloat(restingPitch), y: CGFloat(restingYaw - 0.28), z: -0.18, duration: 0.16),
                    ]),
                    .group([
                        .moveBy(x: 0.1, y: -0.02, z: 0, duration: 0.16),
                        .rotateTo(x: CGFloat(restingPitch), y: CGFloat(restingYaw + 0.28), z: 0.18, duration: 0.16),
                    ]),
                    .group([
                        .moveBy(x: -0.05, y: -0.06, z: 0, duration: 0.16),
                        .rotateTo(x: CGFloat(restingPitch), y: CGFloat(restingYaw), z: 0, duration: 0.16),
                    ]),
                ]),
                count: 3
            ),
            forKey: NodeName.motion
        )
    }

    private func runScan() {
        scanBeamNode.isHidden = false
        scanBeamNode.opacity = 1
        scanBeamNode.runAction(
            .repeat(
                .sequence([
                    .moveBy(x: -0.42, y: 0, z: 0, duration: 0.28),
                    .moveBy(x: 0.84, y: 0, z: 0, duration: 0.56),
                    .moveBy(x: -0.42, y: 0, z: 0, duration: 0.28),
                ]),
                count: 2
            ),
            forKey: NodeName.motion
        )
        petNode.runAction(
            .sequence([
                .rotateTo(x: CGFloat(restingPitch), y: CGFloat(restingYaw - 0.24), z: 0, duration: 0.28),
                .rotateTo(x: CGFloat(restingPitch), y: CGFloat(restingYaw + 0.46), z: 0, duration: 0.56),
                .rotateTo(x: CGFloat(restingPitch), y: CGFloat(restingYaw), z: 0, duration: 0.28),
            ]),
            forKey: NodeName.motion
        )
    }

    private func runIdleFeet() {
        let leftStep = SCNAction.repeatForever(
            .sequence([
                .moveBy(x: 0, y: 0.035, z: 0.035, duration: 0.36),
                .moveBy(x: 0, y: -0.035, z: -0.035, duration: 0.36),
                .wait(duration: 0.24),
            ])
        )
        let rightStep = SCNAction.sequence([
            .wait(duration: 0.24),
            .repeatForever(
                .sequence([
                    .moveBy(x: 0, y: 0.035, z: -0.035, duration: 0.36),
                    .moveBy(x: 0, y: -0.035, z: 0.035, duration: 0.36),
                    .wait(duration: 0.24),
                ])
            ),
        ])

        leftFootNode.runAction(leftStep, forKey: NodeName.foot)
        rightFootNode.runAction(rightStep, forKey: NodeName.foot)
    }

    private func runIdleBlink() {
        let blink = SCNAction.sequence([
            .wait(duration: 1.45),
            .group([
                .customAction(duration: 0.055) { node, _ in
                    node.scale = SCNVector3(1.06, 0.14, 1)
                },
                .moveBy(x: 0, y: -0.004, z: 0, duration: 0.055),
            ]),
            .wait(duration: 0.035),
            .group([
                .customAction(duration: 0.075) { node, _ in
                    node.scale = SCNVector3(1, 1, 1)
                },
                .moveBy(x: 0, y: 0.004, z: 0, duration: 0.075),
            ]),
            .wait(duration: 2.35),
        ])

        leftEyeNode.runAction(.repeatForever(blink), forKey: NodeName.eye)
        rightEyeNode.runAction(.repeatForever(blink), forKey: NodeName.eye)
    }

    private func runFootSteps(count: Int) {
        let leftStep = SCNAction.repeat(
            .sequence([
                .moveBy(x: 0, y: 0.1, z: 0.04, duration: 0.12),
                .moveBy(x: 0, y: -0.1, z: -0.04, duration: 0.12),
            ]),
            count: count
        )
        let rightStep = SCNAction.sequence([
            .wait(duration: 0.12),
            .repeat(
                .sequence([
                    .moveBy(x: 0, y: 0.1, z: -0.04, duration: 0.12),
                    .moveBy(x: 0, y: -0.1, z: 0.04, duration: 0.12),
                ]),
                count: count
            ),
        ])

        leftFootNode.runAction(leftStep, forKey: NodeName.foot)
        rightFootNode.runAction(rightStep, forKey: NodeName.foot)
    }

    private func node(named name: String) -> SCNNode? {
        petNode.childNode(withName: name, recursively: true)
    }

    private func material(
        _ color: UIColor,
        roughness: CGFloat = 0.82,
        metalness: CGFloat = 0.04,
        emission: UIColor? = nil
    ) -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = color
        material.roughness.contents = roughness
        material.metalness.contents = metalness
        material.emission.contents = emission ?? UIColor.clear
        material.specular.contents = UIColor.white.withAlphaComponent(0.03)
        material.shininess = 0.06
        return material
    }
}
