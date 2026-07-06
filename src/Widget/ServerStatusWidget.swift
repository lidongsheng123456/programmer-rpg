import WidgetKit
import SwiftUI

struct ServerStatusEntry: TimelineEntry {
    let date: Date
    let servers: [ServerWidgetData]

    struct ServerWidgetData {
        let name: String
        let emoji: String
        let isOnline: Bool
        let responseTimeMs: Int
    }
}

struct ServerStatusProvider: TimelineProvider {
    func placeholder(in context: Context) -> ServerStatusEntry {
        ServerStatusEntry(date: .now, servers: [
            .init(name: "主服务器", emoji: "🐉", isOnline: true, responseTimeMs: 42)
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (ServerStatusEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ServerStatusEntry>) -> Void) {
        let persistence = UserDefaultsPersistence()
        let ds = UserDefaultsDataSource(persistence: persistence)
        let configs = ds.getServerConfigs()

        let servers = configs.map { config -> ServerStatusEntry.ServerWidgetData in
            let history = ds.getPingHistory(for: config.id)
            let lastRecord = history?.records.last
            return ServerStatusEntry.ServerWidgetData(
                name: config.name,
                emoji: config.guardianEmoji,
                isOnline: lastRecord?.isOnline ?? false,
                responseTimeMs: lastRecord?.responseTimeMs ?? 0
            )
        }

        let entry = ServerStatusEntry(date: .now, servers: servers)
        let nextUpdate = Calendar.current.date(
            byAdding: .minute, value: AppConfig.widgetRefreshMinutes, to: Date()
        ) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct ServerStatusWidgetView: View {
    let entry: ServerStatusEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "server.rack")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: 0x7C3AED))
                Text("守护兽状态")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.primary)
            }

            ForEach(Array(entry.servers.prefix(3).enumerated()), id: \.offset) { _, server in
                HStack(spacing: 8) {
                    Text(server.emoji)
                        .font(.system(size: 16))
                    Text(server.name)
                        .font(.system(size: 11))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Spacer()
                    Circle()
                        .fill(server.isOnline ? Color(hex: 0x10B981) : Color(hex: 0xEF4444))
                        .frame(width: 8, height: 8)
                    if server.isOnline {
                        Text("\(server.responseTimeMs)ms")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundStyle(.secondary)
                    } else {
                        Text("离线")
                            .font(.system(size: 9))
                            .foregroundStyle(Color(hex: 0xEF4444))
                    }
                }
            }

            if entry.servers.isEmpty {
                Text("暂无服务器")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) {
            Color(hex: 0x0F0F23)
        }
    }
}

struct ServerStatusWidget: Widget {
    let kind = "ServerStatusWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ServerStatusProvider()) { entry in
            ServerStatusWidgetView(entry: entry)
        }
        .configurationDisplayName("服务器状态")
        .description("实时监控守护兽在线状态")
        .supportedFamilies([.systemSmall])
    }
}
