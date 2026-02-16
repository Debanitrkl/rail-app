import SwiftUI

struct DisplayText: View {
    let text: String
    var size: CGFloat = 28
    var color: Color = .textPrimary

    var body: some View {
        Text(text)
            .font(.railDisplay(size))
            .tracking(-0.02 * size)
            .foregroundStyle(color)
    }
}
