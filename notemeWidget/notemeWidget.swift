//
//  notemeWidget.swift
//  notemeWidget
//
//  Created by wenmo on 2026/4/10.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of a single entry at the current date.
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate, configuration: configuration)
        entries.append(entry)

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct notemeWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("小组件")
                .font(.headline)
        }
    }
}

struct notemeWidget: Widget {
    let kind: String = "notemeWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            notemeWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("Noteme 小组件")
        .description("这是一个仅支持中号尺寸的示例小组件")
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
    notemeWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
}
