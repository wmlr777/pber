import SwiftUI
import Combine
import WidgetKit

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

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

// MARK: - Main Content View
struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var dataManager = DataManager()
    let bgColor = Color(hex: "070303")
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page Content
                TabView(selection: $selectedTab) {
                    TimeRecordsView()
                        .tag(0)
                    SportsGalleryView()
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .environmentObject(dataManager)
                
                // Custom Bottom Tab Bar
                VStack(spacing: 0) {
                    // Horizontal Divider
                    Rectangle()
                        .fill(Color(hex: "333333")) // Dark gray divider
                        .frame(height: 1.5)
                    
                    ZStack {
                        HStack(spacing: 0) {
                            Spacer()
                            
                            Circle()
                                .fill(selectedTab == 0 ? Color.white : Color.black)
                                .frame(width: 20, height: 20)
                                .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation {
                                        selectedTab = 0
                                    }
                                }
                            
                            Spacer()
                            
                            Circle()
                                .fill(selectedTab == 1 ? Color.white : Color.black)
                                .frame(width: 20, height: 20)
                                .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation {
                                        selectedTab = 1
                                    }
                                }
                            
                            Spacer()
                        }
                        
                        // Vertical Divider
                        Rectangle()
                            .fill(Color(hex: "333333")) // Dark gray divider
                            .frame(width: 1.5, height: 24)
                    }
                    .padding(.bottom, 20)
                    .padding(.top, 15)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
