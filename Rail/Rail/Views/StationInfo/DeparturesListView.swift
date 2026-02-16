import SwiftUI

struct DeparturesListView: View {
    let departures: [StationTrain]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(departures) { dep in
                DepartureRow(departure: dep)
            }
        }
        .padding(.horizontal, RailSpacing.screenHorizontal)
    }
}

struct DepartureRow: View {
    let departure: StationTrain

    var body: some View {
        HStack(spacing: 14) {
            // Time
            Text(departure.departureTime ?? "—")
                .font(.railMono(18, weight: .bold))
                .frame(minWidth: 56, alignment: .leading)

            // Train info
            VStack(alignment: .leading, spacing: 2) {
                Text(departure.trainName)
                    .font(.railBody(14, weight: .semibold))
                    .lineLimit(1)

                Text("\(departure.trainNumber)")
                    .font(.railMono(12))
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            // Platform
            if let platform = departure.platform {
                VStack(spacing: 0) {
                    Text(platform)
                        .font(.railMono(20, weight: .bold))
                        .foregroundStyle(Color.accent)
                    Text("Platform")
                        .font(.railBody(8, weight: .semibold))
                        .tracking(0.64)
                        .textCase(.uppercase)
                        .foregroundStyle(Color.textTertiary)
                }
            }
        }
        .padding(16)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: RailSpacing.largeRadius))
        .overlay {
            RoundedRectangle(cornerRadius: RailSpacing.largeRadius)
                .stroke(Color.border, lineWidth: 1)
        }
    }
}
