import ComposableArchitecture
import SwiftUI

struct SideStoryContainerView: View {
    @Bindable var store: StoreOf<SideStory>
    let modelTitle: String
    let branchTitle: String

    var body: some View {
        SideStoryView(
            store: store,
            modelTitle: modelTitle,
            branchTitle: branchTitle
        )
    }
}
