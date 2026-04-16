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

// MARK: - Skewed Rectangle Shape
struct SkewedRectangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let offset: CGFloat = 1
        
        path.move(to: CGPoint(x: offset, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX - offset, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.closeSubpath()
        
        return path
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

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), bigEvents: [])
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let events = loadBigEvents()
        return SimpleEntry(date: Date(), configuration: configuration, bigEvents: events)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let events = loadBigEvents()
        let entry = SimpleEntry(date: Date(), configuration: configuration, bigEvents: events)
        return Timeline(entries: [entry], policy: .atEnd)
    }
    
    private func loadBigEvents() -> [BigEvent] {
        let fileName = "pb_events_setting.json"
        
        // 尝试从 App Group 中读取最新数据
        if let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.pb.shared") {
            let fileURL = container.appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let decoded = try JSONDecoder().decode([BigEvent].self, from: data)
                    if !decoded.isEmpty {
                        return decoded
                    }
                } catch {
                    print("Widget failed to load user events: \(error)")
                }
            }
        }
        
        // 如果 App Group 中没有数据，尝试从 Bundle 中加载 default_events.json（例如预览或首次启动还未打开主应用时）
        if let bundleURL = Bundle.main.url(forResource: "default_events", withExtension: "json") {
            do {
                let data = try Data(contentsOf: bundleURL)
                let decoded = try JSONDecoder().decode([BigEvent].self, from: data)
                return decoded
            } catch {
                print("Widget failed to load default events: \(error)")
            }
        }
        
        return []
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let bigEvents: [BigEvent]
}

struct pbWidgetEntryView : View {
    var entry: Provider.Entry

    let textBoxColor = Color(hex: "F7F6E5")
    let textColor = Color.black

    func calculatePace(time: TimeRecord?, distance: Double?) -> (min: String, sec: String) {
        guard let t = time, !t.isEmpty, let dist = distance, dist > 0 else {
            return ("--", "--")
        }
        let totalSeconds = Double(t.hour * 3600 + t.minute * 60 + t.second)
        guard totalSeconds > 0 else { return ("--", "--") }
        let paceSeconds = (totalSeconds / dist) * 1000.0
        let pMin = Int(paceSeconds) / 60
        let pSec = Int(paceSeconds) % 60
        return (String(format: "%02d", pMin), String(format: "%02d", pSec))
    }
    
    private var activeEvents: [SmallEvent] {
        var results: [SmallEvent] = []
        for bigEvent in entry.bigEvents {
            for smallEvent in bigEvent.subEvents where smallEvent.isAdded && smallEvent.recordFormat == .time_hms {
                results.append(smallEvent)
            }
        }
        return Array(results.prefix(5))
    }

    var body: some View {
        VStack(spacing: 8) {
            let events = activeEvents
            if events.isEmpty {
                Text("暂无数据")
                    .foregroundColor(.white)
                    .font(.footnote)
            } else {
                ForEach(Array(events.enumerated()), id: \.element.id) { index, smallEvent in
                    let calculatedWidth: CGFloat = 30 + CGFloat(index) * 8
                    HStack(spacing: 8) {
                        // Left Distance Box
                        Text(smallEvent.name)
                            .font(.system(size: 11, weight: .bold))
                            .italic()
                            .foregroundColor(.black)
                            .frame(width: calculatedWidth, height: 20)
                            .background(
                                SkewedRectangle()
                                    .fill(Color(hex: smallEvent.colorHex))
                                    .overlay(
                                        SkewedRectangle()
                                            .stroke(Color.white, lineWidth: 1.5)
                                    )
                            )
                        
                        // Right Boxes (Time and Pace)
                        HStack(spacing: 8) {
                            // Time Box
                            HStack(spacing: 0) {
                                let time = smallEvent.timeRecord
                                let h = (time?.isEmpty == false) ? String(format: "%02d", time!.hour) : "--"
                                let m = (time?.isEmpty == false) ? String(format: "%02d", time!.minute) : "--"
                                let s = (time?.isEmpty == false) ? String(format: "%02d", time!.second) : "--"
                                
                                Text(h).frame(width: 14)
                                Text(":")
                                Text(m).frame(width: 14)
                                Text(":")
                                Text(s).frame(width: 14)
                            }
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(textColor)
                            .padding(.horizontal, 8)
                            .frame(maxWidth: .infinity, minHeight: 20, alignment: .center)
                            .background(
                                SkewedRectangle().fill(textBoxColor)
                            )
                            
                            // Pace Box
                            HStack(spacing: 0) {
                                if smallEvent.isPaceValid == true {
                                    let paceStr = calculatePace(time: smallEvent.timeRecord, distance: smallEvent.distance)
                                    
                                    Text(paceStr.min).frame(width: 14)
                                    Text("'")
                                    Text(paceStr.sec).frame(width: 14)
                                    Text("\"")
                                } else {
                                    Text("--").frame(width: 14)
                                    Text("'")
                                    Text("--").frame(width: 14)
                                    Text("\"")
                                }
                            }
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(textColor)
                            .padding(.horizontal, 8)
                            .frame(maxWidth: .infinity, minHeight: 20, alignment: .center)
                            .background(
                                SkewedRectangle().fill(textBoxColor)
                            )
                        }
                        .frame(maxWidth: .infinity)
                    }
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
    SimpleEntry(date: .now, configuration: .smiley, bigEvents: [])
}
