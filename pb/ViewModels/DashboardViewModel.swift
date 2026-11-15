import Foundation
import Combine
import OSLog
import SwiftUI
import WidgetKit

class DashboardViewModel: ObservableObject {
    @Published private(set) var records: [Record] = []
    @Published var presetDistances: [PresetDistance] = []

    private let logger = Logger(subsystem: "com.mowen.pb", category: "Records")
    private var recordsChangedSinceBackground = false
    
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
    
    private func saveRecords() {
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.pb.shared") else {
            logger.error("Could not access the shared records container")
            return
        }
        let url = container.appendingPathComponent("records.json")
        do {
            let data = try JSONEncoder().encode(records)
            try data.write(to: url, options: .atomic)
            recordsChangedSinceBackground = true
            reloadRecordsWidget()
        } catch {
            logger.error("Could not save shared records: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func reloadRecordsWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: "pbWidget")
    }

    func refreshWidgetOnBackground() {
        // WidgetKit can throttle reloads during a series of foreground edits.
        guard recordsChangedSinceBackground else { return }
        recordsChangedSinceBackground = false
        reloadRecordsWidget()
    }

    func updateRecord(_ record: Record) {
        guard let index = records.firstIndex(where: { $0.id == record.id }),
              records[index] != record else { return }
        records[index] = record
        saveRecords()
    }

    func addRecord(_ record: Record) {
        records.append(record)
        saveRecords()
    }
    
    func addCustomRecord(distance: Double) {
        let randomColor = presetDistances.randomElement()?.colorHex ?? "8BA68E"
        addRecord(Record(distance: distance, distanceStr: "\(distance)k", targetHours: 0, targetMinutes: 0, targetSeconds: 0, date: nil, isCustom: true, colorHex: randomColor))
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
