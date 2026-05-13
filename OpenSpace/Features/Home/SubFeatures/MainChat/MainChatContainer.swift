import ComposableArchitecture
import SwiftUI

struct MainChatContainerView: View {
    @Bindable var store: StoreOf<MainChat>
    let isSidebarVisible: Bool

    var body: some View {
        MainChatView(store: store, isSidebarVisible: isSidebarVisible)
    }
}
