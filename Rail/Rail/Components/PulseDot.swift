import SwiftUI

struct PulseDot: View {
    let color: Color
    var size: CGFloat = 6

    @State private var opacity: Double = 1.0

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .opacity(opacity)
            .animation(
                .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                value: opacity
            )
            .onAppear { opacity = 0.4 }
    }
}
