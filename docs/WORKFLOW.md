# 工作流（多机同步）

本项目建议仅同步“代码/资源/工程配置”，避免提交 Xcode 的本机个人状态文件（xcuserdata）。

## 1. 拉取代码
```bash
git clone https://github.com/gulumu555/lalaman-mango.git
cd lalaman-mango
```

如果已有本地仓库：
```bash
git fetch origin
git checkout dev
git pull --ff-only origin dev
```

## 2. 打开 iOS 工程
```bash
open IOS/MomentPin.xcodeproj
```

## 3. 运行（Xcode）
- Scheme 选择：MomentPin
- 设备选择：iPhone 模拟器
- 点击 Run

## 4. 为什么不提交 xcuserdata
`IOS/MomentPin.xcodeproj/**/xcuserdata` 存的是本机/个人的界面布局、断点、最近打开文件、模拟器偏好等。
- 多台机器会互相覆盖
- 产生大量噪声 diff
- 不影响代码运行或构建

## 5. 需要同步的内容（已在 Git）
- `IOS/` 下的 Swift 代码与资源
- `docs/` 产品与规范文档
- Xcode 工程配置（`project.pbxproj`）

如果你仍要强制同步 `xcuserdata`，请明确指示（不推荐）。
