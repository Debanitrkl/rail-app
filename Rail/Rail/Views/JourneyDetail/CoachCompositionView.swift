import SwiftUI

struct CoachCompositionView: View {
    let coaches: [Coach]
    let userCoachLabel: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Coach Composition")
                .font(.railBody(11, weight: .semibold))
                .tracking(0.66)
                .textCase(.uppercase)
                .foregroundStyle(Color.textTertiary)

            // Coach diagram - horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 3) {
                    ForEach(coaches) { coach in
                        CoachBlockView(
                            coach: coach,
                            isUserCoach: coach.coachLabel == userCoachLabel
                        )
                    }
                }
            }

            // Legend
            Divider()
                .background(Color.border)

            legendRow
        }
        .padding(RailSpacing.cardPadding)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: RailSpacing.cardRadius))
        .overlay {
            RoundedRectangle(cornerRadius: RailSpacing.cardRadius)
                .stroke(Color.border, lineWidth: 1)
        }
        .padding(.horizontal, RailSpacing.screenHorizontal)
        .padding(.bottom, 16)
    }

    private var legendRow: some View {
        let legendItems: [(Color, String)] = [
            (.coach1AC, "1AC"),
            (.coach2AC, "2AC"),
            (.coach3AC, "3AC"),
            (.coachSL, "SL"),
            (.coachPantry, "Pantry"),
        ]

        return HStack(spacing: 12) {
            ForEach(legendItems, id: \.1) { color, label in
                HStack(spacing: 5) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: 8, height: 8)
                    Text(label)
                        .font(.railBody(10))
                        .foregroundStyle(Color.textTertiary)
                }
            }
        }
        .padding(.top, 2)
    }
}

struct CoachBlockView: View {
    let coach: Coach
    let isUserCoach: Bool

    var body: some View {
        VStack(spacing: 1) {
            if isUserCoach {
                Text("YOU")
                    .font(.railMono(7, weight: .bold))
                    .foregroundStyle(Color.accent)
                    .tracking(0.7)
            }

            VStack(spacing: 1) {
                Text(coach.coachLabel)
                    .font(.railMono(10, weight: .bold))

                Text(coach.coachCategory.shortLabel)
                    .font(.railMono(7, weight: .medium))
                    .opacity(0.6)
            }
            .frame(minWidth: coach.coachCategory == .engine ? 30 : 38, minHeight: 42)
            .background(coach.coachCategory.backgroundColor)
            .foregroundStyle(coach.coachCategory.color)
            .clipShape(RoundedRectangle(cornerRadius: RailSpacing.coachRadius))
            .overlay {
                RoundedRectangle(cornerRadius: RailSpacing.coachRadius)
                    .stroke(
                        isUserCoach ? Color.accent : coach.coachCategory.borderColor,
                        lineWidth: isUserCoach ? 2 : 1
                    )
            }
            .shadow(color: isUserCoach ? Color.accentGlowStrong : .clear, radius: 6)
        }
    }
}
