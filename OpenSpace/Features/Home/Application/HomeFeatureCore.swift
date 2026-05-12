import ComposableArchitecture

@ObservableState
struct HomeFeatureState: Equatable {
    var spacerPet = SpacerPetFeatureState()
}

@CasePathable
enum HomeFeatureAction: Equatable {
    case onAppear
    case spacerPet(SpacerPetFeatureAction)
}

@Reducer
struct HomeFeature {
    var body: some Reducer<HomeFeatureState, HomeFeatureAction> {
        Scope(state: \.spacerPet, action: \.spacerPet) {
            SpacerPetFeature()
        }

        Reduce { _, action in
            switch action {
            case .onAppear, .spacerPet:
                return .none
            }
        }
    }
}
