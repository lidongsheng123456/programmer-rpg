import WidgetKit
import SwiftUI

@main
struct DevQuestWidgetBundle: WidgetBundle {
    var body: some Widget {
        PowerWidget()
        ServerStatusWidget()
    }
}
