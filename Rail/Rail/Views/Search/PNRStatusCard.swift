import SwiftUI

struct PNRStatusCard: View {
    let pnr: PNRStatus

    private var overallBadge: (String, BadgeView.BadgeStyle) {
        let status = pnr.currentStatus.uppercased()
        if status.contains("CNF") || status.contains("CONFIRM") {
            return ("Confirmed", .confirmed)
        } else if status.contains("WL") {
            return ("WL \(pnr.currentStatus)", .waitlist)
        } else if status.contains("RAC") {
            return ("RAC", .rac)
        }
        return (pnr.currentStatus, .scheduled)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("PNR Number")
                        .font(.railBody(10, weight: .semibold))
                        .tracking(0.6)
                        .textCase(.uppercase)
                        .foregroundStyle(Color.textTertiary)

                    Text(pnr.pnr.formattedPNR)
                        .font(.railMono(22, weight: .bold))
                        .tracking(0.88)
                }

                Spacer()

                BadgeView(text: overallBadge.0, style: overallBadge.1)
            }

            // Train info
            HStack(spacing: 8) {
                Text(pnr.trainNumber)
                    .font(.railMono(11, weight: .semibold))
                    .foregroundStyle(Color.accent)
                Text(pnr.trainName)
                    .font(.railBody(13, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
            }

            Text("\(pnr.from) → \(pnr.to)")
                .font(.railMono(13))
                .foregroundStyle(Color.textSecondary)

            // Passengers
            Divider().background(Color.border)

            ForEach(pnr.passengers) { passenger in
                PassengerRow(passenger: passenger)
            }
        }
        .padding(RailSpacing.cardPadding)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: 0x1A1714),
                    Color.bgCard,
                    Color(hex: 0x151520)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: RailSpacing.cardRadius))
        .overlay {
            RoundedRectangle(cornerRadius: RailSpacing.cardRadius)
                .stroke(Color.borderAccent, lineWidth: 1)
        }
        .overlay(alignment: .topTrailing) {
            RadialGradient(
                colors: [Color.accentGlow, .clear],
                center: .center,
                startRadius: 0,
                endRadius: 75
            )
            .frame(width: 150, height: 150)
            .allowsHitTesting(false)
        }
        .padding(.horizontal, RailSpacing.screenHorizontal)
        .padding(.bottom, 16)
    }
}

struct PassengerRow: View {
    let passenger: PNRPassenger

    var body: some View {
        HStack {
            Text("Passenger \(passenger.number)")
                .font(.railBody(14, weight: .medium))

            Spacer()

            Text(passenger.displayStatus)
                .font(.railMono(13, weight: .semibold))
                .foregroundStyle(passenger.statusColor)

            if passenger.currentStatus.uppercased().contains("CNF") {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.railGreen)
            }
        }
        .padding(.vertical, 10)
    }
}
