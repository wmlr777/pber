import Foundation

struct Record: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var distance: Double // in km
    var distanceStr: String // e.g. "1k", "21.0975k", "Custom"
    var targetHours: Int
    var targetMinutes: Int
    var targetSeconds: Int
    var date: Date?
    var isCustom: Bool = false
    var colorHex: String
    
    var timeInSeconds: Int {
        get { return targetHours * 3600 + targetMinutes * 60 + targetSeconds }
        set {
            targetHours = newValue / 3600
            targetMinutes = (newValue % 3600) / 60
            targetSeconds = newValue % 60
        }
    }
    
    var formattedPace: String {
        if timeInSeconds == 0 || distance == 0 {
            return "--"
        }
        let paceInSeconds = Double(timeInSeconds) / distance
        let m = Int(paceInSeconds) / 60
        let s = Int(paceInSeconds) % 60
        return "\(m)' \(String(format: "%02d", s))\"/km"
    }
}
