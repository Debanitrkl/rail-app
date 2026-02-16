import SwiftUI

extension View {
    func fadeInUp(active: Bool = true, delay: Double = 0) -> some View {
        modifier(FadeInUpModifier(isActive: active, delay: delay))
    }

    func pulse() -> some View {
        modifier(PulseModifier())
    }

    func breathing() -> some View {
        modifier(BreathingModifier())
    }
}
