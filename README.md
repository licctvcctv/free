# FreeGo Flutter - 社交旅行应用

一个基于Flutter开发的社交旅行平台，集成了视频分享、社交网络、旅行规划和预订等功能。

## 功能特性

- 🎥 **视频分享与直播** - 支持视频上传、播放和实时直播
- 👥 **社交网络** - 好友系统、群组聊天、消息推送
- 🗺️ **旅行规划** - 酒店预订、餐厅推荐、景点介绍
- 🛒 **电商集成** - 商品购买、支付处理
- 📍 **地图集成** - 高德地图定位和导航
- 💬 **微信集成** - 微信SDK登录和分享

## 自动构建 🚀

本项目已配置GitHub Actions自动构建，支持：

### 持续集成 (CI)
- ✅ 代码推送时自动触发构建
- ✅ Pull Request时自动测试
- ✅ 代码分析和测试覆盖率检查

### 多平台构建
- 🤖 **Android**: APK和AAB格式
- 🍎 **iOS**: IPA格式（无签名）
- 🌐 **Web**: 静态网页版本

### 构建触发条件
- 推送到 `main` 或 `develop` 分支
- 创建Pull Request到 `main` 分支
- 发布新版本时自动构建并上传到Release

## 开发环境

### 环境要求
- Flutter SDK 3.19.0+
- Dart SDK 2.19.6+
- Android Studio / VS Code
- Xcode (iOS开发)

### 快速开始

1. **克隆项目**
   ```bash
   git clone https://github.com/licctvcctv/free.git
   cd free
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **生成代码**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **运行应用**
   ```bash
   flutter run
   ```

## 构建命令

### Android
```bash
# 构建APK
flutter build apk --release

# 构建AAB
flutter build appbundle --release
```

### iOS
```bash
# 构建iOS (需要macOS)
flutter build ios --release --no-codesign
```

### Web
```bash
# 构建Web版本
flutter build web --release
```

## 项目结构

```
lib/
├── components/          # UI组件
│   ├── chat/           # 聊天相关组件
│   ├── user/           # 用户相关组件
│   ├── video/          # 视频相关组件
│   └── view/           # 通用视图组件
├── config/             # 配置文件
├── util/               # 工具类
└── main.dart           # 应用入口
```

## 技术栈

- **框架**: Flutter 3.19.0
- **状态管理**: Riverpod
- **网络请求**: Dio
- **地图服务**: 高德地图
- **视频处理**: FFmpeg
- **支付集成**: 支付宝、微信支付
- **推送服务**: 极光推送

## 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。
