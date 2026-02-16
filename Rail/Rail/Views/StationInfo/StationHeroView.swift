import SwiftUI

struct StationHeroView: View {
    let station: Station

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Station code - large mono gradient
            Text(station.code)
                .font(.railMono(48, weight: .bold))
                .tracking(-1.92)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.textPrimary, .textSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Station name
            Text(station.name)
                .font(.railDisplay(22))
                .foregroundStyle(Color.textPrimary)
                .padding(.top, 4)

            // Zone badge
            HStack(spacing: 6) {
                Image(systemName: "location.fill")
                    .font(.system(size: 12))

                Text("\(station.zone) Zone")
                    .font(.railBody(12, weight: .semibold))
            }
            .foregroundStyle(Color.accent)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.accentGlow)
            .clipShape(RoundedRectangle(cornerRadius: RailSpacing.badgeRadius))
            .padding(.top, 8)
        }
        .padding(.horizontal, RailSpacing.pageHeaderHorizontal)
        .padding(.bottom, 20)
    }
}
