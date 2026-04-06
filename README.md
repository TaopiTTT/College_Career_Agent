# AI学生职业生涯 - Flutter大前端应用

> **职业能力测评与岗位匹配平台** - 基于Flutter开发的跨平台应用（Web、Android、iOS）

## 📋 项目概述

本应用是一个完整的学生职业能力测评与岗位匹配平台，提供多维度测评、智能岗位推荐、能力画像生成等核心功能。

**技术栈**: Flutter + Riverpod + fl_chart
**支持平台**: Web、Android、iOS
**主色调**: 青绿色 (#2E7D32)

## 🚀 快速开始

### 环境要求

- Flutter SDK >= 3.0.0
- Dart SDK >= 2.17.0
- VS Code / Android Studio

### 安装运行

```bash
# 1. 进入项目目录
cd /Users/username/Project/AIStudentCareer

# 2. 安装依赖
flutter pub get

# 3. 运行项目（选择一个）
flutter run -d chrome    # Web端（推荐）
flutter run -d android   # Android端
flutter run -d ios       # iOS端
```

### 代码生成

首次运行需要生成JSON序列化代码：

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📱 应用功能

### 核心模块

#### 1. 职业能力测评
- ✅ 基础信息填写
- ✅ 技能自评
- ✅ 软能力问卷
- ✅ AI情境面试
- ✅ 逻辑探针测试
- ✅ 简历上传与解析

#### 2. 岗位浏览
- ✅ 岗位列表展示
- ✅ 岗位详情查看
- ✅ 岗位图谱展示
- ✅ 岗位匹配度分析

#### 3. 个人中心
- ✅ 能力画像展示
- ✅ 个人简历管理
- ✅ 分析报告生成
- ✅ 匹配历史记录

## 🏗️ 项目架构

### 分层架构

```
lib/
├── core/                    # 核心层
│   ├── config/             # 配置（主题、常量）
│   ├── network/            # 网络层（Dio封装）
│   ├── storage/            # 存储层（Token管理）
│   ├── router/             # 路由配置
│   ├── errors/             # 错误处理
│   └── utils/              # 工具类（SSE客户端）
│
├── data/                   # 数据层
│   ├── models/             # 数据模型
│   ├── repositories/       # 仓库实现
│   └── datasources/        # 数据源
│
├── domain/                 # 领域层
│   ├── entities/           # 业务实体
│   └── usecases/           # 用例
│
└── presentation/           # 表现层
    ├── providers/          # 状态管理（Riverpod）
    ├── screens/            # 页面
    │   ├── auth/           # 认证模块
    │   ├── assessment/     # 测评模块
    │   ├── jobs/           # 岗位模块
    │   └── profile/        # 个人中心
    └── widgets/            # 可复用组件
        ├── charts/         # 图表组件
        ├── common/         # 通用组件
        └── ...
```

### 技术栈

| 类别 | 技术 | 说明 |
|------|------|------|
| **框架** | Flutter 3.x | 跨平台UI框架 |
| **状态管理** | Riverpod 2.x | 响应式状态管理 |
| **路由** | go_router 13.x | 声明式路由 |
| **网络** | Dio 5.x | HTTP客户端 |
| **图表** | fl_chart 0.66.x | 高性能图表库 |
| **存储** | flutter_secure_storage | 安全存储 |
| **JSON序列化** | json_annotation | 代码生成 |

## 🎨 主题设计

### 颜色规范

```dart
// 主色调 - 青绿色系
primaryColor: #2E7D32      // 青绿
primaryLight: #4CAF50      // 浅青绿
primaryDark: #1B5E20       // 深青绿

// 辅助色
secondaryColor: #66BB6A    // 浅绿
accentColor: #81C784       // 强调绿

// 状态色
successColor: #4CAF50      // 成功
warningColor: #FF9800      // 警告
errorColor: #E53935        // 错误
infoColor: #2196F3         // 信息
```

### 组件主题

- ✅ 完整的Material Design 3主题
- ✅ 自定义颜色系统
- ✅ 渐变色支持
- ✅ 圆角卡片设计
- ✅ 自定义按钮样式

## 📊 数据可视化

### 图表组件

1. **雷达图** (`RadarChartWidget`)
   - 单维度展示
   - 双维度对比
   - 用于软能力画像展示

2. **进度图** (`ProgressChartWidget`)
   - 环形进度条
   - 线性进度条
   - 柱状图

### 图表性能

- 基于 Canvas 渲染
- 60fps 流畅运行
- 支持动画过渡
- 响应式设计

## 🔐 认证系统

### 功能特性

- ✅ JWT Token管理
- ✅ 自动Token刷新
- ✅ 安全存储（Keychain/Keystore）
- ✅ 路由守卫
- ✅ 401自动处理

### 登录流程

1. 用户输入邮箱和密码
2. 前端表单验证
3. 调用登录API
4. 保存Token
5. 跳转到主页


## 📦 构建发布

### Android APK

```bash
flutter build apk --release
# 输出: build/app/outputs/flutter-apk/app-release.apk
```

### iOS

```bash
flutter build ios --release
# 在Xcode中归档和导出
```

### Web

```bash
flutter build web --release
# 输出: build/web/
```

## 🔍 常见问题

### Q: 编译错误怎么办？

A: 运行 `flutter clean && flutter pub get` 重新安装依赖

### Q: 如何切换主题？

A: 主题配置在 `lib/core/config/app_theme.dart`，当前使用浅色主题

### Q: 如何修改API地址？

A: 编辑 `lib/core/config/app_config.dart` 中的 `baseUrl` 或使用环境变量

### Q: 图表不显示？

A: 确保已运行 `flutter pub run build_runner build` 生成代码


## 📜 许可证

MIT License


