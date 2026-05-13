import ComposableArchitecture

@Reducer
struct Settings {
    @ObservableState
    struct State: Equatable {
        var isPresented = false
    }

    @CasePathable
    enum Action: Equatable {
        case present
        case dismiss
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .present:
                state.isPresented = true
                return .none
            case .dismiss:
                state.isPresented = false
                return .none
            }
        }
    }
}
