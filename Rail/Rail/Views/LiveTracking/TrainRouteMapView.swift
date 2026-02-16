import MapKit
import SwiftUI

struct TrainRouteMapView: View {
    let geoRoute: [GeoRouteStop]
    let currentStopIndex: Int
    let trainCoordinate: CLLocationCoordinate2D?
    let speed: Double
    let eta: String
    let destinationCode: String

    @State private var mapCamera: MapCameraPosition = .automatic

    private var routeCoordinates: [CLLocationCoordinate2D] {
        geoRoute.map(\.coordinate)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $mapCamera, interactionModes: [.pan, .zoom]) {
                // Full route polyline
                if routeCoordinates.count >= 2 {
                    MapPolyline(coordinates: routeCoordinates)
                        .stroke(Color.accent.opacity(0.3), lineWidth: 3)
                }

                // Completed route polyline
                if currentStopIndex > 0 {
                    let completedCoords = Array(routeCoordinates.prefix(currentStopIndex + 1))
                    if completedCoords.count >= 2 {
                        MapPolyline(coordinates: completedCoords)
                            .stroke(Color.accent, lineWidth: 4)
                    }
                }

                // Station annotations
                ForEach(Array(geoRoute.enumerated()), id: \.element.id) { index, stop in
                    let isFirst = index == 0
                    let isLast = index == geoRoute.count - 1
                    let isPassed = index < currentStopIndex
                    let isCurrent = index == currentStopIndex

                    Annotation("", coordinate: stop.coordinate) {
                        StationDot(
                            code: stop.stationCode,
                            isEndpoint: isFirst || isLast,
                            isPassed: isPassed,
                            isCurrent: isCurrent
                        )
                    }
                }

                // Live train position
                if let trainCoord = trainCoordinate {
                    Annotation("", coordinate: trainCoord) {
                        LiveTrainDot()
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
            .colorScheme(.dark)
            .clipShape(RoundedRectangle(cornerRadius: RailSpacing.cardRadius))
            .overlay {
                RoundedRectangle(cornerRadius: RailSpacing.cardRadius)
                    .stroke(Color.border, lineWidth: 1)
            }

            // Overlay badges
            HStack(alignment: .bottom) {
                // Speed badge
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Int(speed))")
                            .font(.railMono(22, weight: .bold))
                            .foregroundStyle(Color.accent)
                        Text("km/h")
                            .font(.railBody(11, weight: .medium))
                            .foregroundStyle(Color.textSecondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.black.opacity(0.7))
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Spacer()

                // ETA badge
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Arriving \(destinationCode)")
                        .font(.railBody(10, weight: .semibold))
                        .tracking(0.5)
                        .textCase(.uppercase)
                        .foregroundStyle(Color.textTertiary)
                    Text(eta)
                        .font(.railMono(16, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.black.opacity(0.7))
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(16)
        }
        .frame(height: 280)
        .onAppear {
            fitCamera()
        }
        .onChange(of: geoRoute.count) {
            fitCamera()
        }
    }

    private func fitCamera() {
        guard !routeCoordinates.isEmpty else { return }
        let region = regionToFit(routeCoordinates)
        mapCamera = .region(region)
    }

    private func regionToFit(_ coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        var minLat = coordinates[0].latitude
        var maxLat = coordinates[0].latitude
        var minLon = coordinates[0].longitude
        var maxLon = coordinates[0].longitude

        for coord in coordinates {
            minLat = min(minLat, coord.latitude)
            maxLat = max(maxLat, coord.latitude)
            minLon = min(minLon, coord.longitude)
            maxLon = max(maxLon, coord.longitude)
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.4 + 0.02,
            longitudeDelta: (maxLon - minLon) * 1.4 + 0.02
        )
        return MKCoordinateRegion(center: center, span: span)
    }
}

// MARK: - Station Dot Annotation

private struct StationDot: View {
    let code: String
    let isEndpoint: Bool
    let isPassed: Bool
    let isCurrent: Bool

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                if isEndpoint {
                    Circle()
                        .fill(dotColor)
                        .frame(width: 14, height: 14)
                    Circle()
                        .fill(Color.bgPrimary)
                        .frame(width: 8, height: 8)
                    Circle()
                        .fill(dotColor)
                        .frame(width: 5, height: 5)
                } else {
                    Circle()
                        .fill(dotColor)
                        .frame(width: 8, height: 8)
                }
            }

            Text(code)
                .font(.railMono(isEndpoint ? 10 : 8, weight: .semibold))
                .foregroundStyle(dotColor.opacity(isEndpoint ? 1 : 0.7))
        }
    }

    private var dotColor: Color {
        if isPassed { return .railGreen }
        if isCurrent { return .accent }
        return .white.opacity(0.4)
    }
}

// MARK: - Live Train Dot

private struct LiveTrainDot: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(Color.accent.opacity(0.15))
                .frame(width: 40, height: 40)
                .scaleEffect(pulse ? 1.3 : 1.0)

            // Mid ring
            Circle()
                .fill(Color.accent.opacity(0.3))
                .frame(width: 24, height: 24)

            // Inner dot
            Circle()
                .fill(Color.accent)
                .frame(width: 16, height: 16)
                .shadow(color: Color.accentGlowStrong, radius: 8)

            // Center
            Image(systemName: "tram.fill")
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.black)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}
