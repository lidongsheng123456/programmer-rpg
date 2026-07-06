import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @AppStorage(AppConfig.StorageKey.githubUsername)
    var githubUsername = AppConfig.defaultGitHubUsername

    @Published var newServerName = ""
    @Published var newServerURL = ""
    @Published var serverConfigs: [ServerConfig] = []

    private let persistence = UserDefaultsPersistence()

    init() {
        loadServerConfigs()
    }

    func loadServerConfigs() {
        let ds = UserDefaultsDataSource(persistence: persistence)
        serverConfigs = ds.getServerConfigs()
    }

    func addServer() {
        guard !newServerName.isEmpty, !newServerURL.isEmpty else { return }
        let config = ServerConfig(name: newServerName, url: newServerURL)
        serverConfigs.append(config)
        saveConfigs()
        newServerName = ""
        newServerURL = ""
    }

    func removeServer(at offsets: IndexSet) {
        serverConfigs.remove(atOffsets: offsets)
        saveConfigs()
    }

    private func saveConfigs() {
        let ds = UserDefaultsDataSource(persistence: persistence)
        ds.saveServerConfigs(serverConfigs)
    }
}
