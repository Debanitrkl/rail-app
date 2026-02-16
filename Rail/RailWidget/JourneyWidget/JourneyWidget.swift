import WidgetKit
import SwiftUI

struct JourneyWidgetEntry: TimelineEntry {
    let date: Date
    let trainNumber: String
    let trainName: String
    let from: String
    let to: String
    let departureTime: String
    let status: String
    let delayMinutes: Int
    let platform: String
}

struct JourneyWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> JourneyWidgetEntry {
        JourneyWidgetEntry(
            date: Date(),
            trainNumber: "12952",
            trainName: "Rajdhani Express",
            from: "NDLS",
            to: "BCT",
            departureTime: "16:55",
            status: "On Time",
            delayMinutes: 0,
            platform: "3"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (JourneyWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<JourneyWidgetEntry>) -> Void) {
        let entry = placeholder(in: context)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(300)))
        completion(timeline)
    }
}

struct JourneyWidget: Widget {
    let kind = "JourneyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: JourneyWidgetProvider()) { entry in
            JourneyWidgetView(entry: entry)
                .containerBackground(Color(hex: 0x08080A), for: .widget)
        }
        .configurationDisplayName("Journey")
        .description("Track your active journey")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
