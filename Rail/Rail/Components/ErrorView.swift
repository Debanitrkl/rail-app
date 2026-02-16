import SwiftUI

struct ErrorView: View {
    let message: String
    var retryAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(Color.railRed)

            Text(message)
                .font(.railBody(14))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let retryAction {
                Button(action: retryAction) {
                    Text("Retry")
                        .font(.railBody(14, weight: .semibold))
                        .foregroundStyle(Color.accent)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.accentGlow)
                        .clipShape(RoundedRectangle(cornerRadius: RailSpacing.smallRadius))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
