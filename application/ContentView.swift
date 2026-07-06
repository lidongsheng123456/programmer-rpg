import SwiftUI

/// 主页面 - TabView 底部导航栏，类比 Spring Boot 的路由分发
struct ContentView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                tab.makeView(container: container)
                    .tabItem { Label(tab.title, systemImage: tab.icon) }
                    .tag(tab)
            }
        }
        .tint(AppColors.primary)
    }
}

/// Tab 枚举，定义五大功能模块
enum AppTab: String, CaseIterable, Identifiable {
    case dashboard, guardian, github, fitness, achievements
    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard:    return "\u6218\u529b"
        case .guardian:     return "\u5b88\u62a4"
        case .github:      return "\u6218\u573a"
        case .fitness:     return "\u526f\u672c"
        case .achievements: return "\u6210\u5c31"
        }
    }

    var icon: String {
        switch self {
        case .dashboard:    return "shield.fill"
        case .guardian:     return "hare.fill"
        case .github:      return "flame.fill"
        case .fitness:     return "figure.run"
        case .achievements: return "trophy.fill"
        }
    }

    /// \u6839\u636e Tab \u521b\u5efa\u5bf9\u5e94\u7684\u89c6\u56fe\uff0c\u901a\u8fc7 DIContainer \u6ce8\u5165 ViewModel
    @MainActor @ViewBuilder
    func makeView(container: DIContainer) -> some View {
        switch self {
        case .dashboard:    DashboardView(viewModel: container.makeDashboardViewModel())
        case .guardian:     GuardianListView(viewModel: container.makeGuardianViewModel())
        case .github:       GitHubBattleView(viewModel: container.makeGitHubBattleViewModel())
        case .fitness:      FitnessDungeonView(viewModel: container.makeFitnessDungeonViewModel())
        case .achievements: AchievementsView(viewModel: container.makeAchievementsViewModel())
        }
    }
}
