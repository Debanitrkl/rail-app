import SwiftUI

extension Animation {
    static let railSpring = Animation.spring(response: 0.5, dampingFraction: 0.8)
    static let railFadeIn = Animation.easeOut(duration: 0.5)
}

struct FadeInUpModifier: ViewModifier {
    let isActive: Bool
    let delay: Double

    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 16)
            .animation(.railFadeIn.delay(delay), value: appeared)
            .onAppear {
                if isActive {
                    appeared = true
                }
            }
    }
}

struct PulseModifier: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .opacity(isPulsing ? 0.4 : 1.0)
            .animation(
                .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}

struct BreathingModifier: ViewModifier {
    @State private var scale: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .animation(
                .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                value: scale
            )
            .onAppear { scale = 1.4 }
    }
}
