import SwiftUI

struct SectionLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .railSectionLabel()
            .padding(.horizontal, RailSpacing.sectionLabelHorizontal)
            .padding(.bottom, 12)
    }
}
