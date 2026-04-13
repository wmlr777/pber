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

// MARK: - Time Model
struct SavedTime: Codable {
    var hour: Int
    var minute: Int
    var second: Int
}

// MARK: - Storage Manager
class TimeStorageManager: ObservableObject {
    @Published var savedTimes: [String: SavedTime] = [:]
    
    private let fileName = "pb_time_setting.json"
    
    private var fileURL: URL? {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.pb.shared")
        return container?.appendingPathComponent(fileName)
    }
    
    init() {
        loadTime()
    }
    
    func loadTime() {
        guard let url = fileURL else { return }
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                let data = try Data(contentsOf: url)
                let times = try JSONDecoder().decode([String: SavedTime].self, from: data)
                self.savedTimes = times
            }
        } catch {
            print("Failed to load time: \(error)")
        }
    }
    
    func saveTime(for key: String, hour: Int, minute: Int, second: Int) {
        savedTimes[key] = SavedTime(hour: hour, minute: minute, second: second)
        saveToFile()
    }
    
    func removeTime(for key: String) {
        savedTimes.removeValue(forKey: key)
        saveToFile()
    }
    
    private func saveToFile() {
        guard let url = fileURL else { return }
        do {
            let data = try JSONEncoder().encode(savedTimes)
            try data.write(to: url)
            #if canImport(WidgetKit)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
        } catch {
            print("Failed to save time: \(error)")
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @State private var selectedTab = 0
    let bgColor = Color(hex: "070303")
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page Content
                TabView(selection: $selectedTab) {
                    TimeRecordsView()
                        .tag(0)
                    SecondView()
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
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
