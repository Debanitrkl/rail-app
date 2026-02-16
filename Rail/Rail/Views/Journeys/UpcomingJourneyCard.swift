import SwiftUI

struct UpcomingJourneyCard: View {
    let journey: Journey

    private var monthStr: String {
        journey.travelDateParsed?.railFormatted(style: .monthShort).uppercased() ?? "---"
    }

    private var dayStr: String {
        journey.travelDateParsed?.railFormatted(style: .dayOnly) ?? "--"
    }

    private var departureTime: String {
        journey.travelDateParsed?.railFormatted(style: .time24) ?? "06:00"
    }

    private var classLabel: String {
        journey.travelClass?.uppercased() ?? "SL"
    }

    var body: some View {
        RailCard {
            HStack(spacing: 14) {
                // Date block
                VStack(spacing: 1) {
                    Text(dayStr)
                        .font(.railMono(22, weight: .bold))
                        .foregroundStyle(Color.textPrimary)
                    Text(monthStr)
                        .font(.railBody(10, weight: .semibold))
                        .tracking(0.6)
                        .foregroundStyle(Color.accent)
                }
                .frame(width: 48, height: 50)
                .background(Color.bgElevated)
                .clipShape(RoundedRectangle(cornerRadius: RailSpacing.smallRadius))

                // Center: Train + route + time
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(journey.trainNumber)
                            .font(.railMono(11, weight: .medium))
                            .foregroundStyle(Color.accent)
                        Text(journey.trainName)
                            .font(.railBody(14, weight: .semibold))
                            .lineLimit(1)
                    }

                    HStack(spacing: 4) {
                        Text(journey.boarding.code)
                            .font(.railMono(13, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.textTertiary)
                        Text(journey.destination.code)
                            .font(.railMono(13, weight: .semibold))
                        Text("•")
                            .foregroundStyle(Color.textTertiary)
                        Text(departureTime)
                            .font(.railMono(12, weight: .medium))
                            .foregroundStyle(Color.textSecondary)
                    }
                }

                Spacer()

                // Right: Class badge + chevron
                HStack(spacing: 10) {
                    Text(classLabel)
                        .font(.railMono(10, weight: .bold))
                        .tracking(0.5)
                        .foregroundStyle(Color.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentGlow)
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.textTertiary)
                }
            }
        }
    }
}
