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
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), records: [])
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let events = loadRecords()
        return SimpleEntry(date: Date(), configuration: configuration, records: events)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let events = loadRecords()
        let entry = SimpleEntry(date: Date(), configuration: configuration, records: events)
        return Timeline(entries: [entry], policy: .atEnd)
    }
    
    private func loadRecords() -> [Record] {
        let fileName = "records.json"
        
        if let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.pb.shared") {
            let fileURL = container.appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let decoded = try JSONDecoder().decode([Record].self, from: data)
                    return decoded
                } catch {
                    print("Widget failed to load user records: \(error)")
                }
            }
        }
        
        return []
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let records: [Record]
}

struct pbWidgetEntryView : View {
    var entry: Provider.Entry

    let textBoxColor = Color(hex: "F7F6E5")
    let textColor = Color.black

    func calculatePace(hours: Int, minutes: Int, seconds: Int, distance: Double) -> (min: String, sec: String) {
        let totalSeconds = Double(hours * 3600 + minutes * 60 + seconds)
        guard totalSeconds > 0, distance > 0 else { return ("--", "--") }
        let paceSeconds = totalSeconds / distance
        let pMin = Int(paceSeconds) / 60
        let pSec = Int(paceSeconds) % 60
        return (String(format: "%02d", pMin), String(format: "%02d", pSec))
    }
    
    private var activeEvents: [Record] {
        return Array(entry.records.prefix(5))
    }

    var body: some View {
        VStack(spacing: 8) {
            let events = activeEvents
            if events.isEmpty {
                Text("暂无数据")
                    .foregroundColor(.white)
                    .font(.footnote)
            } else {
                ForEach(Array(events.enumerated()), id: \.element.id) { index, record in
                    let calculatedWidth: CGFloat = 30 + CGFloat(index) * 8
                    HStack(spacing: 8) {
                        // Left Distance Box
                        Text(record.distanceStr)
                            .font(.system(size: 11, weight: .bold))
                            .italic()
                            .foregroundColor(.black)
                            .frame(width: calculatedWidth, height: 20)
                            .background(
                                SkewedRectangle()
                                    .fill(Color(hex: record.colorHex))
                                    .overlay(
                                        SkewedRectangle()
                                            .stroke(Color.white, lineWidth: 1.5)
                                    )
                            )
                        
                        // Right Boxes (Time and Pace)
                        HStack(spacing: 8) {
                            // Time Box
                            HStack(spacing: 0) {
                                let h = (record.targetHours > 0) ? String(format: "%02d", record.targetHours) : "--"
                                let m = (record.targetHours > 0 || record.targetMinutes > 0) ? String(format: "%02d", record.targetMinutes) : "--"
                                let s = (record.targetHours > 0 || record.targetMinutes > 0 || record.targetSeconds > 0) ? String(format: "%02d", record.targetSeconds) : "--"
                                
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
                                let paceStr = calculatePace(hours: record.targetHours, minutes: record.targetMinutes, seconds: record.targetSeconds, distance: record.distance)
                                
                                Text(paceStr.min).frame(width: 14)
                                Text("'")
                                Text(paceStr.sec).frame(width: 14)
                                Text("\"")
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
    SimpleEntry(date: .now, configuration: .smiley, records: [])
}
