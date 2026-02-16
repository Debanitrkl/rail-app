import WidgetKit
import SwiftUI

struct PNRWidgetEntry: TimelineEntry {
    let date: Date
    let pnr: String
    let trainNumber: String
    let status: String
    let coach: String
    let berth: String
}

struct PNRWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> PNRWidgetEntry {
        PNRWidgetEntry(
            date: Date(),
            pnr: "284-7193820",
            trainNumber: "12952",
            status: "Confirmed",
            coach: "B4",
            berth: "32-LB"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PNRWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PNRWidgetEntry>) -> Void) {
        let entry = placeholder(in: context)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(600)))
        completion(timeline)
    }
}

struct PNRWidget: Widget {
    let kind = "PNRWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PNRWidgetProvider()) { entry in
            PNRWidgetView(entry: entry)
                .containerBackground(Color(hex: 0x08080A), for: .widget)
        }
        .configurationDisplayName("PNR Status")
        .description("Monitor your PNR booking status")
        .supportedFamilies([.systemSmall])
    }
}
