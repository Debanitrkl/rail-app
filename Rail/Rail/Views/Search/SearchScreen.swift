import SwiftUI

struct SearchScreen: View {
    @State private var viewModel = SearchViewModel()
    @Binding var selectedTrainNumber: String?
    @Binding var selectedStationCode: String?
    @Binding var selectedTab: Int

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                PageHeader(title: "Search", subtitle: "Trains, stations, PNR")

                // Search box
                SearchInputView(query: $viewModel.searchQuery) {
                    viewModel.search()
                }
                .padding(.horizontal, RailSpacing.screenHorizontal)
                .padding(.bottom, 20)

                if viewModel.isSearching {
                    LoadingView(message: "Searching...")
                        .frame(height: 200)
                } else if let pnr = viewModel.pnrStatus {
                    SectionLabel(text: "PNR Status")
                    PNRStatusCard(pnr: pnr)
                        .fadeInUp(delay: 0.05)
                } else if !viewModel.trainResults.isEmpty || !viewModel.stationResults.isEmpty {
                    searchResults
                } else {
                    // Recent Searches
                    if !viewModel.recentSearches.isEmpty {
                        SectionLabel(text: "Recent")
                        RecentSearchesList(
                            searches: viewModel.recentSearches,
                            onSelect: handleRecentSearch
                        )
                    }
                }
            }
            .padding(.bottom, 80)
        }
        .background(Color.bgPrimary)
        .onAppear {
            viewModel.loadInitial()
        }
    }

    @ViewBuilder
    private var searchResults: some View {
        if !viewModel.trainResults.isEmpty {
            SectionLabel(text: "Trains")
            TrainSearchResultsList(
                results: viewModel.trainResults,
                onSelect: { train in
                    viewModel.selectTrain(train)
                    selectedTrainNumber = train.number
                    selectedTab = 1
                }
            )
        }

        if !viewModel.stationResults.isEmpty {
            SectionLabel(text: "Stations")
                .padding(.top, 8)
            StationSearchResultsList(
                results: viewModel.stationResults,
                onSelect: { station in
                    viewModel.selectStation(station)
                    selectedStationCode = station.code
                    selectedTab = 3
                }
            )
        }
    }

    private func handleRecentSearch(_ search: RecentSearch) {
        viewModel.searchQuery = search.query
        viewModel.search()
    }
}
