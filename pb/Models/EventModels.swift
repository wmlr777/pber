import Foundation

// MARK: - Data Models
enum RecordFormat: String, Codable {
    case time_hms = "time_hms"
    case unknown = "unknown"
}

struct TimeRecord: Codable, Equatable {
    var hour: Int = 0
    var minute: Int = 0
    var second: Int = 0
    
    var isEmpty: Bool {
        hour == 0 && minute == 0 && second == 0
    }
}

struct SmallEvent: Codable, Identifiable, Equatable {
    var id: String { name }
    var name: String
    var colorHex: String
    var recordFormat: RecordFormat
    var timeRecord: TimeRecord?
    var isAdded: Bool
    var isPaceValid: Bool?
    var distance: Double?
}

struct BigEvent: Codable, Identifiable, Equatable {
    var id: String { name }
    var name: String
    var icon: String
    var subEvents: [SmallEvent]
}
