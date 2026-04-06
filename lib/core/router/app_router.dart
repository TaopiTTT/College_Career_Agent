import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/main_screen.dart';

/// 路由配置
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    // TODO: 后期启用认证检查
    // redirect: (context, state) {
    //   final authState = ProviderScope.containerOf(context)
    //       .read(authNotifierProvider);
    //
    //   // 检查是否需要认证
    //   final isAuthRoute = state.matchedLocation.startsWith('/auth') ||
    //       state.matchedLocation == '/splash';
    //
    //   if (!authState.isAuthenticated && !isAuthRoute) {
    //     return '/auth/login';
    //   }
    //
    //   if (authState.isAuthenticated && isAuthRoute) {
    //     return '/';
    //   }
    //
    //   return null;
    // },
    routes: [
      // 启动页
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => const MaterialPage(
          child: SplashScreen(),
        ),
      ),
      // 认证路由
      GoRoute(
        path: '/auth',
        redirect: (context, state) {
          // /auth 是父路由，重定向到登录页
          final location = state.uri.toString();
          if (location.endsWith('/auth') || location.endsWith('/auth/')) {
            return '/auth/login';
          }
          return null;
        },
        routes: [
          GoRoute(
            path: 'login',
            pageBuilder: (context, state) => const MaterialPage(
              child: LoginScreen(),
            ),
          ),
          GoRoute(
            path: 'register',
            pageBuilder: (context, state) => const MaterialPage(
              child: RegisterScreen(),
            ),
          ),
        ],
      ),
      // 主应用路由
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => const MaterialPage(
          child: MainScreen(),
        ),
        routes: [
          // 测评相关路由
          GoRoute(
            path: 'assessment',
            redirect: (context, state) {
              // /assessment 是父路由，重定向到进度页
              final location = state.uri.toString();
              if (location.endsWith('/assessment') || location.endsWith('/assessment/')) {
                return '/assessment/progress';
              }
              return null;
            },
            routes: [
              GoRoute(
                path: 'progress',
                pageBuilder: (context, state) => const MaterialPage(
                  child: AssessmentProgressScreen(),
                ),
              ),
              GoRoute(
                path: 'basic-info',
                pageBuilder: (context, state) => const MaterialPage(
                  child: BasicInfoScreen(),
                ),
              ),
              GoRoute(
                path: 'skills',
                pageBuilder: (context, state) => const MaterialPage(
                  child: SkillsSelfAssessmentScreen(),
                ),
              ),
              GoRoute(
                path: 'questionnaire',
                pageBuilder: (context, state) => const MaterialPage(
                  child: QuestionnaireScreen(),
                ),
              ),
              GoRoute(
                path: 'interview',
                pageBuilder: (context, state) => const MaterialPage(
                  child: InterviewScreen(),
                ),
              ),
            ],
          ),
          // 岗位相关路由
          GoRoute(
            path: 'jobs',
            redirect: (context, state) {
              // /jobs 是父路由，重定向到岗位列表（这里暂时重定向到主页）
              final location = state.uri.toString();
              if (location.endsWith('/jobs') || location.endsWith('/jobs/')) {
                return '/'; // 或者重定向到岗位列表页
              }
              return null;
            },
            routes: [
              GoRoute(
                path: ':jobId',
                pageBuilder: (context, state) {
                  final jobId = state.pathParameters['jobId']!;
                  return MaterialPage(
                    child: JobDetailScreen(jobId: jobId),
                  );
                },
              ),
              GoRoute(
                path: ':jobId/graph',
                pageBuilder: (context, state) {
                  final jobId = state.pathParameters['jobId']!;
                  return MaterialPage(
                    child: JobGraphScreen(jobId: jobId),
                  );
                },
              ),
            ],
          ),
          // 个人中心路由
          GoRoute(
            path: 'profile',
            redirect: (context, state) {
              // /profile 是父路由，重定向到主页（因为profile就是主页的第三个tab）
              return '/';
            },
            routes: [
              GoRoute(
                path: 'edit',
                pageBuilder: (context, state) => const MaterialPage(
                  child: ProfileEditScreen(),
                ),
              ),
              GoRoute(
                path: 'reports',
                pageBuilder: (context, state) => const MaterialPage(
                  child: ReportsListScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const ErrorScreen(),
  );
}

/// 启动页占位
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// 错误页面
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('页面不存在'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 占位Screen - 需要后续实现
class AssessmentProgressScreen extends StatelessWidget {
  const AssessmentProgressScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('测评进度')));
}

class BasicInfoScreen extends StatelessWidget {
  const BasicInfoScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('基础信息')));
}

class SkillsSelfAssessmentScreen extends StatelessWidget {
  const SkillsSelfAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('技能自评')));
}

class QuestionnaireScreen extends StatelessWidget {
  const QuestionnaireScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('问卷')));
}

class InterviewScreen extends StatelessWidget {
  const InterviewScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('面试')));
}

class JobDetailScreen extends StatelessWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('岗位详情: $jobId')));
}

class JobGraphScreen extends StatelessWidget {
  final String jobId;
  const JobGraphScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('岗位图谱: $jobId')));
}

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('编辑资料')));
}

class ReportsListScreen extends StatelessWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('报告列表')));
}
