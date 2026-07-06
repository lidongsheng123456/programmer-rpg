import SwiftUI

/// 服务器守护者 ViewModel，管理服务器状态刷新和历史记录
@MainActor
final class GuardianViewModel: ObservableObject {
    @Published var serverStatuses: [ServerStatus] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let checkServerHealth: CheckServerHealthUseCase
    init(checkServerHealth: CheckServerHealthUseCase) { self.checkServerHealth = checkServerHealth }

    /// 刷新所有服务器状态
    func refresh() async {
        isLoading = true; errorMessage = nil
        do { serverStatuses = try await checkServerHealth.execute() } catch { errorMessage = error.localizedDescription }
        isLoading = false
    }

    /// 刷新单个服务器状态
    func refreshSingle(_ config: ServerConfig) async {
        do { let s = try await checkServerHealth.executeForConfig(config)
            if let i = serverStatuses.firstIndex(where: { $0.config.id == config.id }) { serverStatuses[i] = s }
        } catch { errorMessage = error.localizedDescription }
    }

    func getHistory(for configId: UUID) -> ServerPingHistory? { checkServerHealth.getHistory(for: configId) }
}
