import SwiftUI

struct StationStatsView: View {
    let station: Station

    var body: some View {
        HStack(spacing: 12) {
            StatItem(label: "Platforms", value: "\(station.platformsCount)")
            StatItem(label: "Zone", value: station.zone)
            StatItem(label: "Division", value: station.division)
            if station.amenities.wifi {
                StatItem(label: "WiFi", value: "Yes")
            }
        }
        .padding(.horizontal, RailSpacing.screenHorizontal)
        .padding(.bottom, 16)
    }
}

struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.railMono(16, weight: .bold))
                .foregroundStyle(Color.accent)
            Text(label)
                .font(.railBody(10, weight: .semibold))
                .tracking(0.5)
                .textCase(.uppercase)
                .foregroundStyle(Color.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: RailSpacing.mediumRadius))
        .overlay {
            RoundedRectangle(cornerRadius: RailSpacing.mediumRadius)
                .stroke(Color.border, lineWidth: 1)
        }
    }
}
