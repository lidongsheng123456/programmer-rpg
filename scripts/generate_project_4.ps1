$ErrorActionPreference = 'Stop'
$root = "D:\idea_project\my_project\programmer-rpg\DevQuest"
function WriteFile($rel, $content) {
    $path = Join-Path $root $rel; $dir = Split-Path $path -Parent
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    [System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::UTF8)
    Write-Host "  [OK] $rel"
}

Write-Host "=== Generating Features ===" -ForegroundColor Cyan

# ==================== Dashboard ====================

WriteFile "Features\Dashboard\DashboardViewModel.swift" @'
import SwiftUI

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var powerStats: PowerStats = .zero
    @Published var achievementCount: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let calculatePower: CalculatePowerUseCase
    private let evaluateAchievement: EvaluateAchievementUseCase
    @AppStorage(AppConfig.StorageKey.githubUsername) private var githubUsername = AppConfig.defaultGitHubUsername

    init(calculatePower: CalculatePowerUseCase, evaluateAchievement: EvaluateAchievementUseCase) {
        self.calculatePower = calculatePower; self.evaluateAchievement = evaluateAchievement
    }

    func refresh() async {
        isLoading = true; errorMessage = nil
        do { powerStats = try await calculatePower.execute(username: githubUsername); achievementCount = evaluateAchievement.getUnlockedCount() }
        catch { errorMessage = error.localizedDescription }
        isLoading = false
    }
}
'@

WriteFile "Features\Dashboard\DashboardView.swift" @'
import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingXL) {
                    characterHeader
                    radarSection
                    statsGrid
                }
                .padding(.horizontal, AppTheme.spacingLG).padding(.bottom, AppTheme.spacingXXL)
            }
            .background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("战力面板").navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .refreshable { await viewModel.refresh() }
            .task { await viewModel.refresh() }
        }.preferredColorScheme(.dark)
    }

    private var characterHeader: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                    Text(viewModel.powerStats.level.rawValue).font(AppTypography.heading2).foregroundStyle(AppColors.accentGold)
                    Text("综合战力").font(AppTypography.caption).foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
                VStack(spacing: 2) {
                    Text("\(Int(viewModel.powerStats.totalPower))").font(AppTypography.displayMedium).foregroundStyle(AppColors.primaryGradient)
                    Text("POWER").font(AppTypography.captionSmall).foregroundStyle(AppColors.textTertiary).tracking(2)
                }
            }
        }
    }

    private var radarSection: some View {
        GlassCard {
            VStack(spacing: AppTheme.spacingMD) {
                HStack { Text("六维属性").font(AppTypography.heading3).foregroundStyle(AppColors.textPrimary); Spacer() }
                RadarChartView(stats: viewModel.powerStats).frame(height: 280)
            }
        }
    }

    private var statsGrid: some View {
        let dims = viewModel.powerStats.dimensions
        let icons = ["bolt.fill", "shield.fill", "heart.fill", "brain.head.profile", "hare.fill", "star.fill"]
        return LazyVGrid(columns: [GridItem(.flexible(), spacing: AppTheme.spacingMD), GridItem(.flexible(), spacing: AppTheme.spacingMD)], spacing: AppTheme.spacingMD) {
            ForEach(Array(dims.enumerated()), id: \.offset) { i, dim in
                GlassCard(padding: AppTheme.spacingMD) {
                    HStack(spacing: AppTheme.spacingSM) {
                        Image(systemName: icons[i]).font(.system(size: 18)).foregroundStyle(AppColors.statColors[i])
                            .frame(width: 32, height: 32).background(AppColors.statColors[i].opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 6))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(dim.label).font(AppTypography.captionSmall).foregroundStyle(AppColors.textTertiary)
                            Text("\(Int(dim.value))").font(AppTypography.statMedium).foregroundStyle(AppColors.textPrimary)
                        }; Spacer()
                    }
                }
            }
        }
    }
}
'@

WriteFile "Features\Dashboard\Components\RadarChartView.swift" @'
import SwiftUI

struct RadarChartView: View {
    let stats: PowerStats; var size: CGFloat; var lineWidth: CGFloat
    @State private var animatedValues: [Double] = Array(repeating: 0, count: 6)
    private let gridLevels = 5
    private var dims: [(label: String, value: Double)] { stats.dimensions }
    private var n: Int { dims.count }

    init(stats: PowerStats, size: CGFloat = 260, lineWidth: CGFloat = 2) { self.stats = stats; self.size = size; self.lineWidth = lineWidth }

    var body: some View {
        ZStack { gridLines; axisLines; dataArea; labels }
            .frame(width: size, height: size)
            .onAppear { withAnimation(AppTheme.animationSlow) { animatedValues = dims.map(\.value) } }
            .onChange(of: stats) { _, _ in withAnimation(AppTheme.animationSlow) { animatedValues = dims.map(\.value) } }
    }

    private var gridLines: some View {
        ForEach(1...gridLevels, id: \.self) { lvl in polygon(scale: CGFloat(lvl) / CGFloat(gridLevels)).stroke(AppColors.borderLight, lineWidth: 0.5) }
    }
    private var axisLines: some View {
        ForEach(0..<n, id: \.self) { i in
            Path { p in p.move(to: center); p.addLine(to: pt(at: angle(i), scale: 1)) }.stroke(AppColors.borderLight, lineWidth: 0.5)
        }
    }
    private var dataArea: some View {
        let path = Path { p in
            for (i, v) in animatedValues.enumerated() {
                let pt = pt(at: angle(i), scale: CGFloat(v / 100))
                i == 0 ? p.move(to: pt) : p.addLine(to: pt)
            }; p.closeSubpath()
        }
        return ZStack {
            path.fill(LinearGradient(colors: [AppColors.primary.opacity(0.3), AppColors.neonCyan.opacity(0.15)], startPoint: .top, endPoint: .bottom))
            path.stroke(LinearGradient(colors: [AppColors.primary, AppColors.neonCyan], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: lineWidth)
            ForEach(0..<n, id: \.self) { i in
                Circle().fill(AppColors.statColors[i]).frame(width: 8, height: 8)
                    .shadow(color: AppColors.statColors[i].opacity(0.6), radius: 4)
                    .position(pt(at: angle(i), scale: CGFloat(animatedValues[i] / 100)))
            }
        }
    }
    private var labels: some View {
        ForEach(0..<n, id: \.self) { i in
            VStack(spacing: 2) {
                Text(dims[i].label).font(AppTypography.caption).foregroundStyle(AppColors.textSecondary)
                Text("\(Int(animatedValues[i]))").font(AppTypography.statSmall).foregroundStyle(AppColors.statColors[i])
            }.position(pt(at: angle(i), scale: 1.2))
        }
    }

    private var center: CGPoint { CGPoint(x: size / 2, y: size / 2) }
    private var radius: CGFloat { size / 2 * 0.7 }
    private func angle(_ i: Int) -> Double { 2 * .pi / Double(n) * Double(i) - .pi / 2 }
    private func pt(at a: Double, scale: CGFloat) -> CGPoint { CGPoint(x: center.x + cos(a) * radius * scale, y: center.y + sin(a) * radius * scale) }
    private func polygon(scale: CGFloat) -> Path {
        Path { p in for i in 0..<n { let pt = pt(at: angle(i), scale: scale); i == 0 ? p.move(to: pt) : p.addLine(to: pt) }; p.closeSubpath() }
    }
}
'@

# ==================== ServerGuardian ====================

WriteFile "Features\ServerGuardian\GuardianViewModel.swift" @'
import SwiftUI

@MainActor
final class GuardianViewModel: ObservableObject {
    @Published var serverStatuses: [ServerStatus] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let checkServerHealth: CheckServerHealthUseCase
    init(checkServerHealth: CheckServerHealthUseCase) { self.checkServerHealth = checkServerHealth }

    func refresh() async {
        isLoading = true; errorMessage = nil
        do { serverStatuses = try await checkServerHealth.execute() } catch { errorMessage = error.localizedDescription }
        isLoading = false
    }
    func refreshSingle(_ config: ServerConfig) async {
        do { let s = try await checkServerHealth.executeForConfig(config)
            if let i = serverStatuses.firstIndex(where: { $0.config.id == config.id }) { serverStatuses[i] = s }
        } catch { errorMessage = error.localizedDescription }
    }
    func getHistory(for configId: UUID) -> ServerPingHistory? { checkServerHealth.getHistory(for: configId) }
}
'@

WriteFile "Features\ServerGuardian\GuardianListView.swift" @'
import SwiftUI

struct GuardianListView: View {
    @ObservedObject var viewModel: GuardianViewModel
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingLG) {
                    GlassCard {
                        HStack {
                            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                                Text("守护兽总览").font(AppTypography.heading3).foregroundStyle(AppColors.textPrimary)
                                let online = viewModel.serverStatuses.filter(\.isOnline).count
                                Text("\(online)/\(viewModel.serverStatuses.count) 在线").font(AppTypography.bodyMedium)
                                    .foregroundStyle(online == viewModel.serverStatuses.count ? AppColors.success : AppColors.warning)
                            }; Spacer()
                            AnimatedProgressRing(progress: viewModel.serverStatuses.isEmpty ? 0 : Double(viewModel.serverStatuses.filter(\.isOnline).count) / Double(viewModel.serverStatuses.count), size: 60,
                                gradientColors: viewModel.serverStatuses.allSatisfy(\.isOnline) ? [AppColors.success, AppColors.neonGreen] : [AppColors.warning, AppColors.error])
                        }
                    }
                    ForEach(viewModel.serverStatuses) { status in
                        NavigationLink {
                            GuardianDetailView(status: status, history: viewModel.getHistory(for: status.config.id), onRefresh: { await viewModel.refreshSingle(status.config) })
                        } label: {
                            GlassCard {
                                HStack(spacing: AppTheme.spacingMD) {
                                    Text(status.config.guardianEmoji).font(.system(size: 36))
                                    VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                                        Text(status.config.name).font(AppTypography.heading3).foregroundStyle(AppColors.textPrimary)
                                        Text(status.config.url).font(AppTypography.captionSmall).foregroundStyle(AppColors.textTertiary).lineLimit(1)
                                    }; Spacer()
                                    VStack(alignment: .trailing, spacing: AppTheme.spacingXS) {
                                        StatusBadge(status.isOnline ? .online : .offline, label: status.isOnline ? "在线" : "离线")
                                        if status.isOnline { Text(status.uptimeDisplay).font(AppTypography.statSmall).foregroundStyle(AppColors.success) }
                                    }
                                    Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.textTertiary)
                                }
                            }
                        }.buttonStyle(.plain)
                    }
                }.padding(.horizontal, AppTheme.spacingLG).padding(.bottom, AppTheme.spacingXXL)
            }
            .background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("服务器守护兽").navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .refreshable { await viewModel.refresh() }.task { await viewModel.refresh() }
        }.preferredColorScheme(.dark)
    }
}
'@

WriteFile "Features\ServerGuardian\GuardianDetailView.swift" @'
import SwiftUI

struct GuardianDetailView: View {
    let status: ServerStatus; let history: ServerPingHistory?; let onRefresh: () async -> Void
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingXL) {
                GlassCard {
                    VStack(spacing: AppTheme.spacingMD) {
                        Text(status.config.guardianEmoji).font(.system(size: 64))
                        Text(status.config.name).font(AppTypography.heading2).foregroundStyle(AppColors.textPrimary)
                        StatusBadge(status.isOnline ? .online : .offline, label: status.isOnline ? "守护中" : "已离线")
                    }.frame(maxWidth: .infinity)
                }
                HStack(spacing: AppTheme.spacingMD) {
                    StatCard(title: "响应时间", value: "\(status.responseTimeMs)ms", icon: "bolt.fill", iconColor: AppColors.success)
                    StatCard(title: "7天在线率", value: String(format: "%.1f%%", history?.uptimePercentage ?? 0), icon: "chart.line.uptrend.xyaxis", iconColor: AppColors.info)
                }
                if let h = history, !h.recentRecords.isEmpty {
                    GlassCard {
                        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                            Text("响应时间趋势").font(AppTypography.heading3).foregroundStyle(AppColors.textPrimary)
                            ResponseTimeChartView(records: h.recentRecords).frame(height: 200)
                        }
                    }
                }
                GlassCard {
                    VStack(spacing: AppTheme.spacingMD) {
                        detailRow("URL", status.config.url); Divider().background(AppColors.borderLight)
                        detailRow("状态码", "\(status.statusCode)"); Divider().background(AppColors.borderLight)
                        detailRow("检测时间", status.checkedAt.relativeString)
                    }
                }
            }.padding(.horizontal, AppTheme.spacingLG).padding(.bottom, AppTheme.spacingXXL)
        }
        .background(AppColors.backgroundGradient.ignoresSafeArea())
        .navigationTitle(status.config.name).navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar).refreshable { await onRefresh() }
    }
    private func detailRow(_ l: String, _ v: String) -> some View {
        HStack { Text(l).font(AppTypography.bodyMedium).foregroundStyle(AppColors.textSecondary); Spacer(); Text(v).font(AppTypography.bodyMedium).foregroundStyle(AppColors.textPrimary).lineLimit(1) }
    }
}
'@

WriteFile "Features\ServerGuardian\Components\ResponseTimeChartView.swift" @'
import SwiftUI
struct ResponseTimeChartView: View {
    let records: [ServerPingHistory.PingRecord]
    @State private var progress: CGFloat = 0
    private var maxMs: Int { max(records.map(\.responseTimeMs).max() ?? 100, 100) }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width; let h = geo.size.height; let step = records.count > 1 ? w / CGFloat(records.count - 1) : w
            ZStack {
                Path { p in
                    guard !records.isEmpty else { return }; p.move(to: CGPoint(x: 0, y: h))
                    for (i, r) in records.enumerated() { p.addLine(to: CGPoint(x: CGFloat(i) * step, y: h - CGFloat(r.responseTimeMs) / CGFloat(maxMs) * h * progress)) }
                    p.addLine(to: CGPoint(x: CGFloat(records.count - 1) * step, y: h)); p.closeSubpath()
                }.fill(LinearGradient(colors: [AppColors.primary.opacity(0.3), AppColors.primary.opacity(0.05)], startPoint: .top, endPoint: .bottom))

                Path { p in
                    for (i, r) in records.enumerated() {
                        let pt = CGPoint(x: CGFloat(i) * step, y: h - CGFloat(r.responseTimeMs) / CGFloat(maxMs) * h * progress)
                        i == 0 ? p.move(to: pt) : p.addLine(to: pt)
                    }
                }.stroke(AppColors.neonGradient, lineWidth: 2)

                ForEach(Array(records.enumerated()), id: \.offset) { i, r in
                    Circle().fill(r.isOnline ? AppColors.success : AppColors.error).frame(width: 6, height: 6)
                        .position(x: CGFloat(i) * step, y: h - CGFloat(r.responseTimeMs) / CGFloat(maxMs) * h * progress)
                }
            }
        }.onAppear { withAnimation(AppTheme.animationSlow) { progress = 1 } }
    }
}
'@

# ==================== GitHubBattle ====================

WriteFile "Features\GitHubBattle\GitHubBattleViewModel.swift" @'
import SwiftUI
@MainActor
final class GitHubBattleViewModel: ObservableObject {
    @Published var profile: GitHubProfile?; @Published var contributions: ContributionSummary?
    @Published var isLoading = false; @Published var errorMessage: String?
    @AppStorage(AppConfig.StorageKey.githubUsername) var githubUsername = AppConfig.defaultGitHubUsername
    private let fetchGitHubData: FetchGitHubDataUseCase
    init(fetchGitHubData: FetchGitHubDataUseCase) { self.fetchGitHubData = fetchGitHubData }

    func refresh() async {
        isLoading = true; errorMessage = nil
        do {
            async let p = fetchGitHubData.execute(username: githubUsername)
            async let c = fetchGitHubData.fetchContributions(username: githubUsername)
            profile = try await p; contributions = try await c
        } catch { errorMessage = error.localizedDescription }
        isLoading = false
    }
}
'@

WriteFile "Features\GitHubBattle\GitHubBattleView.swift" @'
import SwiftUI

struct GitHubBattleView: View {
    @ObservedObject var viewModel: GitHubBattleViewModel
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingXL) {
                    if let p = viewModel.profile {
                        GlassCard {
                            HStack(spacing: AppTheme.spacingLG) {
                                AsyncImage(url: URL(string: p.avatarURL)) { img in img.resizable().scaledToFill() } placeholder: { Circle().fill(AppColors.backgroundTertiary) }
                                    .frame(width: 64, height: 64).clipShape(Circle()).overlay(Circle().strokeBorder(AppColors.primary, lineWidth: 2))
                                VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                                    Text(p.username).font(AppTypography.heading2).foregroundStyle(AppColors.textPrimary)
                                    HStack(spacing: AppTheme.spacingMD) {
                                        Label("\(p.followers)", systemImage: "person.2.fill"); Label("\(p.publicRepos)", systemImage: "folder.fill")
                                    }.font(AppTypography.caption).foregroundStyle(AppColors.textSecondary)
                                }; Spacer()
                            }
                        }
                        HStack(spacing: AppTheme.spacingMD) {
                            StatCard(title: "今日 Commits", value: "\(p.todayCommits)", icon: "flame.fill", iconColor: AppColors.accent)
                            StatCard(title: "总 Stars", value: "\(p.totalStars)", icon: "star.fill", iconColor: AppColors.accentGold)
                        }
                        if let c = viewModel.contributions {
                            GlassCard {
                                VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                                    Text("贡献热力图").font(AppTypography.heading3).foregroundStyle(AppColors.textPrimary)
                                    ContributionGridView(summary: c).frame(height: 120)
                                }
                            }
                        }
                        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                            Text("热门仓库").font(AppTypography.heading3).foregroundStyle(AppColors.textPrimary)
                            ForEach(p.repos.sorted(by: { $0.stargazersCount > $1.stargazersCount }).prefix(5)) { repo in
                                GlassCard(padding: AppTheme.spacingMD) {
                                    VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                                        HStack { Text(repo.name).font(AppTypography.heading3).foregroundStyle(AppColors.textPrimary); Spacer()
                                            HStack(spacing: 4) { Image(systemName: "star.fill").foregroundStyle(AppColors.accentGold); Text("\(repo.stargazersCount)").font(AppTypography.statSmall).foregroundStyle(AppColors.textPrimary) } }
                                        if let d = repo.description { Text(d).font(AppTypography.bodySmall).foregroundStyle(AppColors.textSecondary).lineLimit(2) }
                                        if let l = repo.language { HStack(spacing: 4) { Circle().fill(AppColors.info).frame(width: 8, height: 8); Text(l) }.font(AppTypography.captionSmall).foregroundStyle(AppColors.textTertiary) }
                                    }
                                }
                            }
                        }
                    } else if viewModel.isLoading {
                        ProgressView().tint(AppColors.primary).padding(.top, 100)
                    }
                }.padding(.horizontal, AppTheme.spacingLG).padding(.bottom, AppTheme.spacingXXL)
            }
            .background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("GitHub 战报").navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .refreshable { await viewModel.refresh() }.task { await viewModel.refresh() }
        }.preferredColorScheme(.dark)
    }
}
'@

WriteFile "Features\GitHubBattle\Components\ContributionGridView.swift" @'
import SwiftUI
struct ContributionGridView: View {
    let summary: ContributionSummary
    private let weeks = 13; private let cellSize: CGFloat = 12; private let spacing: CGFloat = 3

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<weeks, id: \.self) { week in
                VStack(spacing: spacing) {
                    ForEach(0..<7, id: \.self) { day in
                        let ds = dateStr(week: week, day: day); let c = summary.count(for: ds)
                        RoundedRectangle(cornerRadius: 2).fill(colorFor(c)).frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
    }
    private func dateStr(week: Int, day: Int) -> String {
        let total = (weeks - 1 - week) * 7 + (6 - day)
        guard let d = Calendar.current.date(byAdding: .day, value: -total, to: Date()) else { return "" }
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: d)
    }
    private func colorFor(_ count: Int) -> Color {
        guard count > 0, summary.maxCount > 0 else { return count > 0 ? AppColors.primary.opacity(0.5) : AppColors.backgroundTertiary }
        let r = Double(count) / Double(max(summary.maxCount, 1))
        switch min(4, Int(r * 4)) {
        case 0: return AppColors.primary.opacity(0.25); case 1: return AppColors.primary.opacity(0.5)
        case 2: return AppColors.primary.opacity(0.75); default: return AppColors.primary
        }
    }
}
'@

# ==================== FitnessDungeon ====================

WriteFile "Features\FitnessDungeon\FitnessDungeonViewModel.swift" @'
import SwiftUI
@MainActor
final class FitnessDungeonViewModel: ObservableObject {
    @Published var todayRecord: FitnessRecord = .empty; @Published var weekRecords: [FitnessRecord] = []
    @Published var dungeonProgress: DungeonProgress?; @Published var isAuthorized = false
    @Published var isLoading = false; @Published var errorMessage: String?
    private let fetchFitnessData: FetchFitnessDataUseCase
    init(fetchFitnessData: FetchFitnessDataUseCase) { self.fetchFitnessData = fetchFitnessData }

    func requestPermission() async {
        do { try await fetchFitnessData.requestPermission(); isAuthorized = true; await refresh() } catch { errorMessage = "HealthKit 授权失败" }
    }
    func refresh() async {
        isLoading = true; errorMessage = nil
        do { todayRecord = try await fetchFitnessData.fetchToday(); weekRecords = try await fetchFitnessData.fetchWeekly()
            dungeonProgress = fetchFitnessData.calculateDungeonProgress(record: todayRecord) } catch { errorMessage = error.localizedDescription }
        isLoading = false
    }
}
'@

WriteFile "Features\FitnessDungeon\FitnessDungeonView.swift" @'
import SwiftUI

struct FitnessDungeonView: View {
    @ObservedObject var viewModel: FitnessDungeonViewModel
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingXL) {
                    if viewModel.isAuthorized {
                        GlassCard {
                            HStack {
                                VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                                    Text("今日副本").font(AppTypography.heading2).foregroundStyle(AppColors.textPrimary)
                                    Text(viewModel.dungeonProgress?.isCompleted == true ? "副本已通关!" : "挑战进行中...")
                                        .font(AppTypography.bodyMedium).foregroundStyle(viewModel.dungeonProgress?.isCompleted == true ? AppColors.accentGold : AppColors.textSecondary)
                                }; Spacer()
                                AnimatedProgressRing(progress: viewModel.dungeonProgress?.overallProgress ?? 0, size: 70, gradientColors: [AppColors.neonGreen, AppColors.neonCyan])
                                    .overlay { Text("\(Int((viewModel.dungeonProgress?.overallProgress ?? 0) * 100))%").font(AppTypography.statSmall).foregroundStyle(AppColors.textPrimary) }
                            }
                        }
                        HStack(spacing: AppTheme.spacingMD) {
                            questCard("figure.walk", "步数", viewModel.todayRecord.stepsDisplay, viewModel.dungeonProgress?.stepsProgress ?? 0, AppColors.neonGreen)
                            questCard("flame.fill", "卡路里", viewModel.todayRecord.caloriesDisplay, viewModel.dungeonProgress?.caloriesProgress ?? 0, AppColors.accent)
                        }
                        questCard("timer", "运动时间", viewModel.todayRecord.exerciseDisplay, viewModel.dungeonProgress?.exerciseProgress ?? 0, AppColors.info)
                        weeklyChart
                    } else {
                        GlassCard {
                            VStack(spacing: AppTheme.spacingLG) {
                                Image(systemName: "heart.text.square.fill").font(.system(size: 48)).foregroundStyle(AppColors.accent)
                                Text("需要 HealthKit 权限").font(AppTypography.heading2).foregroundStyle(AppColors.textPrimary)
                                Button { Task { await viewModel.requestPermission() } } label: {
                                    Text("授权 HealthKit").font(AppTypography.label).foregroundStyle(.white)
                                        .padding(.horizontal, AppTheme.spacingXL).padding(.vertical, AppTheme.spacingMD)
                                        .background(AppColors.primaryGradient).clipShape(Capsule())
                                }
                            }.frame(maxWidth: .infinity).padding(.vertical, AppTheme.spacingXL)
                        }
                    }
                }.padding(.horizontal, AppTheme.spacingLG).padding(.bottom, AppTheme.spacingXXL)
            }
            .background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("健身副本").navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .refreshable { await viewModel.refresh() }.task { await viewModel.requestPermission() }
        }.preferredColorScheme(.dark)
    }

    private func questCard(_ icon: String, _ title: String, _ value: String, _ progress: Double, _ color: Color) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                HStack { Image(systemName: icon).foregroundStyle(color); Text(title).font(AppTypography.caption).foregroundStyle(AppColors.textSecondary); Spacer() }
                Text(value).font(AppTypography.statMedium).foregroundStyle(AppColors.textPrimary)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3).fill(AppColors.backgroundTertiary)
                        RoundedRectangle(cornerRadius: 3).fill(color).frame(width: geo.size.width * min(progress, 1))
                    }
                }.frame(height: 4)
            }
        }
    }

    private var weeklyChart: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                Text("本周步数").font(AppTypography.heading3).foregroundStyle(AppColors.textPrimary)
                HStack(alignment: .bottom, spacing: AppTheme.spacingSM) {
                    ForEach(Array(viewModel.weekRecords.enumerated()), id: \.offset) { _, r in
                        let maxS = viewModel.weekRecords.map(\.steps).max() ?? 1
                        VStack(spacing: 4) {
                            Text("\(r.steps / 1000)k").font(.system(size: 8)).foregroundStyle(AppColors.textTertiary)
                            RoundedRectangle(cornerRadius: 4).fill(r.date.isToday ? AppColors.neonGradient : LinearGradient(colors: [AppColors.primary.opacity(0.5)], startPoint: .top, endPoint: .bottom))
                                .frame(height: max(4, CGFloat(r.steps) / CGFloat(max(maxS, 1)) * 100))
                            Text(r.date.shortDateString).font(.system(size: 8)).foregroundStyle(AppColors.textTertiary)
                        }.frame(maxWidth: .infinity)
                    }
                }.frame(height: 130)
            }
        }
    }
}
'@

# ==================== Achievements + Settings ====================

WriteFile "Features\Achievements\AchievementsViewModel.swift" @'
import SwiftUI
@MainActor
final class AchievementsViewModel: ObservableObject {
    @Published var achievementStatuses: [AchievementStatus] = []; @Published var isLoading = false
    @Published var errorMessage: String?; @Published var selectedCategory: Achievement.Category?
    @AppStorage(AppConfig.StorageKey.githubUsername) private var githubUsername = AppConfig.defaultGitHubUsername
    private let evaluateAchievement: EvaluateAchievementUseCase
    init(evaluateAchievement: EvaluateAchievementUseCase) { self.evaluateAchievement = evaluateAchievement }

    var filteredStatuses: [AchievementStatus] { guard let c = selectedCategory else { return achievementStatuses }; return achievementStatuses.filter { $0.achievement.category == c } }
    var unlockedCount: Int { achievementStatuses.filter(\.isUnlocked).count }
    var totalCount: Int { achievementStatuses.count }

    func refresh() async {
        isLoading = true; errorMessage = nil
        do { achievementStatuses = try await evaluateAchievement.evaluate(username: githubUsername) } catch { errorMessage = error.localizedDescription }
        isLoading = false
    }
}
'@

WriteFile "Features\Achievements\AchievementsView.swift" @'
import SwiftUI

struct AchievementsView: View {
    @ObservedObject var viewModel: AchievementsViewModel
    @State private var showSettings = false
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingXL) {
                    GlassCard {
                        HStack {
                            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                                Text("成就进度").font(AppTypography.heading2).foregroundStyle(AppColors.textPrimary)
                                Text("\(viewModel.unlockedCount) / \(viewModel.totalCount) 已解锁").font(AppTypography.bodyMedium).foregroundStyle(AppColors.accentGold)
                            }; Spacer()
                            AnimatedProgressRing(progress: viewModel.totalCount > 0 ? Double(viewModel.unlockedCount) / Double(viewModel.totalCount) : 0, size: 70, gradientColors: [AppColors.accentGold, AppColors.accent])
                                .overlay { Image(systemName: "trophy.fill").foregroundStyle(AppColors.accentGold) }
                        }
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppTheme.spacingSM) {
                            catChip(nil, "全部")
                            ForEach(Achievement.Category.allCases, id: \.self) { c in catChip(c, c.rawValue) }
                        }
                    }
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: AppTheme.spacingMD), GridItem(.flexible(), spacing: AppTheme.spacingMD)], spacing: AppTheme.spacingMD) {
                        ForEach(viewModel.filteredStatuses) { s in
                            GlassCard(padding: AppTheme.spacingMD) {
                                VStack(spacing: AppTheme.spacingSM) {
                                    ZStack {
                                        Circle().fill(s.isUnlocked ? AppColors.accentGold.opacity(0.15) : AppColors.backgroundTertiary).frame(width: 52, height: 52)
                                        Image(systemName: s.achievement.icon).font(.system(size: 24)).foregroundStyle(s.isUnlocked ? AppColors.accentGold : AppColors.textTertiary)
                                    }
                                    Text(s.achievement.title).font(AppTypography.label).foregroundStyle(s.isUnlocked ? AppColors.textPrimary : AppColors.textTertiary).lineLimit(1)
                                    Text(s.achievement.description).font(AppTypography.captionSmall).foregroundStyle(AppColors.textTertiary).multilineTextAlignment(.center).lineLimit(2)
                                    if !s.isUnlocked {
                                        GeometryReader { geo in ZStack(alignment: .leading) { RoundedRectangle(cornerRadius: 2).fill(AppColors.backgroundTertiary); RoundedRectangle(cornerRadius: 2).fill(AppColors.primary.opacity(0.6)).frame(width: geo.size.width * s.progress) } }.frame(height: 3)
                                    }
                                }
                            }.opacity(s.isUnlocked ? 1 : 0.6)
                        }
                    }
                }.padding(.horizontal, AppTheme.spacingLG).padding(.bottom, AppTheme.spacingXXL)
            }
            .background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("成就殿堂").navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button { showSettings = true } label: { Image(systemName: "gearshape.fill").foregroundStyle(AppColors.textSecondary) } } }
            .sheet(isPresented: $showSettings) { SettingsView(viewModel: SettingsViewModel()) }
            .refreshable { await viewModel.refresh() }.task { await viewModel.refresh() }
        }.preferredColorScheme(.dark)
    }

    private func catChip(_ cat: Achievement.Category?, _ label: String) -> some View {
        let sel = viewModel.selectedCategory == cat
        return Button { withAnimation(AppTheme.animationFast) { viewModel.selectedCategory = cat } } label: {
            Text(label).font(AppTypography.label).foregroundStyle(sel ? .white : AppColors.textSecondary)
                .padding(.horizontal, AppTheme.spacingMD).padding(.vertical, AppTheme.spacingSM)
                .background(sel ? AnyShapeStyle(AppColors.primaryGradient) : AnyShapeStyle(AppColors.backgroundTertiary)).clipShape(Capsule())
        }
    }
}
'@

WriteFile "Features\Settings\SettingsViewModel.swift" @'
import SwiftUI
@MainActor
final class SettingsViewModel: ObservableObject {
    @AppStorage(AppConfig.StorageKey.githubUsername) var githubUsername = AppConfig.defaultGitHubUsername
    @Published var newServerName = ""; @Published var newServerURL = ""; @Published var serverConfigs: [ServerConfig] = []
    private let persistence = UserDefaultsPersistence()
    init() { let ds = UserDefaultsDataSource(persistence: persistence); serverConfigs = ds.getServerConfigs() }

    func addServer() {
        guard !newServerName.isEmpty, !newServerURL.isEmpty else { return }
        serverConfigs.append(ServerConfig(name: newServerName, url: newServerURL))
        UserDefaultsDataSource(persistence: persistence).saveServerConfigs(serverConfigs)
        newServerName = ""; newServerURL = ""
    }
    func removeServer(at offsets: IndexSet) {
        serverConfigs.remove(atOffsets: offsets)
        UserDefaultsDataSource(persistence: persistence).saveServerConfigs(serverConfigs)
    }
}
'@

WriteFile "Features\Settings\SettingsView.swift" @'
import SwiftUI
struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section("GitHub 账号") {
                    HStack { Image(systemName: "person.fill").foregroundStyle(AppColors.primary); TextField("GitHub 用户名", text: $viewModel.githubUsername).foregroundStyle(AppColors.textPrimary) }
                        .listRowBackground(AppColors.backgroundSecondary)
                }
                Section("服务器监控") {
                    ForEach(viewModel.serverConfigs) { c in
                        HStack { Text(c.guardianEmoji); VStack(alignment: .leading) { Text(c.name).font(AppTypography.bodyMedium).foregroundStyle(AppColors.textPrimary); Text(c.url).font(AppTypography.captionSmall).foregroundStyle(AppColors.textTertiary) } }
                            .listRowBackground(AppColors.backgroundSecondary)
                    }.onDelete(perform: viewModel.removeServer)
                    VStack(spacing: AppTheme.spacingSM) {
                        TextField("服务器名称", text: $viewModel.newServerName).foregroundStyle(AppColors.textPrimary)
                        TextField("服务器 URL", text: $viewModel.newServerURL).foregroundStyle(AppColors.textPrimary).textInputAutocapitalization(.never).keyboardType(.URL)
                        Button { viewModel.addServer() } label: { Label("添加服务器", systemImage: "plus.circle.fill").font(AppTypography.label).foregroundStyle(AppColors.primary) }
                            .disabled(viewModel.newServerName.isEmpty || viewModel.newServerURL.isEmpty)
                    }.listRowBackground(AppColors.backgroundSecondary)
                }
                Section("关于") {
                    HStack { Text("版本").foregroundStyle(AppColors.textPrimary); Spacer(); Text("1.0.0").foregroundStyle(AppColors.textTertiary) }.listRowBackground(AppColors.backgroundSecondary)
                }
            }
            .scrollContentBackground(.hidden).background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("设置").navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("完成") { dismiss() }.foregroundStyle(AppColors.primary) } }
        }.preferredColorScheme(.dark)
    }
}
'@

Write-Host "`n=== Features done ===" -ForegroundColor Green

# ==================== Widget ====================

WriteFile "Widget\DevQuestWidgetBundle.swift" @'
import WidgetKit
import SwiftUI

@main
struct DevQuestWidgetBundle: WidgetBundle {
    var body: some Widget { PowerWidget(); ServerStatusWidget() }
}
'@

WriteFile "Widget\PowerWidget.swift" @'
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
            .configurationDisplayName("码力值").description("实时显示六维战力值").supportedFamilies([.systemSmall, .systemMedium])
    }
}
'@

WriteFile "Widget\ServerStatusWidget.swift" @'
import WidgetKit
import SwiftUI

struct ServerStatusEntry: TimelineEntry {
    let date: Date; let servers: [ServerWidgetData]
    struct ServerWidgetData { let name: String; let emoji: String; let isOnline: Bool; let responseTimeMs: Int }
}

struct ServerStatusProvider: TimelineProvider {
    func placeholder(in context: Context) -> ServerStatusEntry { ServerStatusEntry(date: .now, servers: [.init(name: "主服务器", emoji: "🐉", isOnline: true, responseTimeMs: 42)]) }
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

struct ServerStatusWidgetView: View {
    let entry: ServerStatusEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack { Image(systemName: "server.rack").font(.system(size: 12)).foregroundStyle(Color(hex: 0x7C3AED)); Text("守护兽状态").font(.system(size: 12, weight: .semibold)) }
            ForEach(Array(entry.servers.prefix(3).enumerated()), id: \.offset) { _, s in
                HStack(spacing: 8) { Text(s.emoji).font(.system(size: 16)); Text(s.name).font(.system(size: 11)).lineLimit(1); Spacer()
                    Circle().fill(s.isOnline ? Color(hex: 0x10B981) : Color(hex: 0xEF4444)).frame(width: 8, height: 8)
                    Text(s.isOnline ? "\(s.responseTimeMs)ms" : "离线").font(.system(size: 9, design: .monospaced)).foregroundStyle(.secondary) }
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading).containerBackground(for: .widget) { Color(hex: 0x0F0F23) }
    }
}

struct ServerStatusWidget: Widget {
    let kind = "ServerStatusWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ServerStatusProvider()) { ServerStatusWidgetView(entry: $0) }
            .configurationDisplayName("服务器状态").description("监控守护兽在线状态").supportedFamilies([.systemSmall])
    }
}
'@

# ==================== Resources ====================

WriteFile "Resources\Info.plist" @'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSHealthShareUsageDescription</key>
    <string>DevQuest 需要读取你的健康数据（步数、卡路里、运动时间）来计算健身副本进度和生命值战力。</string>
    <key>NSHealthUpdateUsageDescription</key>
    <string>DevQuest 不会修改你的健康数据。</string>
    <key>BGTaskSchedulerPermittedIdentifiers</key>
    <array><string>com.devquest.serverRefresh</string></array>
    <key>UIBackgroundModes</key>
    <array><string>fetch</string><string>processing</string></array>
</dict>
</plist>
'@

Write-Host "`n=== Widget + Resources done ===" -ForegroundColor Green
Write-Host "`n=== ALL FILES GENERATED SUCCESSFULLY ===" -ForegroundColor Cyan

$count = (Get-ChildItem -Recurse $root -Filter *.swift).Count
Write-Host "Total Swift files: $count" -ForegroundColor Yellow
