import SwiftUI

struct RailCard<Content: View>: View {
    let content: Content
    var accentBorder: Bool = false
    var gradient: Bool = false

    init(accentBorder: Bool = false, gradient: Bool = false, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.accentBorder = accentBorder
        self.gradient = gradient
    }

    var body: some View {
        content
            .padding(RailSpacing.cardPadding)
            .background {
                if gradient {
                    AnyView(
                        LinearGradient(
                            colors: [
                                Color(hex: 0x1A1714),
                                Color.bgCard,
                                Color(hex: 0x151520)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                } else {
                    AnyView(Color.bgCard)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: RailSpacing.cardRadius))
            .overlay {
                RoundedRectangle(cornerRadius: RailSpacing.cardRadius)
                    .stroke(accentBorder ? Color.borderAccent : Color.border, lineWidth: 1)
            }
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [.clear, .white.opacity(0.06), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 1)
                .clipShape(RoundedRectangle(cornerRadius: RailSpacing.cardRadius))
            }
            .padding(.horizontal, RailSpacing.screenHorizontal)
    }
}
