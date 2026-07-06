import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                githubSection
                serverSection
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                        .foregroundStyle(AppColors.primary)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - GitHub Section

    private var githubSection: some View {
        Section {
            HStack {
                Image(systemName: "person.fill")
                    .foregroundStyle(AppColors.primary)
                TextField("GitHub 用户名", text: $viewModel.githubUsername)
                    .foregroundStyle(AppColors.textPrimary)
            }
            .listRowBackground(AppColors.backgroundSecondary)
        } header: {
            Text("GitHub 账号")
                .foregroundStyle(AppColors.textTertiary)
        }
    }

    // MARK: - Server Section

    private var serverSection: some View {
        Section {
            ForEach(viewModel.serverConfigs) { config in
                HStack {
                    Text(config.guardianEmoji)
                    VStack(alignment: .leading) {
                        Text(config.name)
                            .font(AppTypography.bodyMedium)
                            .foregroundStyle(AppColors.textPrimary)
                        Text(config.url)
                            .font(AppTypography.captionSmall)
                            .foregroundStyle(AppColors.textTertiary)
                    }
                }
                .listRowBackground(AppColors.backgroundSecondary)
            }
            .onDelete(perform: viewModel.removeServer)

            VStack(spacing: AppTheme.spacingSM) {
                TextField("服务器名称", text: $viewModel.newServerName)
                    .foregroundStyle(AppColors.textPrimary)
                TextField("服务器 URL", text: $viewModel.newServerURL)
                    .foregroundStyle(AppColors.textPrimary)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                Button {
                    viewModel.addServer()
                } label: {
                    Label("添加服务器", systemImage: "plus.circle.fill")
                        .font(AppTypography.label)
                        .foregroundStyle(AppColors.primary)
                }
                .disabled(viewModel.newServerName.isEmpty || viewModel.newServerURL.isEmpty)
            }
            .listRowBackground(AppColors.backgroundSecondary)
        } header: {
            Text("服务器监控")
                .foregroundStyle(AppColors.textTertiary)
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section {
            HStack {
                Text("版本")
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(AppColors.textTertiary)
            }
            .listRowBackground(AppColors.backgroundSecondary)

            HStack {
                Text("开发者")
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text("DevQuest Team")
                    .foregroundStyle(AppColors.textTertiary)
            }
            .listRowBackground(AppColors.backgroundSecondary)
        } header: {
            Text("关于")
                .foregroundStyle(AppColors.textTertiary)
        }
    }
}
