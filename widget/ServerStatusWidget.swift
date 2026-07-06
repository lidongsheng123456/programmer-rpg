import WidgetKit
import SwiftUI

/// \u670d\u52a1\u5668\u72b6\u6001\u5c0f\u7ec4\u4ef6\u6570\u636e\u6761\u76ee
struct ServerStatusEntry: TimelineEntry {
    let date: Date; let servers: [ServerWidgetData]
    struct ServerWidgetData { let name: String; let emoji: String; let isOnline: Bool; let responseTimeMs: Int }
}

/// \u670d\u52a1\u5668\u72b6\u6001\u6570\u636e\u63d0\u4f9b\u8005
struct ServerStatusProvider: TimelineProvider {
    func placeholder(in context: Context) -> ServerStatusEntry { ServerStatusEntry(date: .now, servers: [.init(name: "\u4e3b\u670d\u52a1\u5668", emoji: "\u{1F43B}", isOnline: true, responseTimeMs: 42)]) }
    func getSnapshot(in context: Context, completion: @escaping (ServerStatusEntry) -> Void) { completion(placeholder(in: context)) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<ServerStatusEntry>) -> Void) {
        let p = UserDefaultsPersistence(); let ds = UserDefaultsDataSource(persistence: p)
        let servers = ds.getServerConfigs().map { c -> ServerStatusEntry.ServerWidgetData in
            let last = ds.getPingHistory(for: c.id)?.records.last
            return .init(name: c.name, emoji: c.guardianEmoji, isOnline: last?.isOnline ?? false, responseTimeMs: last?.responseTimeMs ?? 0)
        }
        let next = Calendar.current.date(byAdding: .minute, value: AppConfig.widgetRefreshMinutes, to: Date()) ?? Date()
        completion(Timeline(entries: [ServerStatusEntry(date: .now, servers: servers)], policy: .after(next)))
    }
}

/// \u670d\u52a1\u5668\u72b6\u6001\u5c0f\u7ec4\u4ef6\u89c6\u56fe
struct ServerStatusWidgetView: View {
    let entry: ServerStatusEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack { Image(systemName: "server.rack").font(.system(size: 12)).foregroundStyle(Color(hex: 0x7C3AED)); Text("\u5b88\u62a4\u72b6\u6001").font(.system(size: 12, weight: .semibold)) }
            ForEach(Array(entry.servers.prefix(3).enumerated()), id: \.offset) { _, s in
                HStack(spacing: 8) { Text(s.emoji).font(.system(size: 16)); Text(s.name).font(.system(size: 11)).lineLimit(1); Spacer()
                    Circle().fill(s.isOnline ? Color(hex: 0x10B981) : Color(hex: 0xEF4444)).frame(width: 8, height: 8)
                    Text(s.isOnline ? "\(s.responseTimeMs)ms" : "\u79bb\u7ebf").font(.system(size: 9, design: .monospaced)).foregroundStyle(.secondary) }
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading).containerBackground(for: .widget) { Color(hex: 0x0F0F23) }
    }
}

/// \u670d\u52a1\u5668\u72b6\u6001\u5c0f\u7ec4\u4ef6\u914d\u7f6e
struct ServerStatusWidget: Widget {
    let kind = "ServerStatusWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ServerStatusProvider()) { ServerStatusWidgetView(entry: $0) }
            .configurationDisplayName("\u670d\u52a1\u5668\u72b6\u6001").description("\u76d1\u63a7\u5b88\u62a4\u8005\u5728\u7ebf\u72b6\u6001").supportedFamilies([.systemSmall])
    }
}
