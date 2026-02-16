import SwiftUI

extension Color {
    // Core Palette
    static let bgPrimary = Color(hex: 0x08080A)
    static let bgSecondary = Color(hex: 0x111114)
    static let bgCard = Color(hex: 0x18181C)
    static let bgCardHover = Color(hex: 0x1E1E24)
    static let bgElevated = Color(hex: 0x222228)

    // Accent — Heritage Brass
    static let accent = Color(hex: 0xE4A853)
    static let accentDim = Color(hex: 0xB8862F)
    static let accentGlow = Color(hex: 0xE4A853).opacity(0.15)
    static let accentGlowStrong = Color(hex: 0xE4A853).opacity(0.3)

    // Status Colors
    static let railGreen = Color(hex: 0x34D399)
    static let railGreenDim = Color(hex: 0x34D399).opacity(0.15)
    static let railRed = Color(hex: 0xF87171)
    static let railRedDim = Color(hex: 0xF87171).opacity(0.15)
    static let railYellow = Color(hex: 0xFBBF24)
    static let railYellowDim = Color(hex: 0xFBBF24).opacity(0.15)
    static let railBlue = Color(hex: 0x60A5FA)
    static let railBlueDim = Color(hex: 0x60A5FA).opacity(0.15)

    // Coach Colors
    static let coach1AC = Color(hex: 0xA78BFA)
    static let coach1ACBg = Color(hex: 0x8B5CF6).opacity(0.1)
    static let coach1ACBorder = Color(hex: 0x8B5CF6).opacity(0.3)
    static let coach2AC = Color(hex: 0x60A5FA)
    static let coach2ACBg = Color(hex: 0x3B82F6).opacity(0.1)
    static let coach2ACBorder = Color(hex: 0x3B82F6).opacity(0.3)
    static let coach3AC = Color(hex: 0x34D399)
    static let coach3ACBg = Color(hex: 0x34D399).opacity(0.1)
    static let coach3ACBorder = Color(hex: 0x34D399).opacity(0.3)
    static let coachSL = Color(hex: 0xFBBF24)
    static let coachSLBg = Color(hex: 0xFBBF24).opacity(0.1)
    static let coachSLBorder = Color(hex: 0xFBBF24).opacity(0.3)
    static let coachGEN = Color.white.opacity(0.55)
    static let coachGENBg = Color.white.opacity(0.05)
    static let coachGENBorder = Color.white.opacity(0.1)
    static let coachPantry = Color(hex: 0xF87171)
    static let coachPantryBg = Color(hex: 0xF87171).opacity(0.1)
    static let coachPantryBorder = Color(hex: 0xF87171).opacity(0.3)
    static let coachEngine = Color(hex: 0xE4A853)
    static let coachEngineBg = Color(hex: 0xE4A853).opacity(0.1)
    static let coachEngineBorder = Color(hex: 0xB8862F)

    // Typography
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.55)
    static let textTertiary = Color.white.opacity(0.3)
    static let textAccent = Color(hex: 0xE4A853)

    // Borders
    static let border = Color.white.opacity(0.06)
    static let borderAccent = Color(hex: 0xE4A853).opacity(0.2)

    // Map
    static let mapBackground = Color(hex: 0x0C1220)
}
