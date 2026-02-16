import SwiftUI

struct StationInfoScreen: View {
    @Binding var stationCode: String
    @State private var viewModel = StationViewModel()
    @State private var currentCode: String = ""

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                PageHeader(title: "Station")

                // Station Search
                stationSearch
                    .padding(.horizontal, RailSpacing.screenHorizontal)
                    .padding(.bottom, 16)

                if viewModel.isLoading {
                    LoadingView()
                        .frame(height: 400)
                } else if let error = viewModel.error {
                    ErrorView(message: error) {
                        Task { await viewModel.loadStation(currentCode) }
                    }
                    .frame(height: 400)
                } else if let station = viewModel.station {
                    stationContent(station: station)
                }
            }
            .padding(.bottom, 80)
        }
        .background(Color.bgPrimary)
        .task {
            currentCode = stationCode
            await viewModel.loadStation(currentCode)
        }
        .onChange(of: stationCode) {
            currentCode = stationCode
            Task { await viewModel.loadStation(currentCode) }
        }
        .onDisappear {
            viewModel.disconnect()
        }
    }

    @ViewBuilder
    private var stationSearch: some View {
        VStack(spacing: 8) {
            SearchInputView(query: $viewModel.searchQuery, placeholder: "Search stations by name or code...") {
                viewModel.searchStations(viewModel.searchQuery)
            }

            if !viewModel.searchResults.isEmpty {
                VStack(spacing: 4) {
                    ForEach(viewModel.searchResults) { result in
                        Button {
                            currentCode = result.code
                            stationCode = result.code
                            viewModel.searchQuery = ""
                            viewModel.searchResults = []
                            Task { await viewModel.loadStation(result.code) }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "building.2.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.textTertiary)

                                VStack(alignment: .leading, spacing: 1) {
                                    Text("\(result.name) (\(result.code))")
                                        .font(.railBody(14, weight: .medium))
                                        .foregroundStyle(Color.textPrimary)

                                    Text("\(result.zone) \u{2022} \(result.state)")
                                        .font(.railBody(11))
                                        .foregroundStyle(Color.textTertiary)
                                }

                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(Color.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.border, lineWidth: 1)
                }
            }
        }
    }

    @ViewBuilder
    private func stationContent(station: Station) -> some View {
        // Station Hero
        StationHeroView(station: station)
            .fadeInUp(delay: 0.05)

        // Platforms
        SectionLabel(text: "Platforms")

        PlatformGridView(
            platforms: viewModel.platforms,
            totalPlatforms: station.platformsCount
        )
        .fadeInUp(delay: 0.1)

        // Departures
        SectionLabel(text: "Departures")

        DeparturesListView(departures: viewModel.departures)
            .fadeInUp(delay: 0.15)
    }
}
