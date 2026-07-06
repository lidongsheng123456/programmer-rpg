import WidgetKit
import SwiftUI

/// 战力小组件数据条目
struct PowerWidgetEntry: TimelineEntry { let date: Date; let powerStats: PowerStats; let level: CharacterLevel }

/// 战力小组件数据提供者
struct PowerWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> PowerWidgetEntry { PowerWidgetEntry(date: .now, powerStats: .zero, level: .bronze) }
    func getSnapshot(in context: Context, completion: @escaping (PowerWidgetEntry) -> Void) { completion(load()) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<PowerWidgetEntry>) -> Void) {
        let next = Calendar.current.date(byAdding: .minute, value: AppConfig.widgetRefreshMinutes, to: Date()) ?? Date()
        completion(Timeline(entries: [load()], policy: .after(next)))
    }
    private func load() -> PowerWidgetEntry {
        let p = UserDefaultsPersistence(); let s: PowerStats? = try? p.load(forKey: AppConfig.StorageKey.cachedPowerStats)
        let pw = s ?? .zero; return PowerWidgetEntry(date: .now, powerStats: pw, level: pw.level)
    }
}

/// 战力小组件视图
struct PowerWidgetView: View {
    let entry: PowerWidgetEntry; @Environment(\.widgetFamily) var family
    var body: some View {
        VStack(spacing: 6) {
            Text("\(Int(entry.powerStats.totalPower))").font(.system(size: 36, weight: .bold, design: .rounded)).foregroundStyle(Color(hex: 0x7C3AED))
            Text("\u6218\u529b\u503c").font(.system(size: 10, weight: .medium)).foregroundStyle(.secondary).tracking(2)
            Text(entry.level.rawValue).font(.system(size: 11, weight: .semibold)).foregroundStyle(Color(hex: 0xFBBF24))
        }.frame(maxWidth: .infinity, maxHeight: .infinity).containerBackground(for: .widget) { Color(hex: 0x0F0F23) }
    }
}

/// \u6218\u529b\u5c0f\u7ec4\u4ef6\u914d\u7f6e
struct PowerWidget: Widget {
    let kind = "PowerWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PowerWidgetProvider()) { PowerWidgetView(entry: $0) }
            .configurationDisplayName("\u7801\u529b\u503c\u6218\u529b").description("\u5b9e\u65f6\u516d\u7ef4\u6218\u529b\u7edf\u8ba1").supportedFamilies([.systemSmall, .systemMedium])
    }
}
