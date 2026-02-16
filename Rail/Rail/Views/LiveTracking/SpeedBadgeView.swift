import SwiftUI

struct SpeedBadgeView: View {
    let speed: Double

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text("\(Int(speed))")
                .font(.railMono(22, weight: .bold))
                .foregroundStyle(Color.accent)
            Text("km/h")
                .font(.railBody(11, weight: .medium))
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.black.opacity(0.7))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
