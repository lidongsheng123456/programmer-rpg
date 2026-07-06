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