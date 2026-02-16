import Foundation
import SwiftUI

struct Coach: Codable, Identifiable, Hashable {
    var id: String { "\(position)-\(coachLabel)" }

    let position: Int
    let coachLabel: String
    let coachType: String
    let totalBerths: Int

    var coachCategory: CoachCategory {
        CoachCategory.from(coachType)
    }
}

enum CoachCategory: String, CaseIterable {
    case engine
    case firstAC
    case secondAC
    case thirdAC
    case sleeper
    case general
    case pantry

    static func from(_ type: String) -> CoachCategory {
        switch type.uppercased() {
        case "1AC", "1A": return .firstAC
        case "2AC", "2A": return .secondAC
        case "3AC", "3A", "3E": return .thirdAC
        case "SL": return .sleeper
        case "GEN", "GS", "UR": return .general
        case "PC", "PTY", "PANTRY": return .pantry
        case "ENG", "LOCO", "EOG": return .engine
        default: return .general
        }
    }

    var color: Color {
        switch self {
        case .engine: return .coachEngine
        case .firstAC: return .coach1AC
        case .secondAC: return .coach2AC
        case .thirdAC: return .coach3AC
        case .sleeper: return .coachSL
        case .general: return .coachGEN
        case .pantry: return .coachPantry
        }
    }

    var backgroundColor: Color {
        switch self {
        case .engine: return .coachEngineBg
        case .firstAC: return .coach1ACBg
        case .secondAC: return .coach2ACBg
        case .thirdAC: return .coach3ACBg
        case .sleeper: return .coachSLBg
        case .general: return .coachGENBg
        case .pantry: return .coachPantryBg
        }
    }

    var borderColor: Color {
        switch self {
        case .engine: return .coachEngineBorder
        case .firstAC: return .coach1ACBorder
        case .secondAC: return .coach2ACBorder
        case .thirdAC: return .coach3ACBorder
        case .sleeper: return .coachSLBorder
        case .general: return .coachGENBorder
        case .pantry: return .coachPantryBorder
        }
    }

    var shortLabel: String {
        switch self {
        case .engine: return "ENG"
        case .firstAC: return "1AC"
        case .secondAC: return "2AC"
        case .thirdAC: return "3AC"
        case .sleeper: return "SL"
        case .general: return "GEN"
        case .pantry: return "Pantry"
        }
    }
}
