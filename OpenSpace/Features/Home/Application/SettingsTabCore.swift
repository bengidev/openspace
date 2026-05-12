import ComposableArchitecture

@ObservableState
struct SettingsTabState: Equatable {}

@CasePathable
enum SettingsTabAction: Equatable {}

@Reducer
struct SettingsTab {
    var body: some Reducer<SettingsTabState, SettingsTabAction> {
        Reduce { _, _ in .none }
    }
}
