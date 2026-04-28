import ComposableArchitecture
import SwiftUI
#if os(macOS)
    import AppKit
#endif

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
                #if os(macOS)
                    configureMacWindow()
                #endif
            }
        }
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let capabilityChips = ["Code", "Images", "Research", "Automation"]

    private func platformVariant(for _: CGSize) -> OnboardingPlatformVariant {
        #if os(macOS)
            .mac
        #elseif os(iOS)
            UIDevice.current.userInterfaceIdiom == .pad ? .ipad : .ios
        #else
            .ios
        #endif
    }

    #if os(macOS)
        private func configureMacWindow() {
            DispatchQueue.main.async {
                guard let window = NSApplication.shared.keyWindow ?? NSApplication.shared.windows.first else { return }
                window.minSize = NSSize(width: 760, height: 560)

                if window.styleMask.contains(.fullScreen) {
                    window.toggleFullScreen(nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        applyNormalLaunchFrame(to: window)
                    }
                } else {
                    applyNormalLaunchFrame(to: window)
                }
            }
        }

        private func applyNormalLaunchFrame(to window: NSWindow) {
            guard let screen = window.screen ?? NSScreen.main else { return }

            let visibleFrame = screen.visibleFrame
            let preferredSize = NSSize(width: 1280, height: 820)
            let targetSize = NSSize(
                width: min(preferredSize.width, visibleFrame.width * 0.86),
                height: min(preferredSize.height, visibleFrame.height * 0.86)
            )
            let targetFrame = NSRect(
                x: visibleFrame.midX - (targetSize.width / 2),
                y: visibleFrame.midY - (targetSize.height / 2),
                width: targetSize.width,
                height: targetSize.height
            )

            let fillsVisibleWidth = window.frame.width >= visibleFrame.width - 16
            let fillsVisibleHeight = window.frame.height >= visibleFrame.height - 16

            if fillsVisibleWidth || fillsVisibleHeight {
                window.setFrame(targetFrame, display: true, animate: false)
            }
        }
    #endif
}
