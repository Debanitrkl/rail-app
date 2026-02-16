import SwiftUI

struct RecentSearchesList: View {
    let searches: [RecentSearch]
    let onSelect: (RecentSearch) -> Void

    var body: some View {
        VStack(spacing: 8) {
            ForEach(searches.prefix(5)) { search in
                Button {
                    onSelect(search)
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: RailSpacing.smallRadius)
                                .fill(Color.bgElevated)
                                .frame(width: 32, height: 32)

                            Image(systemName: iconFor(search.type))
                                .font(.system(size: 14))
                                .foregroundStyle(Color.textSecondary)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(search.displayTitle)
                                .font(.railBody(14, weight: .medium))
                                .foregroundStyle(Color.textPrimary)

                            Text(search.displaySubtitle)
                                .font(.railBody(12))
                                .foregroundStyle(Color.textTertiary)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
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

    private func iconFor(_ type: RecentSearch.SearchType) -> String {
        switch type {
        case .train: return "tram.fill"
        case .station: return "location.fill"
        case .pnr: return "magnifyingglass"
        }
    }
}
