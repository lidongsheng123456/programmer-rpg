import SwiftUI

@MainActor
final class FitnessDungeonViewModel: ObservableObject {
    @Published var todayRecord: FitnessRecord = .empty
    @Published var weekRecords: [FitnessRecord] = []
    @Published var dungeonProgress: DungeonProgress?
    @Published var isAuthorized = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let fetchFitnessData: FetchFitnessDataUseCase

    init(fetchFitnessData: FetchFitnessDataUseCase) {
        self.fetchFitnessData = fetchFitnessData
    }

    func requestPermission() async {
        do {
            try await fetchFitnessData.requestPermission()
            isAuthorized = true
            await refresh()
        } catch {
            errorMessage = "HealthKit 授权失败"
        }
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil

        do {
            todayRecord = try await fetchFitnessData.fetchToday()
            weekRecords = try await fetchFitnessData.fetchWeekly()
            dungeonProgress = fetchFitnessData.calculateDungeonProgress(record: todayRecord)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
