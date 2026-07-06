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