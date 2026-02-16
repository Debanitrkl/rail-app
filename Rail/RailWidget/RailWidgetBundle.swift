import WidgetKit
import SwiftUI

@main
struct RailWidgetBundle: WidgetBundle {
    var body: some Widget {
        JourneyWidget()
        PNRWidget()
    }
}
