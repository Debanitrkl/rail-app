import SwiftUI
import WidgetKit

struct JourneyWidgetView: View {
    let entry: JourneyWidgetEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        default:
            smallWidget
        }
    }

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.trainNumber)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(hex: 0xE4A853))

                Spacer()

                Text(entry.status)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(entry.delayMinutes <= 0 ? Color(hex: 0x34D399) : Color(hex: 0xF87171))
            }

            Text(entry.trainName)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(1)

            Spacer()

            HStack {
                Text(entry.from)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))

                Spacer()

                Text("→")
                    .foregroundStyle(.white.opacity(0.3))

                Spacer()

                Text(entry.to)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
            }

            HStack {
                Text("PF \(entry.platform)")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(hex: 0xE4A853))

                Spacer()

                Text(entry.departureTime)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding(4)
    }

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.trainNumber)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(hex: 0xE4A853))

                Text(entry.trainName)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)

                Spacer()

                HStack {
                    Text(entry.from)
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                    Text("→")
                        .foregroundStyle(.white.opacity(0.3))
                    Text(entry.to)
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Text(entry.status)
                    .font(.system(size: 11, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        (entry.delayMinutes <= 0 ? Color(hex: 0x34D399) : Color(hex: 0xF87171)).opacity(0.15)
                    )
                    .foregroundStyle(entry.delayMinutes <= 0 ? Color(hex: 0x34D399) : Color(hex: 0xF87171))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("PF \(entry.platform)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(hex: 0xE4A853))

                    Text(entry.departureTime)
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                }
            }
        }
        .padding(4)
    }
}
