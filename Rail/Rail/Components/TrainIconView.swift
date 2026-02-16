import SwiftUI

struct TrainIconView: View {
    var size: CGFloat = 28

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.accent)
                .frame(width: size, height: size)
                .shadow(color: Color.accentGlowStrong, radius: 10)
                .shadow(color: Color.accentGlow, radius: 20)

            Image(systemName: "tram.fill")
                .font(.system(size: size * 0.4))
                .foregroundStyle(.black)
        }
    }
}
