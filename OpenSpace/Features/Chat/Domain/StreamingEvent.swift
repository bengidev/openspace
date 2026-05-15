import Foundation

enum StreamingEvent: Equatable, Sendable {
    case textDelta(String)
    case done
    case error(String)
}
