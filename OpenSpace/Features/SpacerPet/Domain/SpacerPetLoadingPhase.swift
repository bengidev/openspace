//
//  SpacerPetLoadingPhase.swift
//  OpenSpace
//

enum SpacerPetLoadingPhase: Equatable {
    case initializing
    case loading
    case ready

    var title: String {
        switch self {
        case .initializing:
            return "Starting up"
        case .loading:
            return "Loading"
        case .ready:
            return "Ready"
        }
    }

    var detail: String {
        switch self {
        case .initializing:
            return "Preparing pet"
        case .loading:
            return "Loading 3D pet"
        case .ready:
            return "Ready to show"
        }
    }
}
