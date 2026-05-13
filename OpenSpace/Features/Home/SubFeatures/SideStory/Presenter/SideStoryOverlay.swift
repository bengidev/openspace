import ComposableArchitecture
import SwiftUI

struct SideStoryOverlay: View {
    @Bindable var store: StoreOf<SideStory>
    let modelTitle: String
    let branchTitle: String
    var safeAreaInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

    @Environment(\.palette) private var palette
    private let hiddenShadowPadding: CGFloat = 28

    var body: some View {
        GeometryReader { proxy in
            let sidebarWidth = sidebarWidth(for: proxy.size.width)

            HStack(spacing: 0) {
                SideStoryView(
                    store: store,
                    modelTitle: modelTitle,
                    branchTitle: branchTitle,
                    safeAreaInsets: safeAreaInsets
                )
                .frame(width: sidebarWidth)
                .frame(maxHeight: .infinity)
                .clipped()
                .compositingGroup()
                .shadow(
                    color: .black.opacity(sidebarShadowOpacity),
                    radius: 10,
                    x: 5,
                    y: 0
                )
                .offset(x: store.isSidebarVisible ? 0 : -(sidebarWidth + hiddenShadowPadding))

                Color.clear
                    .contentShape(Rectangle())
                    .accessibilityHidden(true)
                    .onTapGesture {
                        store.send(.sidebarDismissed)
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .ignoresSafeArea(.container, edges: .vertical)
            .clipped()
        }
        .animation(.spring(response: 0.26, dampingFraction: 0.84), value: store.isSidebarVisible)
        .allowsHitTesting(store.isSidebarVisible)
        .accessibilityHidden(!store.isSidebarVisible)
    }

    private func sidebarWidth(for availableWidth: CGFloat) -> CGFloat {
        min(max(availableWidth - 48, 308), 354)
    }

    private var sidebarShadowOpacity: Double {
        guard store.isSidebarVisible else { return 0 }
        return palette.isDark ? 0.18 : 0.08
    }
}
