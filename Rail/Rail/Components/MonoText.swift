import SwiftUI

struct MonoText: View {
    let text: String
    var size: CGFloat = 14
    var weight: Font.Weight = .medium
    var color: Color = .textPrimary

    var body: some View {
        Text(text)
            .font(.railMono(size, weight: weight))
            .foregroundStyle(color)
    }
}
