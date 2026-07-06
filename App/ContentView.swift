import SwiftUI

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

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard, guardian, github, fitness, achievements
    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard:    return "Power"
        case .guardian:     return "Guardian"
        case .github:      return "Battle"
        case .fitness:     return "Dungeon"
        case .achievements: return "Achieve"
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

    @ViewBuilder
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
