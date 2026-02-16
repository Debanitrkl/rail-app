import SwiftUI

struct StationTimelineView: View {
    let route: [RouteStop]
    let currentStopIndex: Int
    let livePosition: LiveTrainPosition?

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(route.enumerated()), id: \.element.id) { index, stop in
                let status = stopStatus(index: index)
                let isLast = index == route.count - 1

                TimelineItemView(
                    stop: stop,
                    status: status,
                    isLast: isLast,
                    livePosition: status == .current ? livePosition : nil
                )
            }
        }
        .padding(.horizontal, RailSpacing.sectionLabelHorizontal)
    }

    private func stopStatus(index: Int) -> StopStatus {
        if index < currentStopIndex { return .completed }
        if index == currentStopIndex { return .current }
        return .upcoming
    }
}

struct TimelineItemView: View {
    let stop: RouteStop
    let status: StopStatus
    let isLast: Bool
    let livePosition: LiveTrainPosition?

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline track
            VStack(spacing: 0) {
                // Dot
                ZStack {
                    switch status {
                    case .completed:
                        Circle()
                            .fill(Color.accent)
                            .frame(width: 12, height: 12)

                    case .current:
                        Circle()
                            .stroke(Color.accent, lineWidth: 2)
                            .frame(width: 12, height: 12)
                            .shadow(color: Color.accentGlowStrong, radius: 4)

                    case .upcoming:
                        Circle()
                            .stroke(Color.border, lineWidth: 2)
                            .fill(Color.bgPrimary)
                            .frame(width: 12, height: 12)
                    }
                }
                .padding(.top, 4)

                // Connecting line
                if !isLast {
                    Rectangle()
                        .fill(lineGradient)
                        .frame(width: 2)
                        .padding(.top, 4)
                }
            }
            .frame(width: 20)

            // Content
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(stop.station.name)
                            .font(.railBody(15, weight: .semibold))
                            .tracking(-0.15)
                            .foregroundStyle(status == .current ? Color.accent : .textPrimary)

                        Text(stop.station.code)
                            .font(.railMono(11))
                            .foregroundStyle(Color.textTertiary)
                    }

                    Spacer()

                    // Times
                    VStack(alignment: .trailing, spacing: 2) {
                        if status == .completed, let depTime = stop.departureTime {
                            Text(depTime)
                                .font(.railMono(14, weight: .semibold))
                                .foregroundStyle(Color.railGreen)

                            Text(haltText)
                                .font(.railMono(14, weight: .medium))
                                .foregroundStyle(Color.textSecondary)
                        } else {
                            Text(haltText)
                                .font(.railMono(14, weight: .medium))
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                }

                // Detail row
                if status == .completed || status == .current {
                    HStack(spacing: 16) {
                        if let platform = stop.platform {
                            Text("PF \(platform)")
                                .font(.railMono(11, weight: .bold))
                                .foregroundStyle(Color.accent)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.accentGlow)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }

                        if status == .completed {
                            Text("Departed on time")
                                .font(.railBody(12))
                                .foregroundStyle(Color.textTertiary)
                        } else if status == .current {
                            if livePosition != nil {
                                Text("Next stop")
                                    .font(.railBody(12))
                                    .foregroundStyle(Color.textTertiary)
                            }
                        }
                    }
                    .padding(.top, 8)
                }

                if isLast && status == .upcoming {
                    Text("Final destination")
                        .font(.railBody(12))
                        .foregroundStyle(Color.textTertiary)
                        .padding(.top, 8)
                }
            }
            .padding(.bottom, isLast ? 8 : 28)
        }
    }

    private var lineGradient: AnyShapeStyle {
        switch status {
        case .completed:
            AnyShapeStyle(
                LinearGradient(
                    colors: [.accent, .accentDim],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        case .current:
            AnyShapeStyle(
                LinearGradient(
                    colors: [.accentDim, Color.border],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        case .upcoming:
            AnyShapeStyle(Color.border)
        }
    }

    private var haltText: String {
        if stop.stopNumber == 1, let dep = stop.departureTime {
            return "Dep \(dep)"
        }
        if isLast, let arr = stop.arrivalTime {
            return "Arr \(arr)"
        }
        let halt = stop.haltMinutes > 0 ? " • \(stop.haltMinutes)m halt" : ""
        return "\(stop.arrivalTime ?? stop.departureTime ?? "")\(halt)"
    }
}
