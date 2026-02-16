import ActivityKit
import WidgetKit
import SwiftUI

struct RailLiveActivityView: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RailActivityAttributes.self) { context in
            // Lock screen / banner view
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.state.trainNumber)
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Color(hex: 0xE4A853))

                        Text(context.state.trainName)
                            .font(.system(size: 15, weight: .semibold))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(context.state.delayMinutes <= 0 ? "On Time" : "Late \(context.state.delayMinutes)m")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(context.state.delayMinutes <= 0 ? Color(hex: 0x34D399) : Color(hex: 0xF87171))

                        Text("ETA \(context.state.eta)")
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    }
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.white.opacity(0.1))
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hex: 0xE4A853))
                            .frame(width: geo.size.width * context.state.progress, height: 4)
                    }
                }
                .frame(height: 4)

                HStack {
                    Text(context.state.fromCode)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))

                    Spacer()

                    Text("Nr. \(context.state.currentStation)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))

                    Spacer()

                    Text(context.state.toCode)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                }
            }
            .padding(16)
            .activityBackgroundTint(Color(hex: 0x08080A))

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.state.trainNumber)
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Color(hex: 0xE4A853))
                        Text(context.state.fromCode)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(context.state.delayMinutes <= 0 ? "On Time" : "+\(context.state.delayMinutes)m")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(context.state.delayMinutes <= 0 ? Color(hex: 0x34D399) : Color(hex: 0xF87171))
                        Text(context.state.toCode)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    Text("→ \(context.state.nextStation)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Label("\(Int(context.state.speedKmph)) km/h", systemImage: "gauge.with.needle")
                            .font(.system(size: 11, weight: .medium))
                        Spacer()
                        Label("PF \(context.state.platform)", systemImage: "building.2")
                            .font(.system(size: 11, weight: .medium))
                        Spacer()
                        Label("ETA \(context.state.eta)", systemImage: "clock")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(.white.opacity(0.6))
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Image(systemName: "tram.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color(hex: 0xE4A853))
                    Text(context.state.trainNumber)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                }
            } compactTrailing: {
                Text(context.state.delayMinutes <= 0 ? "On Time" : "+\(context.state.delayMinutes)m")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(context.state.delayMinutes <= 0 ? Color(hex: 0x34D399) : Color(hex: 0xF87171))
            } minimal: {
                Image(systemName: "tram.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: 0xE4A853))
            }
        }
    }
}
