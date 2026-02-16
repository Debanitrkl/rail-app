import SwiftUI

struct RouteDisplayView: View {
    let fromCode: String
    let fromName: String
    let fromTime: String
    let toCode: String
    let toName: String
    let toTime: String
    var progress: Double = 0

    var body: some View {
        HStack(spacing: 0) {
            // Origin
            VStack(alignment: .leading, spacing: 4) {
                Text(fromCode)
                    .font(.railMono(28, weight: .semibold))
                    .tracking(-0.56)
                Text(fromName)
                    .font(.railBody(11))
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
                    .frame(maxWidth: 90, alignment: .leading)
                Text(fromTime)
                    .font(.railMono(14, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
                    .padding(.top, 2)
            }

            // Progress line
            GeometryReader { geo in
                let width = geo.size.width
                ZStack(alignment: .leading) {
                    // Background track
                    Rectangle()
                        .fill(Color.border)
                        .frame(height: 2)

                    // Progress
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.accent, .accentDim],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: width * progress, height: 2)

                    // Train icon
                    if progress > 0 && progress < 1 {
                        TrainIconView()
                            .offset(x: width * progress - 14)
                    }
                }
                .frame(height: 28)
                .frame(maxHeight: .infinity, alignment: .center)
            }
            .padding(.horizontal, 16)

            // Destination
            VStack(alignment: .trailing, spacing: 4) {
                Text(toCode)
                    .font(.railMono(28, weight: .semibold))
                    .tracking(-0.56)
                Text(toName)
                    .font(.railBody(11))
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
                    .frame(maxWidth: 90, alignment: .trailing)
                Text(toTime)
                    .font(.railMono(14, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
                    .padding(.top, 2)
            }
        }
    }
}
