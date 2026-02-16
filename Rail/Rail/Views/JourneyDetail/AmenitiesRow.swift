import SwiftUI

struct AmenitiesRow: View {
    let amenities: [(String, String)]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(amenities, id: \.1) { icon, label in
                    HStack(spacing: 6) {
                        Image(systemName: icon)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.accent)

                        Text(label)
                            .font(.railBody(12, weight: .medium))
                            .foregroundStyle(Color.textSecondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.bgCard)
                    .clipShape(RoundedRectangle(cornerRadius: RailSpacing.mediumRadius))
                    .overlay {
                        RoundedRectangle(cornerRadius: RailSpacing.mediumRadius)
                            .stroke(Color.border, lineWidth: 1)
                    }
                }
            }
            .padding(.horizontal, RailSpacing.screenHorizontal)
        }
        .padding(.bottom, 20)
    }
}
