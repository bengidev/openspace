import SwiftUI

struct OnboardingPromptQueueVisual: View {
    let palette: OpenSpacePalette
    let queuedPromptCount: Int
    let appeared: Bool
    let onAddQueuedPrompt: () -> Void

    var body: some View {
        VStack(spacing: 9) {
            ForEach(Array(OnboardingPromptQueueItem.samples.prefix(queuedPromptCount).enumerated()), id: \.element.id) { index, item in
                OnboardingQueueRow(item: item, index: index, palette: palette, appeared: appeared)
            }

            Color.clear
                .frame(height: 16)
                .id("queueLast")
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }
}
