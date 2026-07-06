import SwiftUI

/// \u4f53\u80fd\u526f\u672c ViewModel\uff0c\u7ba1\u7406 HealthKit \u6388\u6743\u548c\u5065\u5eb7\u6570\u636e\u52a0\u8f7d
@MainActor
final class FitnessDungeonViewModel: ObservableObject {
    @Published var todayRecord: FitnessRecord = .empty; @Published var weekRecords: [FitnessRecord] = []
    @Published var dungeonProgress: DungeonProgress?; @Published var isAuthorized = false
    @Published var isLoading = false; @Published var errorMessage: String?
    private let fetchFitnessData: FetchFitnessDataUseCase
    init(fetchFitnessData: FetchFitnessDataUseCase) { self.fetchFitnessData = fetchFitnessData }

    /// \u8bf7\u6c42 HealthKit \u6388\u6743
    func requestPermission() async {
        do { try await fetchFitnessData.requestPermission(); isAuthorized = true; await refresh() } catch { errorMessage = "HealthKit \u6388\u6743\u5931\u8d25" }
    }

    /// \u5237\u65b0\u4eca\u65e5\u548c\u672c\u5468\u5065\u5eb7\u6570\u636e
    func refresh() async {
        isLoading = true; errorMessage = nil
        do { todayRecord = try await fetchFitnessData.fetchToday(); weekRecords = try await fetchFitnessData.fetchWeekly()
            dungeonProgress = fetchFitnessData.calculateDungeonProgress(record: todayRecord) } catch { errorMessage = error.localizedDescription }
        isLoading = false
    }
}
