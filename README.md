# 码力值 DevQuest

一款为程序员打造的 RPG 风格 iOS App，用游戏化方式追踪你的编程、运维、健身和写作数据。

## 功能模块

| 模块 | 描述 |
|------|------|
| 战力面板 | 六维雷达图展示攻击/防御/生命/智力/敏捷/声望 |
| 服务器守护兽 | HTTP 健康检查 + 响应时间曲线 + 7 天在线率 |
| GitHub 战报 | Commit 统计 + 贡献热力图 + 仓库排行 |
| 健身副本 | HealthKit 步数/卡路里/运动时间追踪 |
| 成就殿堂 | 8+ 成就解锁 + 进度追踪 |
| 桌面 Widget | 战力值 + 服务器状态小组件 |

## 技术架构

Clean Architecture + MVVM，借鉴 Spring Boot 分层思想：

```
DevQuest/
├── App/           # 入口 + DI 容器
├── Core/          # 基础设施 (Network / Persistence / Config)
├── Domain/        # 领域层 (Entity + Protocol + UseCase)
├── Data/          # 数据层 (DTO + DataSource + Repository Impl)
├── Features/      # 功能模块 (View + ViewModel)
├── DesignSystem/  # 设计系统 (Theme + Components + Modifiers)
└── Widget/        # WidgetKit 扩展
```

## 构建

需要 macOS + Xcode 15+。

```bash
# 安装 XcodeGen
brew install xcodegen

# 生成 Xcode 项目
xcodegen generate

# 构建
xcodebuild build \
  -project DevQuest.xcodeproj \
  -scheme DevQuest \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

## 六维战力计算公式

- **攻击力** = min(100, todayCommits × 10 + weekCommits × 2)
- **防御力** = 7 天服务器在线率
- **生命值** = min(100, todaySteps / 100 + workoutMinutes × 2)
- **智力** = min(100, totalBlogPosts × 5 + recentPostBonus)
- **敏捷** = 基于 Issue 关闭速度
- **声望** = min(100, totalStars × 5 + followers × 3)
