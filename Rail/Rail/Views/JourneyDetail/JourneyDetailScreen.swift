import SwiftUI

struct JourneyDetailScreen: View {
    let trainNumber: String
    var journeyId: String?
    @State private var viewModel = JourneyDetailViewModel()

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                if viewModel.isLoading {
                    LoadingView()
                        .frame(height: 500)
                } else if let error = viewModel.error {
                    ErrorView(message: error) {
                        Task { await viewModel.loadDetail(trainNumber: trainNumber, journeyId: journeyId) }
                    }
                    .frame(height: 500)
                } else if let train = viewModel.train {
                    detailContent(train: train)
                }
            }
            .padding(.bottom, 80)
        }
        .background(Color.bgPrimary)
        .task {
            await viewModel.loadDetail(trainNumber: trainNumber, journeyId: journeyId)
        }
    }

    @ViewBuilder
    private func detailContent(train: Train) -> some View {
        // Hero
        DetailHeroView(train: train, journey: viewModel.journey)
            .fadeInUp(delay: 0.05)

        // Coach Composition
        CoachCompositionView(
            coaches: viewModel.coaches,
            userCoachLabel: viewModel.userCoachLabel
        )
        .fadeInUp(delay: 0.1)

        // Booking Details
        if let journey = viewModel.journey {
            BookingDetailsCard(journey: journey)
                .fadeInUp(delay: 0.15)
        }

        // Amenities
        if !viewModel.amenitiesList.isEmpty {
            SectionLabel(text: "Amenities")
                .padding(.top, 8)

            AmenitiesRow(amenities: viewModel.amenitiesList)
                .fadeInUp(delay: 0.2)
        }
    }
}
