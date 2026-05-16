import Foundation

struct PresetDistance: Codable, Identifiable {
    var id: String { distanceStr }
    var distanceStr: String
    var distance: Double
    var colorHex: String
}
