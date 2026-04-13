import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/assessment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/assessment_provider.dart';

/// 我的信息主页
class ProfileHomeScreen extends ConsumerWidget {
  const ProfileHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用真实的认证数据
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    // 监听用户画像数据
    final userProfile = ref.watch(userProfileNotifierProvider);
    final assessmentState = ref.watch(assessmentNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的信息'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // 设置页面
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 用户信息卡片
            _buildUserCard(context, user, userProfile),
            const SizedBox(height: 16),

            // 能力画像概览
            _buildProfileOverview(context, userProfile, assessmentState),
            const SizedBox(height: 16),

            // 功能列表
            _buildMenuList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(
      BuildContext context, UserModel? user, UserProfileModel? userProfile) {
    final basicInfo = userProfile?.basicInfo;
    final displayName = basicInfo?.name ?? user?.nickname ?? '未登录';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 头像
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            backgroundImage: user?.avatarUrl != null
                ? NetworkImage(user!.avatarUrl!)
                : null,
            child: user?.avatarUrl == null
                ? Text(
                    displayName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                if (basicInfo?.major != null)
                  Text(
                    '${basicInfo?.major} | ${basicInfo?.education}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  )
                else
                  Text(
                    user?.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                const SizedBox(height: 8),
                if (basicInfo?.school != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      basicInfo!.school!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user?.role == 'student' ? '学生' : '管理员',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 编辑按钮
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              context.push('/profile/edit');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOverview(
      BuildContext context,
      UserProfileModel? userProfile,
      AssessmentStateModel assessmentState) {
    // 计算完整度
    final completedSteps = assessmentState.completedSteps.values.where((v) => v).length;
    final totalSteps = assessmentState.completedSteps.length;
    final completeness = (completedSteps / totalSteps * 100).toInt();

    // 计算竞争力分数
    final softSkills = userProfile?.softSkills;
    int totalScore = 0;
    if (softSkills != null && softSkills.isNotEmpty) {
      totalScore = softSkills.values.reduce((a, b) => a + b).toInt();
      // 归一化到100分制 (假设满分是50分)
      totalScore = (totalScore / 50 * 100).toInt();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '能力画像',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // 跳转到详细画像页面
                    },
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    label: const Text('详情'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 完整度和竞争力
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      '完整度',
                      '$completeness',
                      '%',
                      AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      '竞争力',
                      '$totalScore',
                      '分',
                      AppTheme.warningColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 软能力雷达图预览
              _buildSoftSkillsPreview(context, userProfile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
              ),
              SizedBox(
                height: 24,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    unit,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: color,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSoftSkillsPreview(
      BuildContext context, UserProfileModel? userProfile) {
    final softSkills = userProfile?.softSkills;

    if (softSkills == null || softSkills.isEmpty) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.radar_outlined,
                size: 48,
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 8),
              Text(
                '完成问卷后查看能力画像',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    // 显示软技能列表
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '软能力评估',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...softSkills.entries.map((entry) {
          final category = entry.key;
          final score = entry.value.toInt();
          final maxScore = 10; // 假设每个维度满分是10分

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '$score/$maxScore',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / maxScore,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMenuList(BuildContext context) {
    final menuItems = [
      _MenuItem(
        icon: Icons.description_outlined,
        title: '我的简历',
        subtitle: '查看和编辑个人简历',
        onTap: () {
          // 跳转到简历页面
        },
      ),
      _MenuItem(
        icon: Icons.assessment_outlined,
        title: '分析报告',
        subtitle: '查看岗位匹配分析报告',
        onTap: () {
          context.push('/profile/reports');
        },
      ),
      _MenuItem(
        icon: Icons.history_outlined,
        title: '测评历史',
        subtitle: '查看历史测评记录',
        onTap: () {
          // 跳转到测评历史
        },
      ),
      _MenuItem(
        icon: Icons.favorite_outline,
        title: '收藏的岗位',
        subtitle: '查看收藏的岗位列表',
        onTap: () {
          // 跳转到收藏列表
        },
      ),
      _MenuItem(
        icon: Icons.help_outline,
        title: '帮助与反馈',
        subtitle: '使用帮助和问题反馈',
        onTap: () {
          // 跳转到帮助页面
        },
      ),
      _MenuItem(
        icon: Icons.info_outline,
        title: '关于我们',
        subtitle: '了解应用和团队',
        onTap: () {
          // 跳转到关于页面
        },
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Column(
          children: menuItems.map((item) {
            return Column(
              children: [
                ListTile(
                  leading: Icon(item.icon, color: AppTheme.primaryColor),
                  title: Text(item.title),
                  subtitle: Text(item.subtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: item.onTap,
                ),
                if (item != menuItems.last) const Divider(height: 1),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
