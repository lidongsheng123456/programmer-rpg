import WidgetKit
import SwiftUI

struct PowerWidgetEntry: TimelineEntry { let date: Date; let powerStats: PowerStats; let level: CharacterLevel }

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

struct PowerWidgetView: View {
    let entry: PowerWidgetEntry; @Environment(\.widgetFamily) var family
    var body: some View {
        VStack(spacing: 6) {
            Text("\(Int(entry.powerStats.totalPower))").font(.system(size: 36, weight: .bold, design: .rounded)).foregroundStyle(Color(hex: 0x7C3AED))
            Text("POWER").font(.system(size: 10, weight: .medium)).foregroundStyle(.secondary).tracking(2)
            Text(entry.level.rawValue).font(.system(size: 11, weight: .semibold)).foregroundStyle(Color(hex: 0xFBBF24))
        }.frame(maxWidth: .infinity, maxHeight: .infinity).containerBackground(for: .widget) { Color(hex: 0x0F0F23) }
    }
}

struct PowerWidget: Widget {
    let kind = "PowerWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PowerWidgetProvider()) { PowerWidgetView(entry: $0) }
            .configurationDisplayName("鐮佸姏鍊?).description("瀹炴椂鏄剧ず鍏淮鎴樺姏鍊?).supportedFamilies([.systemSmall, .systemMedium])
    }
}