import Foundation

struct OnboardingFeatureHighlight: Equatable, Sendable {
    var id: String { title }
    let title: String
    let detail: String
    let symbol: String

    nonisolated init(title: String, detail: String, symbol: String) {
        self.title = title
        self.detail = detail
        self.symbol = symbol
    }
}
