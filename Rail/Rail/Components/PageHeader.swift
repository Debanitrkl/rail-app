import SwiftUI

struct PageHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.railDisplay(32))
                .tracking(-0.64)
                .lineSpacing(-0.1 * 32)

            if let subtitle {
                Text(subtitle)
                    .font(.railBody(14))
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, RailSpacing.pageHeaderHorizontal)
        .padding(.top, 16)
        .padding(.bottom, 20)
    }
}
