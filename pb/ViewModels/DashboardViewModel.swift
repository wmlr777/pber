import Foundation
import Combine
import SwiftUI
import WidgetKit

class DashboardViewModel: ObservableObject {
    @Published var records: [Record] = []
    @Published var presetDistances: [PresetDistance] = []
    
    init() {
        loadPresets()
        loadRecords()
    }
    
    func loadPresets() {
        // Try to load from bundle
        if let url = Bundle.main.url(forResource: "presets", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let loadedPresets = try? JSONDecoder().decode([PresetDistance].self, from: data) {
            self.presetDistances = loadedPresets
        } else {
            print("Please add presets.json to the Xcode target.")
            // Fallback just in case to maintain preview and logic
            self.presetDistances = [
                PresetDistance(distanceStr: "1k", distance: 1.0, colorHex: "8BA68E"),
                PresetDistance(distanceStr: "5k", distance: 5.0, colorHex: "D6B25C"),
                PresetDistance(distanceStr: "10k", distance: 10.0, colorHex: "E98A8E"),
                PresetDistance(distanceStr: "21.0975k", distance: 21.0975, colorHex: "7BB3B5"),
                PresetDistance(distanceStr: "42.195k", distance: 42.195, colorHex: "768DBE")
            ]
        }
    }
    
    func loadRecords() {
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.pb.shared") else { return }
        let url = container.appendingPathComponent("records.json")
        
        if let data = try? Data(contentsOf: url),
           let savedRecords = try? JSONDecoder().decode([Record].self, from: data) {
            self.records = savedRecords
        } else {
            // Load initial records from presets if no records exist
            for preset in presetDistances {
                self.records.append(Record(distance: preset.distance, distanceStr: preset.distanceStr, targetHours: 0, targetMinutes: 0, targetSeconds: 0, date: nil, colorHex: preset.colorHex))
            }
            saveRecords()
        }
    }
    
    func saveRecords() {
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.pb.shared") else { return }
        let url = container.appendingPathComponent("records.json")
        if let data = try? JSONEncoder().encode(records) {
            try? data.write(to: url)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func addCustomRecord(distance: Double) {
        let randomColor = presetDistances.randomElement()?.colorHex ?? "8BA68E"
        records.append(Record(distance: distance, distanceStr: "\(distance)k", targetHours: 0, targetMinutes: 0, targetSeconds: 0, date: nil, isCustom: true, colorHex: randomColor))
        saveRecords()
    }
    
    func deleteRecord(_ record: Record) {
        if let idx = records.firstIndex(where: { $0.id == record.id }) {
            records.remove(at: idx)
            saveRecords()
        }
    }
    
    func moveRecord(from: IndexSet, to: Int) {
        records.move(fromOffsets: from, toOffset: to)
        saveRecords()
    }
}
