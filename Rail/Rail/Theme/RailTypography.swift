import SwiftUI

extension Font {
    // Display — System Serif (New York)
    static func railDisplay(_ size: CGFloat) -> Font {
        .system(size: size, design: .serif)
    }

    // Body — System Default (SF Pro)
    static func railBody(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    // Mono — System Monospaced (SF Mono)
    static func railMono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

extension View {
    func railDisplayStyle(size: CGFloat = 32) -> some View {
        self.font(.railDisplay(size))
            .tracking(-0.02 * size)
    }

    func railMonoStyle(size: CGFloat = 14, weight: Font.Weight = .medium) -> some View {
        self.font(.railMono(size, weight: weight))
    }

    func railSectionLabel() -> some View {
        self.font(.railBody(11, weight: .semibold))
            .tracking(0.88)
            .textCase(.uppercase)
            .foregroundStyle(Color.textTertiary)
    }
}
