$ErrorActionPreference = 'Stop'
$root = "D:\idea_project\my_project\programmer-rpg\DevQuest"
function WriteFile($rel, $content) {
    $path = Join-Path $root $rel; $dir = Split-Path $path -Parent
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    [System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::UTF8)
    Write-Host "  [OK] $rel"
}

Write-Host "=== Generating DesignSystem ===" -ForegroundColor Cyan

WriteFile "DesignSystem\Theme\AppColors.swift" @'
import SwiftUI

enum AppColors {
    static let primary = Color(hex: 0x7C3AED)
    static let primaryLight = Color(hex: 0xA78BFA)
    static let primaryDark = Color(hex: 0x4C1D95)
    static let accent = Color(hex: 0xF43F5E)
    static let accentGold = Color(hex: 0xFBBF24)
    static let neonCyan = Color(hex: 0x00FFFF)
    static let neonGreen = Color(hex: 0x10B981)
    static let backgroundPrimary = Color(hex: 0x0F0F23)
    static let backgroundSecondary = Color(hex: 0x1A1A2E)
    static let backgroundTertiary = Color(hex: 0x16213E)
    static let textPrimary = Color(hex: 0xE2E8F0)
    static let textSecondary = Color(hex: 0x94A3B8)
    static let textTertiary = Color(hex: 0x64748B)
    static let success = Color(hex: 0x10B981)
    static let warning = Color(hex: 0xF59E0B)
    static let error = Color(hex: 0xEF4444)
    static let info = Color(hex: 0x3B82F6)
    static let border = Color(hex: 0x4C1D95).opacity(0.3)
    static let borderLight = Color.white.opacity(0.08)

    static let primaryGradient = LinearGradient(colors: [primary, Color(hex: 0xA855F7)], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let accentGradient = LinearGradient(colors: [accent, Color(hex: 0xEC4899)], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let backgroundGradient = LinearGradient(colors: [backgroundPrimary, Color(hex: 0x0A0A1A)], startPoint: .top, endPoint: .bottom)
    static let neonGradient = LinearGradient(colors: [neonCyan, primary], startPoint: .leading, endPoint: .trailing)

    static let statColors: [Color] = [
        Color(hex: 0xEF4444), Color(hex: 0x3B82F6), Color(hex: 0x10B981),
        Color(hex: 0xF59E0B), Color(hex: 0x8B5CF6), Color(hex: 0xEC4899)
    ]
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(.sRGB, red: Double((hex >> 16) & 0xFF) / 255.0, green: Double((hex >> 8) & 0xFF) / 255.0, blue: Double(hex & 0xFF) / 255.0, opacity: alpha)
    }
}
'@

WriteFile "DesignSystem\Theme\AppTypography.swift" @'
import SwiftUI
enum AppTypography {
    static let displayLarge = Font.system(size: 48, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 36, weight: .bold, design: .rounded)
    static let heading1 = Font.system(size: 28, weight: .bold)
    static let heading2 = Font.system(size: 22, weight: .semibold)
    static let heading3 = Font.system(size: 18, weight: .semibold)
    static let bodyLarge = Font.system(size: 17, weight: .regular)
    static let bodyMedium = Font.system(size: 15, weight: .regular)
    static let bodySmall = Font.system(size: 13, weight: .regular)
    static let statLarge = Font.system(size: 32, weight: .bold, design: .monospaced)
    static let statMedium = Font.system(size: 20, weight: .semibold, design: .monospaced)
    static let statSmall = Font.system(size: 14, weight: .medium, design: .monospaced)
    static let caption = Font.system(size: 12, weight: .medium)
    static let captionSmall = Font.system(size: 10, weight: .regular)
    static let label = Font.system(size: 14, weight: .medium)
    static let labelSmall = Font.system(size: 12, weight: .regular)
}
'@

WriteFile "DesignSystem\Theme\AppTheme.swift" @'
import SwiftUI
enum AppTheme {
    static let spacingXS: CGFloat = 4; static let spacingSM: CGFloat = 8; static let spacingMD: CGFloat = 12
    static let spacingLG: CGFloat = 16; static let spacingXL: CGFloat = 24; static let spacingXXL: CGFloat = 32
    static let radiusSM: CGFloat = 8; static let radiusMD: CGFloat = 12; static let radiusLG: CGFloat = 16
    static let radiusXL: CGFloat = 20; static let radiusFull: CGFloat = 100
    static let animationFast = Animation.easeInOut(duration: 0.2)
    static let animationMedium = Animation.easeInOut(duration: 0.35)
    static let animationSlow = Animation.easeInOut(duration: 0.6)
    static let animationSpring = Animation.spring(response: 0.5, dampingFraction: 0.7)
    static let glassOpacity: Double = 0.12; static let glassBlur: CGFloat = 20; static let glassBorderOpacity: Double = 0.15
}
'@

WriteFile "DesignSystem\Modifiers\GlassModifier.swift" @'
import SwiftUI
struct GlassModifier: ViewModifier {
    var cornerRadius: CGFloat; var opacity: Double; var borderOpacity: Double
    init(cornerRadius: CGFloat = AppTheme.radiusLG, opacity: Double = AppTheme.glassOpacity, borderOpacity: Double = AppTheme.glassBorderOpacity) {
        self.cornerRadius = cornerRadius; self.opacity = opacity; self.borderOpacity = borderOpacity
    }
    func body(content: Content) -> some View {
        content.background(
            RoundedRectangle(cornerRadius: cornerRadius).fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: cornerRadius).fill(Color.white.opacity(opacity)))
                .overlay(RoundedRectangle(cornerRadius: cornerRadius).strokeBorder(
                    LinearGradient(colors: [Color.white.opacity(borderOpacity), Color.white.opacity(borderOpacity * 0.3)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
        ).clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
extension View {
    func glassCard(cornerRadius: CGFloat = AppTheme.radiusLG, opacity: Double = AppTheme.glassOpacity) -> some View {
        modifier(GlassModifier(cornerRadius: cornerRadius, opacity: opacity))
    }
}
'@

WriteFile "DesignSystem\Modifiers\ShimmerModifier.swift" @'
import SwiftUI
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1
    var duration: Double
    init(duration: Double = 1.5) { self.duration = duration }
    func body(content: Content) -> some View {
        content.overlay(GeometryReader { geo in
            LinearGradient(colors: [.clear, Color.white.opacity(0.15), .clear], startPoint: .leading, endPoint: .trailing)
                .frame(width: geo.size.width * 0.6).offset(x: phase * geo.size.width * 1.6 - geo.size.width * 0.3)
        }).clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMD))
        .onAppear { withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) { phase = 1 } }
    }
}
extension View { func shimmer(duration: Double = 1.5) -> some View { modifier(ShimmerModifier(duration: duration)) } }
'@

WriteFile "DesignSystem\Components\GlassCard.swift" @'
import SwiftUI
struct GlassCard<Content: View>: View {
    let content: Content; var padding: CGFloat; var cornerRadius: CGFloat
    init(padding: CGFloat = AppTheme.spacingLG, cornerRadius: CGFloat = AppTheme.radiusLG, @ViewBuilder content: () -> Content) {
        self.content = content(); self.padding = padding; self.cornerRadius = cornerRadius
    }
    var body: some View { content.padding(padding).glassCard(cornerRadius: cornerRadius) }
}
'@

WriteFile "DesignSystem\Components\StatCard.swift" @'
import SwiftUI
struct StatCard: View {
    let title: String; let value: String; let icon: String; var iconColor: Color
    init(title: String, value: String, icon: String, iconColor: Color = AppColors.primary) {
        self.title = title; self.value = value; self.icon = icon; self.iconColor = iconColor
    }
    var body: some View {
        GlassCard {
            HStack(spacing: AppTheme.spacingMD) {
                Image(systemName: icon).font(.system(size: 24)).foregroundStyle(iconColor)
                    .frame(width: 44, height: 44).background(iconColor.opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusSM))
                VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                    Text(title).font(AppTypography.caption).foregroundStyle(AppColors.textSecondary)
                    Text(value).font(AppTypography.statMedium).foregroundStyle(AppColors.textPrimary)
                }
                Spacer()
            }
        }
    }
}
'@

WriteFile "DesignSystem\Components\StatusBadge.swift" @'
import SwiftUI
struct StatusBadge: View {
    let status: Status; let label: String?
    init(_ status: Status, label: String? = nil) { self.status = status; self.label = label }
    var body: some View {
        HStack(spacing: AppTheme.spacingXS) {
            Circle().fill(status.color).frame(width: 8, height: 8)
            if let label = label { Text(label).font(AppTypography.captionSmall).foregroundStyle(status.color) }
        }.padding(.horizontal, AppTheme.spacingSM).padding(.vertical, AppTheme.spacingXS)
        .background(status.color.opacity(0.1)).clipShape(Capsule())
    }
    enum Status {
        case online, offline, warning, unknown
        var color: Color { switch self { case .online: return AppColors.success; case .offline: return AppColors.error; case .warning: return AppColors.warning; case .unknown: return AppColors.textTertiary } }
    }
}
'@

WriteFile "DesignSystem\Components\AnimatedProgressRing.swift" @'
import SwiftUI
struct AnimatedProgressRing: View {
    let progress: Double; var lineWidth: CGFloat; var size: CGFloat; var gradientColors: [Color]
    @State private var animatedProgress: Double = 0
    init(progress: Double, lineWidth: CGFloat = 8, size: CGFloat = 80, gradientColors: [Color] = [AppColors.primary, AppColors.neonCyan]) {
        self.progress = progress; self.lineWidth = lineWidth; self.size = size; self.gradientColors = gradientColors
    }
    var body: some View {
        ZStack {
            Circle().stroke(AppColors.backgroundTertiary, lineWidth: lineWidth)
            Circle().trim(from: 0, to: animatedProgress)
                .stroke(AngularGradient(colors: gradientColors, center: .center, startAngle: .degrees(-90), endAngle: .degrees(270)),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)).rotationEffect(.degrees(-90))
        }.frame(width: size, height: size)
        .onAppear { withAnimation(AppTheme.animationSlow) { animatedProgress = progress } }
        .onChange(of: progress) { _, v in withAnimation(AppTheme.animationMedium) { animatedProgress = v } }
    }
}
'@

Write-Host "=== DesignSystem done ===" -ForegroundColor Green
Write-Host "=== Run generate_project_4.ps1 for Features ===" -ForegroundColor Cyan
