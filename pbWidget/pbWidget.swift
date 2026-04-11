import WidgetKit
import SwiftUI

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

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), savedTimes: [:])
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let times = loadSavedTimes()
        return SimpleEntry(date: Date(), configuration: configuration, savedTimes: times)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let times = loadSavedTimes()
        let entry = SimpleEntry(date: Date(), configuration: configuration, savedTimes: times)
        return Timeline(entries: [entry], policy: .atEnd)
    }
    
    private func loadSavedTimes() -> [String: SavedTime] {
        let fileName = "pb_time_setting.json"
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.pb.shared") else { return [:] }
        let fileURL = container.appendingPathComponent(fileName)
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                let data = try Data(contentsOf: fileURL)
                return try JSONDecoder().decode([String: SavedTime].self, from: data)
            }
        } catch {
            print("Widget failed to load time: \(error)")
        }
        return [:]
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let savedTimes: [String: SavedTime]
}

struct pbWidgetEntryView : View {
    var entry: Provider.Entry

    let distances = [
        ("1k", Color(hex: "A0D585")),
        ("5k", Color(hex: "F9F6C4")),
        ("10k", Color(hex: "FE9EC7")),
        ("21.0975k", Color(hex: "AACDDC")),
        ("42.195k", Color(hex: "81A6C6"))
    ]
    let textBoxColor = Color(hex: "F7F6E5")
    let textColor = Color.black

    var body: some View {
        VStack(spacing: 8) {
            ForEach(distances, id: \.0) { item in
                HStack {
                    Text(item.0)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 60, height: 20)
                        .background(item.1)
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        let time = entry.savedTimes[item.0]
                        let h = time.map { String(format: "%02d", $0.hour) } ?? "--"
                        let m = time.map { String(format: "%02d", $0.minute) } ?? "--"
                        let s = time.map { String(format: "%02d", $0.second) } ?? "--"
                        
                        Text(h)
                            .frame(width: 18)
                        Text(":")
                        Text(m)
                            .frame(width: 18)
                        Text(":")
                        Text(s)
                            .frame(width: 18)
                    }
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(textColor)
                    .padding(.horizontal, 8)
                    .frame(height: 20)
                    .background(textBoxColor)
                    .cornerRadius(6)
                }
            }
        }
    }
}

struct pbWidget: Widget {
    let kind: String = "pbWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            pbWidgetEntryView(entry: entry)
                .containerBackground(Color(hex: "070303"), for: .widget)
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("跑步时间小组件")
        .description("展示您设定的各个跑步距离目标时间。")
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
}

#Preview(as: .systemMedium) {
    pbWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, savedTimes: [:])
}
