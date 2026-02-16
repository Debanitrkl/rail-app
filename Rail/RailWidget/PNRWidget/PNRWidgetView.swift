import SwiftUI
import WidgetKit

struct PNRWidgetView: View {
    let entry: PNRWidgetEntry

    private var statusColor: Color {
        let s = entry.status.uppercased()
        if s.contains("CNF") || s.contains("CONFIRM") { return Color(hex: 0x34D399) }
        if s.contains("WL") { return Color(hex: 0xF87171) }
        if s.contains("RAC") { return Color(hex: 0xFBBF24) }
        return .white.opacity(0.55)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("PNR")
                .font(.system(size: 10, weight: .semibold))
                .tracking(0.6)
                .textCase(.uppercase)
                .foregroundStyle(.white.opacity(0.3))

            Text(entry.pnr)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .tracking(0.5)

            Spacer()

            Text(entry.status)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(statusColor)

            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Coach")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.3))
                    Text(entry.coach)
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text("Berth")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.3))
                    Text(entry.berth)
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                }
            }
        }
        .padding(4)
    }
}

// Color extension for Widget target
extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
