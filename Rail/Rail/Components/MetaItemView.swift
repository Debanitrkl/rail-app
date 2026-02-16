import SwiftUI

struct MetaItemView: View {
    let label: String
    let value: String
    var valueColor: Color = .textPrimary

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.railBody(10, weight: .semibold))
                .tracking(0.6)
                .textCase(.uppercase)
                .foregroundStyle(Color.textTertiary)

            Text(value)
                .font(.railMono(14, weight: .medium))
                .foregroundStyle(valueColor)
        }
    }
}
