import SwiftUI

/// 设置 ViewModel，管理 GitHub 用户名和服务器列表的增删
@MainActor
final class SettingsViewModel: ObservableObject {
    @AppStorage(AppConfig.StorageKey.githubUsername) var githubUsername = AppConfig.defaultGitHubUsername
    @Published var newServerName = ""; @Published var newServerURL = ""; @Published var serverConfigs: [ServerConfig] = []
    private let persistence = UserDefaultsPersistence()
    init() { let ds = UserDefaultsDataSource(persistence: persistence); serverConfigs = ds.getServerConfigs() }

    /// 添加新服务器
    func addServer() {
        guard !newServerName.isEmpty, !newServerURL.isEmpty else { return }
        serverConfigs.append(ServerConfig(name: newServerName, url: newServerURL))
        UserDefaultsDataSource(persistence: persistence).saveServerConfigs(serverConfigs)
        newServerName = ""; newServerURL = ""
    }

    /// 删除服务器
    func removeServer(at offsets: IndexSet) {
        serverConfigs.remove(atOffsets: offsets)
        UserDefaultsDataSource(persistence: persistence).saveServerConfigs(serverConfigs)
    }
}
