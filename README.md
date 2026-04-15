# AI学生职业生涯 - Flutter大前端应用

> **职业能力测评与岗位匹配平台** - 基于Flutter开发的跨平台应用（Web、Android、iOS）

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📋 项目概述

本应用是一个完整的学生职业能力测评与岗位匹配平台，提供多维度测评、智能岗位推荐、能力画像生成等核心功能。

**核心特性：**
- 🧠 **多维度测评**: 基础信息、技能自评、软能力问卷、AI面试、逻辑测试、简历解析
- 📊 **能力画像**: 雷达图展示个人能力维度，生成详细分析报告
- 💼 **智能匹配**: 基于能力画像匹配最合适的岗位（27+真实岗位数据）
- 🔐 **安全认证**: JWT Token + 自动刷新，7天免登录
- 💾 **数据持久化**: 本地存储 + 自动加载，支持断点续填

**技术栈**: Flutter + Riverpod + fl_chart
**支持平台**: Web、Android、iOS
**主色调**: 青绿色 (#2E7D32)

## 🚀 快速开始

### 环境要求

- Flutter SDK >= 3.11.0
- Dart SDK >= 3.11.0
- VS Code / Android Studio

### 安装运行

```bash
# 1. 进入项目目录
cd app

# 2. 安装依赖
flutter pub get

# 3. 生成JSON序列化代码
flutter pub run build_runner build --delete-conflicting-outputs

# 4. 运行项目（选择一个）
flutter run -d chrome    # Web端（推荐）
flutter run -d android   # Android端
flutter run -d ios       # iOS端
```

### 环境配置

在运行前，请确保配置以下环境：

1. **后端API地址**
   - 编辑 `lib/core/config/app_config.dart`
   - 设置 `authApiUrl` 为你的认证API地址

2. **数据文件**
   - 岗位数据已包含在 `assets/data/jobs.json`（27条真实岗位）
   - 无需额外配置

## 📱 应用功能

### 核心模块

#### 1. 职业能力测评

完整的6步测评流程：

- ✅ **基础信息填写** (Step 1)
  - 姓名、性别、出生日期
  - 学历、专业、学校、毕业年份
  - 联系方式、个人标签
  - 支持自动加载已保存数据

- ✅ **技能自评** (Step 2)
  - 技术技能选择与评分
  - 技能熟练度标注
  - 支持自定义技能

- ✅ **软能力问卷** (Step 3)
  - 多维度软能力评估
  - 标准化问卷题目
  - 自动评分系统

- ✅ **AI情境面试** (Step 4)
  - 模拟真实面试场景
  - AI问题生成与回答
  - 回答质量评估

- ✅ **逻辑探针测试** (Step 5)
  - 逻辑思维能力测试
  - 多种题型支持
  - 自动判分

- ✅ **简历上传与解析** (Step 6)
  - 支持PDF/Word简历上传
  - AI自动解析简历内容
  - 信息提取与结构化

**数据持久化：**
- 所有步骤自动保存到本地
- 支持断点续填
- 应用重启后自动恢复进度

#### 2. 岗位浏览与管理

- ✅ **岗位列表展示**
  - 27条真实岗位数据
  - 岗位名称、薪资、地点
  - 公司信息、行业类型
  - 支持搜索和筛选

- ✅ **多维度筛选**
  - 按行业筛选（10+行业分类）
  - 按地点筛选（多个城市）
  - 关键词搜索

- ✅ **岗位详情**
  - 岗位要求与职责
  - 公司详情介绍
  - 薪资范围展示
  - 原始链接跳转

#### 3. 个人中心

- ✅ **能力画像展示**
  - 基础信息卡片
  - 软能力雷达图
  - 完整度与竞争力评分

- ✅ **测评进度管理**
  - 实时进度显示
  - 已完成/未完成状态
  - 一键继续测评

- ✅ **个人信息管理**
  - 自动加载已保存信息
  - 支持编辑和更新
  - 数据同步到各模块

#### 4. 认证系统

- ✅ **用户注册/登录**
  - 邮箱验证码注册
  - 密码登录
  - 记住密码功能

- ✅ **登录状态持久化**
  - 7天免登录
  - Token自动刷新
  - 安全存储（Keychain/Keystore）

- ✅ **路由守卫**
  - 自动重定向到登录页
  - 登录后自动跳转主页
  - Token过期自动处理

## 🏗️ 项目架构

### 分层架构

```
lib/
├── core/                    # 核心层
│   ├── config/             # 配置（主题、常量）
│   │   ├── app_theme.dart          # 应用主题
│   │   └── app_config.dart         # 应用配置
│   ├── network/            # 网络层
│   │   └── auth_api_service.dart   # 认证API服务
│   ├── storage/            # 存储层
│   │   ├── token_storage.dart      # Token管理
│   │   └── local_storage_service.dart # 本地存储
│   └── router/             # 路由配置
│       └── app_router.dart         # 路由定义
│
├── data/                   # 数据层
│   ├── models/             # 数据模型
│   │   ├── user_model.dart         # 用户模型
│   │   ├── assessment_model.dart   # 测评模型
│   │   └── job_model.dart          # 岗位模型
│   ├── services/           # 数据服务
│   │   └── job_data_service.dart   # 岗位数据服务
│   └── repositories/       # 仓库
│       └── auth_repository.dart    # 认证仓库
│
├── presentation/           # 表现层
│   ├── providers/          # 状态管理（Riverpod）
│   │   ├── auth_provider.dart      # 认证状态
│   │   └── assessment_provider.dart # 测评状态
│   ├── screens/            # 页面
│   │   ├── auth/           # 认证模块
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── assessment/     # 测评模块
│   │   │   ├── assessment_home_screen.dart
│   │   │   ├── assessment_progress_screen.dart
│   │   │   ├── basic_info_screen.dart
│   │   │   ├── skills_self_assessment_screen.dart
│   │   │   └── questionnaire_screen.dart
│   │   ├── jobs/           # 岗位模块
│   │   │   ├── jobs_home_screen.dart
│   │   │   └── job_list_screen.dart
│   │   ├── profile/        # 个人中心
│   │   │   └── profile_home_screen.dart
│   │   └── home/           # 主页
│   │       └── home_dashboard_screen.dart
│   └── widgets/            # 可复用组件
│       ├── charts/         # 图表组件
│       │   ├── radar_chart_widget.dart
│       │   └── progress_chart_widget.dart
│       └── common/         # 通用组件
│           └── assessment_bottom_nav.dart
│
└── assets/                 # 资源文件
    ├── data/               # 数据文件
    │   └── jobs.json       # 岗位数据
    ├── images/             # 图片资源
    └── icons/              # 图标资源
```

### 技术栈

| 类别 | 技术 | 版本 | 说明 |
|------|------|------|------|
| **框架** | Flutter | 3.x | 跨平台UI框架 |
| **语言** | Dart | 3.x | 编程语言 |
| **状态管理** | Riverpod | 2.x | 响应式状态管理 |
| **路由** | go_router | 13.x | 声明式路由 |
| **网络** | Dio | 5.x | HTTP客户端 |
| **图表** | fl_chart | 0.66.x | 高性能图表库 |
| **安全存储** | flutter_secure_storage | - | Token安全存储 |
| **本地存储** | shared_preferences | - | 数据持久化 |
| **JSON序列化** | json_annotation | - | 代码生成 |

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

// 背景色
backgroundColor: #F5F5F5   // 背景灰
surfaceColor: #FFFFFF      // 表面白
```

### 组件主题

- ✅ 完整的Material Design 3主题
- ✅ 自定义颜色系统
- ✅ 渐变色支持（LinearGradient）
- ✅ 圆角卡片设计（BorderRadius 12-16px）
- ✅ 自定义按钮样式
- ✅ 统一的间距系统（4px倍数）

## 📊 数据可视化

### 图表组件

1. **雷达图** (`RadarChartWidget`)
   - 单维度展示
   - 多维度对比（最多6个维度）
   - 用于软能力画像展示
   - 支持自定义颜色和标签

2. **进度图** (`ProgressChartWidget`)
   - 环形进度条
   - 线性进度条
   - 柱状图
   - 支持动画效果

### 图表特性

- 基于 Canvas 渲染，高性能
- 60fps 流畅运行
- 平滑动画过渡
- 完全响应式设计
- 支持深色/浅色模式

## 💾 数据存储

### 存储策略

1. **Token存储** (`token_storage.dart`)
   - 使用 `FlutterSecureStorage` 加密存储
   - iOS: Keychain
   - Android: EncryptedSharedPreferences
   - Web: localStorage
   - 支持过期时间管理

2. **本地数据存储** (`local_storage_service.dart`)
   - 基础信息（BasicInfo）
   - 测评状态（AssessmentState）
   - 用户画像（UserProfile）
   - 问卷答案（QuestionnaireAnswers）
   - 技能列表（Skills）
   - 登录凭据（Credentials）

### 数据持久化流程

```
用户输入数据
    ↓
Provider更新状态
    ↓
自动保存到本地存储
    ↓
应用重启自动加载
    ↓
恢复到上次状态
```

## 🔐 认证系统

### 功能特性

- ✅ JWT Token管理
- ✅ 自动Token刷新（过期前1天）
- ✅ 安全存储（Keychain/Keystore）
- ✅ 路由守卫（自动重定向）
- ✅ 401自动处理
- ✅ 记住密码功能
- ✅ 7天免登录

### 登录流程

```
1. 用户输入邮箱和密码
   ↓
2. 前端表单验证
   ↓
3. 调用登录API
   ↓
4. 保存Token（安全存储）
   ↓
5. 设置过期时间（7天）
   ↓
6. 获取用户信息
   ↓
7. 更新认证状态
   ↓
8. 跳转到主页
```

### Token刷新机制

```dart
// Token过期检查
Future<bool> isLoggedIn() async {
  final token = await getToken();
  if (token == null) return false;

  final expiry = await getTokenExpiry();
  if (expiry != null && DateTime.now().isAfter(expiry)) {
    await clearTokens();
    return false;
  }

  return true;
}
```

## 📦 构建发布

### Android APK

```bash
# 生成签名密钥（首次）
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key

# 配置签名（android/key.properties）
# 然后构建
flutter build apk --release
# 输出: build/app/outputs/flutter-apk/app-release.apk
```

### iOS

```bash
flutter build ios --release
# 在Xcode中打开 ios/Runner.xcworkspace
# 配置签名和证书
# 归档并导出
```

### Web

```bash
flutter build web --release
# 输出: build/web/
# 可部署到任何静态服务器
```

## 🔧 开发指南

### 添加新页面

1. 在 `lib/presentation/screens/` 创建页面文件
2. 在 `lib/core/router/app_router.dart` 添加路由
3. 在导航处调用 `context.push('/route')`

### 添加新状态

1. 创建 StateNotifier
2. 创建 Provider
3. 在页面中使用 `ref.watch(provider)` 和 `ref.read(provider)`

### 添加新API

1. 在 `lib/core/network/` 创建API服务
2. 在 `lib/data/repositories/` 创建仓库
3. 在 Provider 中调用仓库方法

### 数据持久化

1. 定义数据模型（使用 `json_annotation`）
2. 在 `LocalStorageService` 添加保存/加载方法
3. 在 Provider 中调用存储方法

## 🔍 常见问题

### Q: 编译错误怎么办？

```bash
# 清理并重新安装
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Q: 如何切换主题？

编辑 `lib/core/config/app_theme.dart`，修改 `ThemeData` 配置

### Q: 如何修改API地址？

编辑 `lib/core/config/app_config.dart`，修改 `authApiUrl` 配置

### Q: 图表不显示？

1. 确保已运行 `flutter pub run build_runner build`
2. 检查数据格式是否正确
3. 查看控制台错误日志

### Q: Token过期后怎么办？

系统会自动：
1. 检测Token过期
2. 清除本地Token
3. 重定向到登录页
4. 提示用户重新登录

### Q: 如何查看调试日志？

运行应用时，控制台会显示详细的调试日志：
- 🔐 Token保存/读取
- 🔄 数据加载状态
- ✅ 成功操作
- ❌ 错误信息

### Q: 岗位数据不显示？

1. 检查 `assets/data/jobs.json` 是否存在
2. 确认 `pubspec.yaml` 中已配置 `assets/data/`
3. 运行 `flutter clean && flutter pub get`
4. 查看控制台日志确认加载状态

## 📝 更新日志

### v1.0.0 (当前版本)

**新增功能：**
- ✅ 完整的6步测评流程
- ✅ 岗位浏览与筛选（27条真实数据）
- ✅ 个人能力画像展示
- ✅ 用户认证与登录状态持久化
- ✅ 数据本地存储与自动加载
- ✅ 记住密码功能
- ✅ 详细的调试日志

**技术优化：**
- ✅ 优化Token存储机制
- ✅ 改进数据持久化流程
- ✅ 增强错误处理
- ✅ 添加性能监控日志

## 📜 许可证

MIT License

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

## 📧 联系方式

如有问题，请提交 Issue 或联系项目维护者。

---

**Made with ❤️ using Flutter**
