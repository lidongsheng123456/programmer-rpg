import SwiftUI
import BackgroundTasks

/// 应用程序入口，类比 Spring Boot 的 @SpringBootApplication
@main
struct DevQuestApp: App {
    @StateObject private var container = DIContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(container)
        }
    }

    init() {
        registerBackgroundTasks()
    }

    /// 注册后台刷新任务，定时检查服务器状态
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: AppConfig.backgroundTaskIdentifier,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            self.handleBackgroundRefresh(refreshTask)
        }
    }

    /// 处理后台刷新：执行服务器健康检查
    private func handleBackgroundRefresh(_ task: BGAppRefreshTask) {
        scheduleNextBackgroundRefresh()
        let operation = Task {
            try? await container.checkServerHealthUseCase.execute()
        }
        task.expirationHandler = { operation.cancel() }
        Task {
            await operation.value
            task.setTaskCompleted(success: true)
        }
    }

    /// 调度下一次后台刷新（15分钟间隔）
    private func scheduleNextBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: AppConfig.backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        try? BGTaskScheduler.shared.submit(request)
    }
}
