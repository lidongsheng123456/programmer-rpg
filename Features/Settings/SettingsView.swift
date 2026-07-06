import SwiftUI
struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section("GitHub Account") {
                    HStack { Image(systemName: "person.fill").foregroundStyle(AppColors.primary); TextField("GitHub Username", text: $viewModel.githubUsername).foregroundStyle(AppColors.textPrimary) }
                        .listRowBackground(AppColors.backgroundSecondary)
                }
                Section("Server Monitor") {
                    ForEach(viewModel.serverConfigs) { c in
                        HStack { Text(c.guardianEmoji); VStack(alignment: .leading) { Text(c.name).font(AppTypography.bodyMedium).foregroundStyle(AppColors.textPrimary); Text(c.url).font(AppTypography.captionSmall).foregroundStyle(AppColors.textTertiary) } }
                            .listRowBackground(AppColors.backgroundSecondary)
                    }.onDelete(perform: viewModel.removeServer)
                    VStack(spacing: AppTheme.spacingSM) {
                        TextField("Server Name", text: $viewModel.newServerName).foregroundStyle(AppColors.textPrimary)
                        TextField("Server URL", text: $viewModel.newServerURL).foregroundStyle(AppColors.textPrimary).textInputAutocapitalization(.never).keyboardType(.URL)
                        Button { viewModel.addServer() } label: { Label("Add Server", systemImage: "plus.circle.fill").font(AppTypography.label).foregroundStyle(AppColors.primary) }
                            .disabled(viewModel.newServerName.isEmpty || viewModel.newServerURL.isEmpty)
                    }.listRowBackground(AppColors.backgroundSecondary)
                }
                Section("About") {
                    HStack { Text("Version").foregroundStyle(AppColors.textPrimary); Spacer(); Text("1.0.0").foregroundStyle(AppColors.textTertiary) }.listRowBackground(AppColors.backgroundSecondary)
                }
            }
            .scrollContentBackground(.hidden).background(AppColors.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Settings").navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() }.foregroundStyle(AppColors.primary) } }
        }.preferredColorScheme(.dark)
    }
}
