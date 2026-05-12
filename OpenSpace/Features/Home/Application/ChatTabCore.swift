import ComposableArchitecture

@ObservableState
struct ChatTabState: Equatable {}

@CasePathable
enum ChatTabAction: Equatable {}

@Reducer
struct ChatTab {
    var body: some Reducer<ChatTabState, ChatTabAction> {
        Reduce { _, _ in .none }
    }
}
