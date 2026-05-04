import ComposableArchitecture
import SwiftUI

// MARK: - OnboardingView

struct OnboardingView: View {
    // MARK: Internal

    let store: StoreOf<OnboardingFeature>
    let onContinue: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let variant = platformVariant(for: proxy.size)
            let context = OnboardingRenderContext(
                capabilityChips: capabilityChips,
                containerSize: proxy.size,
                hasAppeared: store.hasAppeared,
                reduceMotion: reduceMotion
            )

            ZStack(alignment: .top) {
                OnboardingBackdrop(isAnimated: context.isAnimated)
                    .accessibilityIdentifier("onboarding.backdrop")

                OnboardingPlatformViewFactory.makeContent(
                    for: variant,
                    context: context,
                    onContinue: onContinue
                )
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityIdentifier("onboarding.root")
            .task {
                guard !store.hasAppeared else { return }
                store.send(.appeared)
            }
        }
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let capabilityChips = ["Code", "Images", "Research", "Automation"]

    private func platformVariant(for _: CGSize) -> OnboardingPlatformVariant {
        #if os(iOS)
            UIDevice.current.userInterfaceIdiom == .pad ? .ipad : .ios
        #else
            .ios
        #endif
    }
}
