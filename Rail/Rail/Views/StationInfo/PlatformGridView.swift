import SwiftUI

struct PlatformGridView: View {
    let platforms: [PlatformStatus]
    let totalPlatforms: Int

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8)
        ], spacing: 8) {
            ForEach(1...max(totalPlatforms, 1), id: \.self) { num in
                let platform = platforms.first { $0.platformNumber == num }
                PlatformCell(
                    number: num,
                    platform: platform
                )
            }
        }
        .padding(.horizontal, RailSpacing.screenHorizontal)
        .padding(.bottom, 20)
    }
}

struct PlatformCell: View {
    let number: Int
    let platform: PlatformStatus?

    private var isOccupied: Bool {
        platform?.isOccupied ?? false
    }

    var body: some View {
        VStack(spacing: 2) {
            Text("\(number)")
                .font(.railMono(22, weight: .bold))
                .foregroundStyle(isOccupied ? Color.accent : .textPrimary)

            Text("Platform")
                .font(.railBody(9, weight: .semibold))
                .tracking(0.45)
                .textCase(.uppercase)
                .foregroundStyle(Color.textTertiary)

            if let trainNum = platform?.currentTrain, isOccupied {
                Text(trainNum)
                    .font(.railMono(8, weight: .semibold))
                    .foregroundStyle(Color.accent)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentGlow)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background {
            if isOccupied {
                LinearGradient(
                    colors: [Color(hex: 0xE4A853).opacity(0.08), Color.bgCard],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                Color.bgCard
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(isOccupied ? Color.accentDim : Color.border, lineWidth: 1)
        }
    }
}
