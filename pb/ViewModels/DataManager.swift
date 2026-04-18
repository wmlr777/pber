import Foundation
import Combine
import WidgetKit

// MARK: - Data Manager
class DataManager: ObservableObject {
    @Published var bigEvents: [BigEvent] = []
    
    private let fileName = "pb_events_setting.json"
    
    private var fileURL: URL? {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.pb.shared")
        return container?.appendingPathComponent(fileName)
    }
    
    init() {
        loadData()
    }
    
    func loadData() {
        guard let url = fileURL else { return }
        
        // 尝试从本地持久化目录读取
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                let data = try Data(contentsOf: url)
                self.bigEvents = try JSONDecoder().decode([BigEvent].self, from: data)
                return
            } catch {
                print("Failed to load user data: \(error)")
            }
        }
        
        // 如果本地没有，从 Bundle 中读取 default_events.json
        if let bundleURL = Bundle.main.url(forResource: "default_events", withExtension: "json") {
            do {
                let data = try Data(contentsOf: bundleURL)
                self.bigEvents = try JSONDecoder().decode([BigEvent].self, from: data)
                saveData() // 将初始配置写入本地
            } catch {
                print("Failed to load default data: \(error)")
            }
        } else {
            print("default_events.json not found in bundle.")
        }
    }
    
    func saveData() {
        guard let url = fileURL else { return }
        do {
            let data = try JSONEncoder().encode(bigEvents)
            try data.write(to: url)
            
            #if canImport(WidgetKit)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
        } catch {
            print("Failed to save data: \(error)")
        }
    }
    
    // 操作小项目
    func toggleAddedStatus(for bigEventName: String, smallEventName: String) -> Bool {
        // 判断当前已添加的总数
        let currentAddedCount = bigEvents.flatMap { $0.subEvents }.filter { $0.isAdded }.count
        
        guard let bIndex = bigEvents.firstIndex(where: { $0.name == bigEventName }),
              let sIndex = bigEvents[bIndex].subEvents.firstIndex(where: { $0.name == smallEventName }) else {
            return false
        }
        
        let currentState = bigEvents[bIndex].subEvents[sIndex].isAdded
        
        // 如果要添加，且已经达到 10 个，则拦截并返回 false (表示需要弹窗)
        if !currentState && currentAddedCount >= 10 {
            return false
        }
        
        bigEvents[bIndex].subEvents[sIndex].isAdded.toggle()
        saveData()
        return true
    }
    
    func updateTimeRecord(for bigEventName: String, smallEventName: String, record: TimeRecord?) {
        guard let bIndex = bigEvents.firstIndex(where: { $0.name == bigEventName }),
              let sIndex = bigEvents[bIndex].subEvents.firstIndex(where: { $0.name == smallEventName }) else {
            return
        }
        bigEvents[bIndex].subEvents[sIndex].timeRecord = record
        saveData()
    }
}
