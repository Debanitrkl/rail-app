import SwiftUI
import MapKit

struct IndiaMapView: View {
    let trains: [LiveTrainPosition]
    var onTrainTapped: ((String) -> Void)?

    // India center and span
    private let indiaCenter = CLLocationCoordinate2D(latitude: 22.5, longitude: 79.5)
    private let indiaSpan = MKCoordinateSpan(latitudeDelta: 28, longitudeDelta: 28)

    @State private var selectedTrain: LiveTrainPosition?

    private var validTrains: [LiveTrainPosition] {
        trains.filter { $0.latitude > 6 && $0.latitude < 37 && $0.longitude > 66 && $0.longitude < 99 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            header

            // Apple Map
            Map(initialPosition: .region(MKCoordinateRegion(center: indiaCenter, span: indiaSpan)),
                interactionModes: [.pan, .zoom]) {
                ForEach(validTrains, id: \.trainNumber) { train in
                    Annotation(
                        train.trainNumber,
                        coordinate: CLLocationCoordinate2D(
                            latitude: train.latitude,
                            longitude: train.longitude
                        ),
                        anchor: .center
                    ) {
                        TrainAnnotationView(train: train) {
                            onTrainTapped?(train.trainNumber)
                        }
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat, emphasis: .muted, pointsOfInterest: .excludingAll, showsTraffic: false))
            .frame(height: 420)
            .allowsHitTesting(true)

            // Legend
            legend
        }
        .background(Color.bgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: RailSpacing.cardRadius))
        .overlay {
            RoundedRectangle(cornerRadius: RailSpacing.cardRadius)
                .stroke(Color.border, lineWidth: 1)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("LIVE TRAINS")
                    .font(.railBody(10, weight: .semibold))
                    .tracking(1.5)
                    .foregroundStyle(Color.accent.opacity(0.6))

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(validTrains.count)")
                        .font(.railMono(32, weight: .bold))
                        .foregroundStyle(Color.textPrimary)
                    Text("active")
                        .font(.railBody(14, weight: .medium))
                        .foregroundStyle(Color.textTertiary)
                }
            }
            Spacer()
            HStack(spacing: 6) {
                PulseDot(color: .railGreen, size: 8)
                Text("LIVE")
                    .font(.railMono(10, weight: .semibold))
                    .foregroundStyle(Color.railGreen.opacity(0.8))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.railGreen.opacity(0.1))
            .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 12)
    }

    // MARK: - Legend

    private var legend: some View {
        HStack(spacing: 20) {
            legendItem(color: .railGreen, label: "On Time")
            legendItem(color: .railYellow, label: "Delayed")
            legendItem(color: .railRed, label: "Late")
            Spacer()
            Text("Tap for details")
                .font(.railBody(10))
                .foregroundStyle(Color.textTertiary.opacity(0.6))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.02))
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(label)
                .font(.railBody(11, weight: .medium))
                .foregroundStyle(Color.textSecondary)
        }
    }
}

// MARK: - Train Annotation View

private struct TrainAnnotationView: View {
    let train: LiveTrainPosition
    let onTap: () -> Void

    private var color: Color {
        if train.delayMinutes <= 0 {
            return .railGreen
        } else if train.delayMinutes <= 15 {
            return .railYellow
        } else {
            return .railRed
        }
    }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Glow
                Circle()
                    .fill(color.opacity(0.25))
                    .frame(width: 28, height: 28)

                // Dot
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
                    .shadow(color: color.opacity(0.5), radius: 6, x: 0, y: 0)

                // Highlight
                Circle()
                    .fill(.white.opacity(0.7))
                    .frame(width: 4, height: 4)
            }
        }
        .buttonStyle(.plain)
    }
}
