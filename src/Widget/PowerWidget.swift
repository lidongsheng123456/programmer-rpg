import WidgetKit
import SwiftUI

struct PowerWidgetEntry: TimelineEntry {
    let date: Date
    let powerStats: PowerStats
    let level: CharacterLevel
}

struct PowerWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> PowerWidgetEntry {
        PowerWidgetEntry(date: .now, powerStats: .zero, level: .bronze)
    }

    func getSnapshot(in context: Context, completion: @escaping (PowerWidgetEntry) -> Void) {
        let entry = loadCachedEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PowerWidgetEntry>) -> Void) {
        let entry = loadCachedEntry()
        let nextUpdate = Calendar.current.date(
            byAdding: .minute,
            value: AppConfig.widgetRefreshMinutes,
            to: Date()
        ) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadCachedEntry() -> PowerWidgetEntry {
        let persistence = UserDefaultsPersistence()
        let stats: PowerStats? = try? persistence.load(forKey: AppConfig.StorageKey.cachedPowerStats)
        let power = stats ?? .zero
        return PowerWidgetEntry(date: .now, powerStats: power, level: power.level)
    }
}

struct PowerWidgetView: View {
    let entry: PowerWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    private var smallView: some View {
        VStack(spacing: 6) {
            Text("\(Int(entry.powerStats.totalPower))")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: 0x7C3AED))
            Text("POWER")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
                .tracking(2)
            Text(entry.level.rawValue)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(hex: 0xFBBF24))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color(hex: 0x0F0F23)
        }
    }

    private var mediumView: some View {
        HStack(spacing: 16) {
            VStack(spacing: 6) {
                Text("\(Int(entry.powerStats.totalPower))")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: 0x7C3AED))
                Text(entry.level.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(hex: 0xFBBF24))
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 4) {
                statRow("攻击", value: entry.powerStats.attack, color: Color(hex: 0xEF4444))
                statRow("防御", value: entry.powerStats.defense, color: Color(hex: 0x3B82F6))
                statRow("生命", value: entry.powerStats.health, color: Color(hex: 0x10B981))
                statRow("智力", value: entry.powerStats.intelligence, color: Color(hex: 0xF59E0B))
                statRow("敏捷", value: entry.powerStats.agility, color: Color(hex: 0x8B5CF6))
                statRow("声望", value: entry.powerStats.reputation, color: Color(hex: 0xEC4899))
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .containerBackground(for: .widget) {
            Color(hex: 0x0F0F23)
        }
    }

    private func statRow(_ label: String, value: Double, color: Color) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .frame(width: 24, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.08))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geo.size.width * value / 100.0)
                }
            }
            .frame(height: 6)
            Text("\(Int(value))")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 20, alignment: .trailing)
        }
    }
}

struct PowerWidget: Widget {
    let kind = "PowerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PowerWidgetProvider()) { entry in
            PowerWidgetView(entry: entry)
        }
        .configurationDisplayName("码力值")
        .description("实时显示你的六维战力值")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
