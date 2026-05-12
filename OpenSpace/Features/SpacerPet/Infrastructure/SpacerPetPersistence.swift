import ComposableArchitecture
import Foundation

struct SpacerPetPreferences: Equatable {
    var positionX: Double
    var positionY: Double
    var scale: Double
}

struct SpacerPetPersistenceClient {
    var load: @Sendable () -> SpacerPetPreferences
    var save: @Sendable (SpacerPetPreferences) -> Void
}

extension SpacerPetPersistenceClient: DependencyKey {
    static let liveValue = SpacerPetPersistenceClient(
        load: {
            let defaults = UserDefaults.standard
            let positionX = defaults.object(forKey: "home.petCompanion.positionX") as? Double ?? 0.78
            let positionY = defaults.object(forKey: "home.petCompanion.positionY") as? Double ?? 0.74
            let scale = defaults.object(forKey: "home.petCompanion.scale") as? Double ?? 1.0

            return SpacerPetPreferences(
                positionX: positionX,
                positionY: positionY,
                scale: scale
            )
        },
        save: { preferences in
            let defaults = UserDefaults.standard
            defaults.set(preferences.positionX, forKey: "home.petCompanion.positionX")
            defaults.set(preferences.positionY, forKey: "home.petCompanion.positionY")
            defaults.set(preferences.scale, forKey: "home.petCompanion.scale")
        }
    )

    static let testValue = SpacerPetPersistenceClient(
        load: {
            SpacerPetPreferences(positionX: 0.78, positionY: 0.74, scale: 1.0)
        },
        save: { _ in }
    )
}

extension DependencyValues {
    var spacerPetPersistence: SpacerPetPersistenceClient {
        get { self[SpacerPetPersistenceClient.self] }
        set { self[SpacerPetPersistenceClient.self] = newValue }
    }
}
