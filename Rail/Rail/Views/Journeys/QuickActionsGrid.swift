import SwiftUI

struct QuickActionsGrid: View {
    var onPNRTapped: () -> Void
    var onLiveTrainTapped: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                QuickActionCapsule(
                    icon: "magnifyingglass",
                    title: "Search Trains",
                    color: .accent,
                    action: onPNRTapped
                )

                QuickActionCapsule(
                    icon: "location.fill",
                    title: "Live Trains",
                    color: .railGreen,
                    action: onLiveTrainTapped
                )

                QuickActionCapsule(
                    icon: "doc.text.magnifyingglass",
                    title: "Check PNR",
                    color: .railBlue,
                    action: onPNRTapped
                )
            }
            .padding(.horizontal, RailSpacing.screenHorizontal)
        }
    }
}

private struct QuickActionCapsule: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(color)

                Text(title)
                    .font(.railBody(13, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(color.opacity(0.1))
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(color.opacity(0.2), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}
