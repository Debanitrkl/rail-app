import SwiftUI

struct ActiveJourneyCard: View {
    let journey: Journey
    let livePosition: LiveTrainPosition?
    var onTap: () -> Void

    private var progress: Double {
        guard let pos = livePosition else { return 0.62 }
        return min(max(pos.speedKmph > 0 ? 0.5 : 0.2, 0), 1.0)
    }

    private var isDelayed: Bool {
        livePosition?.isDelayed ?? false
    }

    private var statusText: String {
        guard let pos = livePosition else { return "On Time" }
        return pos.statusText
    }

    private var statusColor: Color {
        isDelayed ? .railRed : .railGreen
    }

    private var statusBgColor: Color {
        isDelayed ? .railRedDim : .railGreenDim
    }

    var body: some View {
        RailCard(accentBorder: true, gradient: true) {
            VStack(alignment: .leading, spacing: 0) {
                // Top: Train info + LIVE badge
                topSection
                    .padding(.bottom, 20)

                // Progress strip
                progressStrip
                    .padding(.bottom, 20)

                // Info grid row
                infoRow
            }
            .zIndex(1)
        }
        .overlay(alignment: .topTrailing) {
            // Accent glow
            RadialGradient(
                colors: [Color.accentGlow, .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 180
            )
            .clipShape(RoundedRectangle(cornerRadius: RailSpacing.cardRadius))
            .padding(.horizontal, RailSpacing.screenHorizontal)
            .allowsHitTesting(false)
        }
        .onTapGesture(perform: onTap)
    }

    // MARK: - Top Section

    private var topSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(journey.trainNumber)
                    .font(.railMono(11, weight: .semibold))
                    .foregroundStyle(Color.accent)
                    .tracking(0.8)

                Text(journey.trainName)
                    .font(.railDisplay(22))
                    .tracking(-0.3)
                    .lineLimit(1)
            }

            Spacer()

            // LIVE indicator + status
            VStack(alignment: .trailing, spacing: 6) {
                HStack(spacing: 5) {
                    PulseDot(color: .railGreen, size: 6)
                    Text("LIVE")
                        .font(.railMono(10, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(Color.railGreen)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.railGreenDim)
                .clipShape(RoundedRectangle(cornerRadius: 6))

                // Status badge
                Text(statusText)
                    .font(.railBody(11, weight: .semibold))
                    .tracking(0.2)
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(statusBgColor)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
    }

    // MARK: - Progress Strip

    private var progressStrip: some View {
        VStack(spacing: 0) {
            // Station codes + times
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(journey.boarding.code)
                        .font(.railMono(26, weight: .semibold))
                        .tracking(-0.5)
                    Text(journey.boarding.name)
                        .font(.railBody(11))
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)
                        .frame(maxWidth: 100, alignment: .leading)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(journey.destination.code)
                        .font(.railMono(26, weight: .semibold))
                        .tracking(-0.5)
                    Text(journey.destination.name)
                        .font(.railBody(11))
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)
                        .frame(maxWidth: 100, alignment: .trailing)
                }
            }

            // Progress line with train icon
            GeometryReader { geo in
                let width = geo.size.width
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(Color.border)
                        .frame(height: 3)

                    // Filled progress
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(
                            LinearGradient(
                                colors: [.accent, .accentDim],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: width * progress, height: 3)

                    // Origin dot
                    Circle()
                        .fill(Color.accent)
                        .frame(width: 8, height: 8)

                    // Destination dot
                    Circle()
                        .fill(progress >= 1 ? Color.accent : Color.bgElevated)
                        .frame(width: 8, height: 8)
                        .overlay {
                            Circle().stroke(Color.border, lineWidth: 1.5)
                        }
                        .offset(x: width - 8)

                    // Train icon at current position
                    if progress > 0 && progress < 1 {
                        TrainIconView(size: 26)
                            .offset(x: width * progress - 13)
                    }
                }
                .frame(height: 26)
            }
            .frame(height: 26)
            .padding(.top, 10)

            // Time labels
            HStack {
                Text(livePosition.map { _ in "16:55" } ?? "16:55")
                    .font(.railMono(13, weight: .medium))
                    .foregroundStyle(Color.textSecondary)

                Spacer()

                Text(livePosition?.etaNext ?? "08:35")
                    .font(.railMono(13, weight: .medium))
                    .foregroundStyle(statusColor)
            }
            .padding(.top, 6)
        }
    }

    // MARK: - Info Row

    private var infoRow: some View {
        HStack(spacing: 0) {
            infoCell(label: "PLATFORM", value: livePosition?.currentStation ?? "3", color: .accent)
            Spacer()
            infoCell(label: "COACH", value: journey.coach ?? "B4", color: .textPrimary)
            Spacer()
            infoCell(label: "BERTH", value: journey.berth ?? "32 LB", color: .textPrimary)
            Spacer()
            infoCell(label: "SPEED", value: "\(Int(livePosition?.speedKmph ?? 0))", color: .accent)
        }
        .padding(.top, 16)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.border)
                .frame(height: 1)
        }
    }

    private func infoCell(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.railBody(9, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(Color.textTertiary)
            Text(value)
                .font(.railMono(14, weight: .semibold))
                .foregroundStyle(color)
        }
    }
}
