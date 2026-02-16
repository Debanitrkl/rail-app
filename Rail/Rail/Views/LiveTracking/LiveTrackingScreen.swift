import SwiftUI

struct LiveTrackingScreen: View {
    let trainNumber: String
    @State private var viewModel = LiveTrackingViewModel()

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                PageHeader(
                    title: "Live Tracking",
                    subtitle: viewModel.train.map { "\(trainNumber) \($0.name)" }
                )

                if viewModel.isLoading {
                    LoadingView()
                        .frame(height: 400)
                } else if let error = viewModel.error {
                    ErrorView(message: error) {
                        Task { await viewModel.loadTrain(trainNumber) }
                    }
                    .frame(height: 400)
                } else {
                    trackingContent
                }
            }
            .padding(.bottom, 80)
        }
        .background(Color.bgPrimary)
        .task {
            await viewModel.loadTrain(trainNumber)
        }
        .onDisappear {
            viewModel.disconnect()
        }
    }

    @ViewBuilder
    private var trackingContent: some View {
        // Route Map
        if !viewModel.geoRoute.isEmpty {
            TrainRouteMapView(
                geoRoute: viewModel.geoRoute,
                currentStopIndex: viewModel.currentStopIndex ?? 0,
                trainCoordinate: viewModel.trainCoordinate,
                speed: viewModel.livePosition?.speedKmph ?? 0,
                eta: viewModel.livePosition?.etaNext ?? "--:--",
                destinationCode: viewModel.route.last?.station.code ?? "---"
            )
            .padding(.horizontal, RailSpacing.screenHorizontal)
            .padding(.bottom, 16)
        } else {
            RouteMapView(
                route: viewModel.route,
                currentStopIndex: viewModel.currentStopIndex ?? 3,
                speed: viewModel.livePosition?.speedKmph ?? 112,
                eta: viewModel.livePosition?.etaNext ?? "08:35 AM",
                destinationCode: viewModel.route.last?.station.code ?? "BCT"
            )
            .padding(.horizontal, RailSpacing.screenHorizontal)
            .padding(.bottom, 16)
        }

        SectionLabel(text: "Station Timeline")
            .padding(.top, 8)

        // Station Timeline
        StationTimelineView(
            route: viewModel.route,
            currentStopIndex: viewModel.currentStopIndex ?? 3,
            livePosition: viewModel.livePosition
        )
    }
}
