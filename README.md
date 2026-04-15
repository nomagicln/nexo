# Nexo

Nexo 是一个 **Flutter 桌面 Todo 应用**（Windows + macOS），支持本地存储、过滤、附件、动效，以及桌面 Pin（置顶 + 小便签模式）。

## 开发环境

- Flutter stable（本项目使用 `flutter create` 生成桌面工程）
- macOS：需要 Xcode + CocoaPods

## 运行（macOS）

```bash
flutter doctor -v
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d macos
```

## 构建（macOS）

```bash
flutter build macos --release
```

产物：`build/macos/Build/Products/Release/nexo.app`

## Windows 说明

Windows 的 release 构建需要在 Windows 机器上执行：

```bash
flutter build windows --release
```

## 桌面 Pin

- **Always on top**：主界面右上角按钮切换置顶
- **Widget mode**：主界面右上角按钮切换小便签模式（无边框小窗）\n+- **Opacity**：右上角 opacity 菜单调整透明度（会持久化）\n+
## 本地数据与附件

- 数据库：SQLite（Drift）
- 附件：导入后会复制到应用数据目录（由系统 Application Support 目录决定）

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
