import SwiftUI

struct BadgeView: View {
    let text: String
    let style: BadgeStyle
    var showDot: Bool = true

    enum BadgeStyle {
        case onTime
        case delayed
        case arriving
        case scheduled
        case confirmed
        case waitlist
        case rac

        var backgroundColor: Color {
            switch self {
            case .onTime, .confirmed: return .railGreenDim
            case .delayed, .waitlist: return .railRedDim
            case .arriving: return .railBlueDim
            case .scheduled, .rac: return .accentGlow
            }
        }

        var textColor: Color {
            switch self {
            case .onTime, .confirmed: return .railGreen
            case .delayed, .waitlist: return .railRed
            case .arriving: return .railBlue
            case .scheduled, .rac: return .accent
            }
        }
    }

    var body: some View {
        HStack(spacing: 5) {
            if showDot {
                PulseDot(color: style.textColor)
            }
            Text(text)
                .font(.railBody(11, weight: .semibold))
                .tracking(0.22)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(style.backgroundColor)
        .foregroundStyle(style.textColor)
        .clipShape(RoundedRectangle(cornerRadius: RailSpacing.badgeRadius))
    }
}
