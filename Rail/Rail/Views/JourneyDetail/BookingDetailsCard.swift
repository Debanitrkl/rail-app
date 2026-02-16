import SwiftUI

struct BookingDetailsCard: View {
    let journey: Journey

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Booking Details")
                .font(.railBody(11, weight: .semibold))
                .tracking(0.66)
                .textCase(.uppercase)
                .foregroundStyle(Color.textTertiary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                BookingField(label: "PNR", value: journey.pnr?.formattedPNR ?? "—", mono: true)
                BookingField(label: "Class", value: classLabel)
                BookingField(label: "Coach / Berth", value: coachBerthLabel, mono: true)
                BookingField(label: "Status", value: "Confirmed", valueColor: .railGreen)
                BookingField(label: "Quota", value: "General")
                BookingField(label: "Passengers", value: "1 Adult")
            }
        }
        .padding(RailSpacing.cardPadding)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: RailSpacing.cardRadius))
        .overlay {
            RoundedRectangle(cornerRadius: RailSpacing.cardRadius)
                .stroke(Color.border, lineWidth: 1)
        }
        .padding(.horizontal, RailSpacing.screenHorizontal)
        .padding(.bottom, 16)
    }

    private var classLabel: String {
        switch journey.travelClass {
        case "1AC", "1A": return "AC 1 Tier"
        case "2AC", "2A": return "AC 2 Tier"
        case "3AC", "3A": return "AC 3 Tier"
        case "SL": return "Sleeper"
        default: return journey.travelClass ?? "—"
        }
    }

    private var coachBerthLabel: String {
        let coach = journey.coach ?? "—"
        let berth = journey.berth ?? "—"
        return "\(coach) / \(berth)"
    }
}

struct BookingField: View {
    let label: String
    let value: String
    var mono: Bool = false
    var valueColor: Color = .textPrimary

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.railBody(10, weight: .semibold))
                .tracking(0.6)
                .textCase(.uppercase)
                .foregroundStyle(Color.textTertiary)

            Text(value)
                .font(mono ? .railMono(14) : .railBody(15, weight: .semibold))
                .foregroundStyle(valueColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
