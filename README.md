# VVebo Fix

修复 VVebo 用户主页显示问题的 iOS Tweak，适用于 iOS 14 和 TrollFools 注入。

## 🚀 自动编译

这个项目使用 GitHub Actions 自动编译，无需本地环境。

### 如何获取 deb 文件：

1. **Fork 这个仓库**
2. **等待自动编译完成**（约 5-10 分钟）
3. **下载编译好的文件**：
   - 进入 `Actions` 页面
   - 点击最新的构建任务
   - 下载 `VVeboFix-deb` 文件

### 手动触发编译：

- 进入 `Actions` 页面
- 选择 `Build VVebo Fix` 工作流
- 点击 `Run workflow` 按钮

## 📱 安装方法

1. 下载生成的 deb 文件到 iOS 设备
2. 使用 TrollFools 注入到 VVebo 应用
3. 重启 VVebo 应用

## ✨ 功能特性

- ✅ 修复用户主页显示问题
- ✅ 自动重定向 API 请求
- ✅ 支持置顶微博标记
- ✅ 兼容 iOS 14+
- ✅ 适配 TrollFools 注入

## 📋 系统要求

- iOS 14.0 或更高版本
- TrollFools 或其他注入工具
- VVebo 应用 (Bundle ID: com.johnil.vvebo)

## 🔧 技术原理

通过 Hook 以下关键点实现修复：
- `NSMutableURLRequest.setURL:` - 拦截并重定向 API 请求
- `NSURLSessionDataTask.resume` - 处理网络请求响应
- 数据转换函数 - 将新 API 格式转换为应用期望的格式

## 📝 版本历史

- **v1.0.0**: 初始版本，修复用户主页显示问题

---

💡 **提示**: 编译完成后，deb 文件会自动保存在 Actions 的 Artifacts 中供下载。