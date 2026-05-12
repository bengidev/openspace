import ComposableArchitecture
import SwiftUI

struct SpacerPetContainerView: View {
    @Bindable var store: StoreOf<SpacerPetContainer>
    
    var body: some View {
        SpacerPetOverlay(store: store.scope(state: \.feature, action: \.feature))
    }
}


@Reducer
struct SpacerPetContainer {
    @ObservableState
    struct State: Equatable {
        var feature = SpacerPetFeatureState()
    }
    
    @CasePathable
    enum Action: Equatable {
        case feature(SpacerPetFeatureAction)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.feature, action: \.feature) {
            SpacerPetFeature()
        }
    }
}

