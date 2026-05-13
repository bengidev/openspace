import ComposableArchitecture
import SwiftUI

struct SettingsContainerView: View {
    @Bindable var store: StoreOf<Settings>

    var body: some View {
        SettingsView()
    }
}
