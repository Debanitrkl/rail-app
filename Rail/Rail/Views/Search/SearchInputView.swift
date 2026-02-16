import SwiftUI

struct SearchInputView: View {
    @Binding var query: String
    var placeholder: String = "Train number, name, or PNR..."
    var onSubmit: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18))
                .foregroundStyle(Color.textTertiary)

            TextField(placeholder, text: $query)
                .font(.railBody(16))
                .foregroundStyle(Color.textPrimary)
                .tint(Color.accent)
                .focused($isFocused)
                .onSubmit(onSubmit)
                .submitLabel(.search)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: RailSpacing.largeRadius))
        .overlay {
            RoundedRectangle(cornerRadius: RailSpacing.largeRadius)
                .stroke(
                    isFocused ? Color.accentDim : Color.border,
                    lineWidth: 1
                )
        }
        .shadow(color: isFocused ? Color.accentGlow : .clear, radius: 8)
        .onChange(of: query) {
            if query.count >= 3 {
                onSubmit()
            }
        }
    }
}
