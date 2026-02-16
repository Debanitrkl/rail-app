import SwiftUI

struct DetailHeroView: View {
    let train: Train
    let journey: Journey?

    var body: some View {
        ZStack {
            // Background glow
            RadialGradient(
                colors: [Color.accentGlow, .clear],
                center: .top,
                startRadius: 0,
                endRadius: 300
            )
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 0) {
                // Train number
                Text(train.number)
                    .font(.railMono(12, weight: .semibold))
                    .foregroundStyle(Color.accent)
                    .tracking(0.72)

                // Train name
                Text(train.name)
                    .font(.railDisplay(28))
                    .tracking(-0.56)
                    .padding(.top, 4)

                // Route
                HStack(alignment: .top, spacing: 0) {
                    // Origin
                    VStack(alignment: .leading, spacing: 4) {
                        Text(train.source.code)
                            .font(.railMono(36, weight: .bold))
                            .tracking(-1.08)

                        Text(train.source.name)
                            .font(.railBody(12))
                            .foregroundStyle(Color.textSecondary)

                        if let sched = train.schedule?.first {
                            HStack(spacing: 0) {
                                Text(journey?.travelDate.prefix(6).description ?? "16 Feb")
                                    .font(.railMono(13))
                                    .foregroundStyle(Color.textTertiary)
                                Text(" • ")
                                    .foregroundStyle(Color.textTertiary)
                                Text(sched.departureTime ?? "")
                                    .font(.railMono(18, weight: .semibold))
                                    .foregroundStyle(Color.textPrimary)
                            }
                            .padding(.top, 2)
                        }
                    }

                    Spacer()

                    // Middle
                    VStack(spacing: 6) {
                        Text(String.duration(minutes: train.durationMinutes))
                            .font(.railMono(13, weight: .medium))
                            .foregroundStyle(Color.textSecondary)

                        Text("→")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.textTertiary)

                        Text(String.distanceFormatted(km: train.distanceKm))
                            .font(.railBody(11))
                            .foregroundStyle(Color.textTertiary)
                    }
                    .padding(.horizontal, 12)

                    // Destination
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(train.destination.code)
                            .font(.railMono(36, weight: .bold))
                            .tracking(-1.08)

                        Text(train.destination.name)
                            .font(.railBody(12))
                            .foregroundStyle(Color.textSecondary)

                        if let sched = train.schedule?.last {
                            HStack(spacing: 0) {
                                Text("17 Feb")
                                    .font(.railMono(13))
                                    .foregroundStyle(Color.textTertiary)
                                Text(" • ")
                                    .foregroundStyle(Color.textTertiary)
                                Text(sched.arrivalTime ?? "")
                                    .font(.railMono(18, weight: .semibold))
                                    .foregroundStyle(Color.textPrimary)
                            }
                            .padding(.top, 2)
                        }
                    }
                }
                .padding(.top, 24)
            }
            .padding(.horizontal, RailSpacing.pageHeaderHorizontal)
            .padding(.vertical, 8)
        }
        .padding(.bottom, 24)
    }
}
