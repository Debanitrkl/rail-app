import SwiftUI

struct ETABadgeView: View {
    let destinationCode: String
    let eta: String

    var body: some View {
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
}
