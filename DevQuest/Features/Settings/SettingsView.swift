import SwiftUI
struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section("GitHub 璐﹀彿") {
                    HStack { Image(systemName: "person.fill").foregroundStyle(AppColors.primary); TextField("GitHub 鐢ㄦ埛鍚?, text: $viewModel.githubUsername).foregroundStyle(AppColors.textPrimary) }
                        .listRowBackground(AppColors.backgroundSecondary)
                }
                Section("鏈嶅姟鍣ㄧ洃鎺?) {
                    ForEach(viewModel.serverConfigs) { c in
                        HStack { Text(c.guardianEmoji); VStack(alignment: .leading) { Text(c.name).font(AppTypography.bodyMedium).foregroundStyle(AppColors.textPrimary); Text(c.url).font(AppTypography.captionSmall).foregroundStyle(AppColors.textTertiary) } }
                            .listRowBackground(AppColors.backgroundSecondary)
                    }.onDelete(perform: viewModel.removeServer)
                    VStack(spacing: AppTheme.spacingSM) {
                        TextField("鏈嶅姟鍣ㄥ悕绉?, text: $viewModel.newServerName).foregroundStyle(AppColors.textPrimary)
                        TextField("鏈嶅姟鍣?URL", text: $viewModel.newServerURL).foregroundStyle(AppColors.textPrimary).textInputAutocapitalization(.never).keyboardType(.URL)
                        Button { viewModel.addServer() } label: { Label("娣诲姞鏈嶅姟鍣?, systemImage: "plus.circle.fill").font(AppTypography.label).foregroundStyle(AppColors.primary) }
                            .disabled(viewModel.newServerName.isEmpty || viewModel.newServerURL.isEmpty)
                    }.listRowBackground(AppColors.backgroundSecondary)
                }
                Section("鍏充簬") {
                    HStack { Text("鐗堟湰").foregroundStyle(AppColors.textPrimary); Spacer(); Text("1.0.0").foregroundStyle(AppColors.textTertiary) }.listRowBackground(AppColors.backgroundSecondary)
                }
            }
            .scrollContentBackground(.hidden).background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("璁剧疆").navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("瀹屾垚") { dismiss() }.foregroundStyle(AppColors.primary) } }
        }.preferredColorScheme(.dark)
    }
}