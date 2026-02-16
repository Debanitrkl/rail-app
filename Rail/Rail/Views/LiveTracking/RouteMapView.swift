import SwiftUI

struct RouteMapView: View {
    let route: [RouteStop]
    let currentStopIndex: Int
    let speed: Double
    let eta: String
    let destinationCode: String

    var body: some View {
        ZStack(alignment: .bottom) {
            // Map canvas
            Canvas { context, size in
                drawGrid(context: context, size: size)
                drawRoute(context: context, size: size)
                drawStations(context: context, size: size)
                drawTrainPosition(context: context, size: size)
            }
            .background(Color.mapBackground)
            .clipShape(RoundedRectangle(cornerRadius: RailSpacing.cardRadius))
            .overlay {
                RoundedRectangle(cornerRadius: RailSpacing.cardRadius)
                    .stroke(Color.border, lineWidth: 1)
            }

            // Overlay badges
            HStack(alignment: .bottom) {
                // Speed
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

                // ETA
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
        .frame(height: 260)
    }

    // MARK: - Canvas Drawing

    private func drawGrid(context: GraphicsContext, size: CGSize) {
        let gridSpacing: CGFloat = 40
        let gridColor = Color(hex: 0xE4A853).opacity(0.05)

        for x in stride(from: 0, to: size.width, by: gridSpacing) {
            var path = Path()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
            context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
        }
        for y in stride(from: 0, to: size.height, by: gridSpacing) {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
            context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
        }
    }

    private func stationPoints(size: CGSize) -> [CGPoint] {
        let count = max(route.count, 2)
        return (0..<count).map { i in
            let t = Double(i) / Double(count - 1)
            let x = 40 + (size.width - 80) * t
            let y = size.height * 0.78 - (size.height * 0.55) * t + sin(t * .pi) * 20
            return CGPoint(x: x, y: y)
        }
    }

    private func drawRoute(context: GraphicsContext, size: CGSize) {
        let points = stationPoints(size: size)
        guard points.count >= 2 else { return }

        // Background track
        var fullPath = Path()
        fullPath.move(to: points[0])
        for i in 1..<points.count {
            let prev = points[i - 1]
            let curr = points[i]
            let ctrl1 = CGPoint(x: (prev.x + curr.x) / 2, y: prev.y)
            let ctrl2 = CGPoint(x: (prev.x + curr.x) / 2, y: curr.y)
            fullPath.addCurve(to: curr, control1: ctrl1, control2: ctrl2)
        }
        context.stroke(fullPath, with: .color(.white.opacity(0.06)), lineWidth: 3)

        // Completed path
        let completedIdx = min(currentStopIndex, points.count - 1)
        if completedIdx > 0 {
            var completedPath = Path()
            completedPath.move(to: points[0])
            for i in 1...completedIdx {
                let prev = points[i - 1]
                let curr = points[i]
                let ctrl1 = CGPoint(x: (prev.x + curr.x) / 2, y: prev.y)
                let ctrl2 = CGPoint(x: (prev.x + curr.x) / 2, y: curr.y)
                completedPath.addCurve(to: curr, control1: ctrl1, control2: ctrl2)
            }
            let dashes: [CGFloat] = [6, 4]
            context.stroke(
                completedPath,
                with: .color(Color.accent.opacity(0.8)),
                style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: dashes)
            )
        }

        // Remaining path
        if completedIdx < points.count - 1 {
            var remainPath = Path()
            remainPath.move(to: points[completedIdx])
            for i in (completedIdx + 1)..<points.count {
                let prev = points[i - 1]
                let curr = points[i]
                let ctrl1 = CGPoint(x: (prev.x + curr.x) / 2, y: prev.y)
                let ctrl2 = CGPoint(x: (prev.x + curr.x) / 2, y: curr.y)
                remainPath.addCurve(to: curr, control1: ctrl1, control2: ctrl2)
            }
            let dashes: [CGFloat] = [4, 6]
            context.stroke(
                remainPath,
                with: .color(.white.opacity(0.15)),
                style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: dashes)
            )
        }
    }

    private func drawStations(context: GraphicsContext, size: CGSize) {
        let points = stationPoints(size: size)

        for (i, point) in points.enumerated() {
            guard i < route.count else { break }
            let stop = route[i]
            let isFirst = i == 0
            let isLast = i == route.count - 1
            let isCompleted = i < currentStopIndex
            let isCurrent = i == currentStopIndex

            // Station dot
            let dotSize: CGFloat = (isFirst || isLast) ? 10 : 6
            let dotColor: Color
            let dotOpacity: Double

            if isCompleted {
                dotColor = .accent
                dotOpacity = isFirst ? 0.8 : 0.5
            } else if isCurrent {
                dotColor = .accent
                dotOpacity = 1.0
            } else {
                dotColor = .white
                dotOpacity = isLast ? 0.3 : 0.2
            }

            let dotRect = CGRect(
                x: point.x - dotSize / 2,
                y: point.y - dotSize / 2,
                width: dotSize,
                height: dotSize
            )
            context.fill(
                Path(ellipseIn: dotRect),
                with: .color(dotColor.opacity(dotOpacity))
            )

            // Station label
            let labelY = point.y + (isLast ? -16 : 16)
            let labelColor: Color = isCompleted || isCurrent
                ? .white.opacity(isFirst ? 0.4 : 0.25)
                : .white.opacity(isLast ? 0.35 : 0.2)

            context.draw(
                Text(stop.station.code)
                    .font(.railMono(isFirst || isLast ? 9 : 8))
                    .foregroundStyle(labelColor),
                at: CGPoint(x: point.x, y: labelY)
            )
        }
    }

    private func drawTrainPosition(context: GraphicsContext, size: CGSize) {
        let points = stationPoints(size: size)
        guard currentStopIndex < points.count else { return }
        let trainPoint = points[currentStopIndex]

        // Glow circle
        let glowSize: CGFloat = 32
        let glowRect = CGRect(
            x: trainPoint.x - glowSize / 2,
            y: trainPoint.y - glowSize / 2,
            width: glowSize,
            height: glowSize
        )
        context.fill(
            Path(ellipseIn: glowRect),
            with: .color(Color.accent.opacity(0.15))
        )

        // Inner dot
        let innerSize: CGFloat = 14
        let innerRect = CGRect(
            x: trainPoint.x - innerSize / 2,
            y: trainPoint.y - innerSize / 2,
            width: innerSize,
            height: innerSize
        )
        context.fill(
            Path(ellipseIn: innerRect),
            with: .color(Color.accent)
        )

        // Center dot
        let centerSize: CGFloat = 6
        let centerRect = CGRect(
            x: trainPoint.x - centerSize / 2,
            y: trainPoint.y - centerSize / 2,
            width: centerSize,
            height: centerSize
        )
        context.fill(
            Path(ellipseIn: centerRect),
            with: .color(.black)
        )

        // Location label
        if currentStopIndex < route.count {
            let labelText = "Nr. \(route[currentStopIndex].station.name.uppercased())"
            let labelBgRect = CGRect(
                x: trainPoint.x + 12,
                y: trainPoint.y - 11,
                width: 90,
                height: 22
            )
            let labelPath = Path(roundedRect: labelBgRect, cornerRadius: 6)
            context.fill(labelPath, with: .color(.black.opacity(0.7)))
            context.draw(
                Text(labelText)
                    .font(.railMono(9, weight: .semibold))
                    .foregroundStyle(Color.accent),
                at: CGPoint(x: labelBgRect.midX, y: labelBgRect.midY)
            )
        }
    }
}
