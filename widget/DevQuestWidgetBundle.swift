import WidgetKit
import SwiftUI

/// 小组件 Bundle，注册所有桌面小组件
@main
struct DevQuestWidgetBundle: WidgetBundle {
    var body: some Widget { PowerWidget(); ServerStatusWidget() }
}
