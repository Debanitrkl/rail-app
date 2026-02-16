import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var selectedTrainNumber: String? = "12952"
    @State private var selectedStationCode: String? = "NDLS"

    var body: some View {
        ZStack(alignment: .bottom) {
            // Screen content
            Group {
                switch selectedTab {
                case 0:
                    JourneysScreen(
                        selectedTrainNumber: $selectedTrainNumber,
                        selectedTab: $selectedTab
                    )
                case 1:
                    LiveTrackingScreen(
                        trainNumber: selectedTrainNumber ?? "12952"
                    )
                case 2:
                    JourneyDetailScreen(
                        trainNumber: selectedTrainNumber ?? "12952"
                    )
                case 3:
                    StationInfoScreen(
                        stationCode: Binding(
                            get: { selectedStationCode ?? "NDLS" },
                            set: { selectedStationCode = $0 }
                        )
                    )
                case 4:
                    SearchScreen(
                        selectedTrainNumber: $selectedTrainNumber,
                        selectedStationCode: $selectedStationCode,
                        selectedTab: $selectedTab
                    )
                default:
                    JourneysScreen(
                        selectedTrainNumber: $selectedTrainNumber,
                        selectedTab: $selectedTab
                    )
                }
            }

            // Tab Bar
            RailTabBar(selectedTab: $selectedTab)
        }
        .background(Color.bgPrimary)
        .preferredColorScheme(.dark)
    }
}

struct RailTabBar: View {
    @Binding var selectedTab: Int

    private let tabs: [(String, String, Int)] = [
        ("house.fill", "Home", 0),
        ("location.fill", "Track", 1),
        ("rectangle.portrait.fill", "Detail", 2),
        ("tram.fill", "Station", 3),
        ("magnifyingglass", "Search", 4),
    ]

    var body: some View {
        HStack {
            ForEach(tabs, id: \.2) { icon, label, index in
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: icon)
                            .font(.system(size: 22, weight: .regular))
                            .symbolRenderingMode(.monochrome)

                        Text(label)
                            .font(.railBody(10, weight: .medium))
                            .tracking(0.2)
                            .lineLimit(1)
                    }
                    .foregroundStyle(selectedTab == index ? Color.accent : Color.textTertiary)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 16)
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 34)
        .background {
            LinearGradient(
                colors: [Color.bgPrimary, Color.bgPrimary.opacity(0.95), .clear],
                startPoint: .bottom,
                endPoint: .top
            )
            .background(.ultraThinMaterial)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.border)
                .frame(height: 1)
        }
    }
}
