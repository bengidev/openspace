//
//  SpacerPetMotion.swift
//  OpenSpace
//

import Foundation

enum SpacerPetMotion: String, CaseIterable, Equatable {
    case idle
    case lookAround
    case scootLeft
    case scootRight
    case settle
    case jump
    case wave
    case highFive
    case spin
    case happyDance
    case scan

    var title: String {
        switch self {
        case .idle:
            return "ready"
        case .lookAround:
            return "curious"
        case .scootLeft, .scootRight:
            return "rolling"
        case .settle:
            return "nice"
        case .jump:
            return "jump"
        case .wave:
            return "wave"
        case .highFive:
            return "high five"
        case .spin:
            return "spin"
        case .happyDance:
            return "dance"
        case .scan:
            return "scan"
        }
    }

    var menuTitle: String {
        switch self {
        case .jump:
            return "Do a little jump"
        case .wave:
            return "Wave hello"
        case .highFive:
            return "High five me"
        case .spin:
            return "Spin around"
        case .happyDance:
            return "Happy dance"
        case .scan:
            return "Look around"
        default:
            return title
        }
    }

    var systemImage: String {
        switch self {
        case .idle:
            return "sparkle"
        case .lookAround:
            return "eye"
        case .scootLeft, .scootRight:
            return "arrow.left.and.right"
        case .settle:
            return "checkmark"
        case .jump:
            return "arrow.up"
        case .wave:
            return "hand.wave.fill"
        case .highFive:
            return "hands.clap.fill"
        case .spin:
            return "arrow.triangle.2.circlepath"
        case .happyDance:
            return "music.note"
        case .scan:
            return "viewfinder"
        }
    }

    var expression: SpacerPetExpression {
        switch self {
        case .idle:
            return .calm
        case .lookAround, .scan:
            return .curious
        case .scootLeft, .scootRight:
            return .focused
        case .settle:
            return .happy
        case .jump, .spin, .happyDance:
            return .excited
        case .wave:
            return .wink
        case .highFive:
            return .starry
        }
    }

    var durationNanoseconds: UInt64 {
        switch self {
        case .idle:
            return 0
        case .lookAround:
            return 1_600_000_000
        case .scootLeft, .scootRight:
            return 600_000_000
        case .settle:
            return 900_000_000
        case .jump:
            return 1_100_000_000
        case .wave:
            return 1_500_000_000
        case .highFive:
            return 1_250_000_000
        case .spin:
            return 1_450_000_000
        case .happyDance:
            return 1_800_000_000
        case .scan:
            return 1_700_000_000
        }
    }

    var closesMenu: Bool {
        switch self {
        case .jump, .wave, .highFive, .spin, .happyDance, .scan:
            return true
        default:
            return false
        }
    }
}
