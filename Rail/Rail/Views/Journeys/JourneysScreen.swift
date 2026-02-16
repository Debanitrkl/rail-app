import SwiftUI

struct JourneysScreen: View {
    @State private var viewModel = JourneysViewModel()
    @Binding var selectedTrainNumber: String?
    @Binding var selectedTab: Int

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                PageHeader(title: "Rail", subtitle: viewModel.todayFormatted)

                if viewModel.isLoading {
                    LoadingView()
                        .frame(height: 300)
                } else if let error = viewModel.error {
                    ErrorView(message: error) {
                        Task { await viewModel.loadJourneys() }
                    }
                    .frame(height: 300)
                } else {
                    journeysContent
                }
            }
            .padding(.bottom, 80)
        }
        .background(Color.bgPrimary)
        .task {
            await viewModel.loadJourneys()
        }
        .onDisappear {
            viewModel.disconnect()
        }
    }

    @ViewBuilder
    private var journeysContent: some View {
        // 1. Active Journey (Hero)
        if let active = viewModel.activeJourney {
            SectionLabel(text: "Live Journey")

            ActiveJourneyCard(
                journey: active,
                livePosition: viewModel.livePosition
            ) {
                selectedTrainNumber = active.trainNumber
                selectedTab = 2
            }
            .fadeInUp(delay: 0.05)

            Spacer().frame(height: 20)
        }

        // 2. Quick Actions (Inline)
        QuickActionsGrid(
            onPNRTapped: { selectedTab = 4 },
            onLiveTrainTapped: { selectedTab = 1 }
        )
        .fadeInUp(delay: 0.1)

        Spacer().frame(height: 24)

        // 3. Upcoming Journeys
        if !viewModel.upcomingJourneys.isEmpty {
            SectionLabel(text: "Upcoming")

            ForEach(Array(viewModel.upcomingJourneys.enumerated()), id: \.element.id) { index, journey in
                UpcomingJourneyCard(journey: journey)
                    .fadeInUp(delay: 0.15 + Double(index) * 0.05)
            }

            Spacer().frame(height: 24)
        }

        // 4. Live Network Map
        if !viewModel.allLivePositions.isEmpty {
            SectionLabel(text: "Live Network")

            IndiaMapView(trains: viewModel.allLivePositions) { trainNumber in
                selectedTrainNumber = trainNumber
                selectedTab = 2
            }
            .padding(.horizontal, RailSpacing.screenHorizontal)
            .fadeInUp(delay: 0.2)
        }
    }
}
