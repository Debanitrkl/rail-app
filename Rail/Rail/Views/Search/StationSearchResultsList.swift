import SwiftUI

struct StationSearchResultsList: View {
    let results: [StationSearchResult]
    let onSelect: (StationSearchResult) -> Void

    var body: some View {
        VStack(spacing: 8) {
            ForEach(results) { station in
                Button {
                    onSelect(station)
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: RailSpacing.smallRadius)
                                .fill(Color.bgElevated)
                                .frame(width: 32, height: 32)

                            Image(systemName: "building.2.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.textSecondary)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(station.name) (\(station.code))")
                                .font(.railBody(14, weight: .medium))
                                .foregroundStyle(Color.textPrimary)

                            Text("\(station.zone) • \(station.state)")
                                .font(.railBody(12))
                                .foregroundStyle(Color.textTertiary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.textTertiary)
                    }
                    .padding(14)
                    .background(Color.bgCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.border, lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, RailSpacing.screenHorizontal)
    }
}
