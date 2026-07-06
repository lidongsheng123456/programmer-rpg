import SwiftUI

/// 设置视图，管理 GitHub 账号和服务器监控配置
struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section("GitHub 账号") {
                    HStack { Image(systemName: "person.fill").foregroundStyle(AppColors.primary); TextField("GitHub 用户名", text: $viewModel.githubUsername).foregroundStyle(AppColors.textPrimary) }
                        .listRowBackground(AppColors.backgroundSecondary)
                }
                Section("服务器监控") {
                    ForEach(viewModel.serverConfigs) { c in
                        HStack { Text(c.guardianEmoji); VStack(alignment: .leading) { Text(c.name).font(AppTypography.bodyMedium).foregroundStyle(AppColors.textPrimary); Text(c.url).font(AppTypography.captionSmall).foregroundStyle(AppColors.textTertiary) } }
                            .listRowBackground(AppColors.backgroundSecondary)
                    }.onDelete(perform: viewModel.removeServer)
                    VStack(spacing: AppTheme.spacingSM) {
                        TextField("服务器名称", text: $viewModel.newServerName).foregroundStyle(AppColors.textPrimary)
                        TextField("服务器地址", text: $viewModel.newServerURL).foregroundStyle(AppColors.textPrimary).textInputAutocapitalization(.never).keyboardType(.URL)
                        Button { viewModel.addServer() } label: { Label("添加服务器", systemImage: "plus.circle.fill").font(AppTypography.label).foregroundStyle(AppColors.primary) }
                            .disabled(viewModel.newServerName.isEmpty || viewModel.newServerURL.isEmpty)
                    }.listRowBackground(AppColors.backgroundSecondary)
                }
                Section("关于") {
                    HStack { Text("版本").foregroundStyle(AppColors.textPrimary); Spacer(); Text("1.0.0").foregroundStyle(AppColors.textTertiary) }.listRowBackground(AppColors.backgroundSecondary)
                }
            }
            .scrollContentBackground(.hidden).background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("设置").navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("完成") { dismiss() }.foregroundStyle(AppColors.primary) } }
        }.preferredColorScheme(.dark)
    }
}
