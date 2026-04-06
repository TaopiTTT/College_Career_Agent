import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../providers/mock_auth_provider.dart';

/// 我的信息主页
class ProfileHomeScreen extends ConsumerWidget {
  const ProfileHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用模拟数据
    final user = ref.watch(mockUserProvider);

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
            _buildUserCard(context, user),
            const SizedBox(height: 16),

            // 能力画像概览
            _buildProfileOverview(context),
            const SizedBox(height: 16),

            // 功能列表
            _buildMenuList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel? user) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
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
                    user?.nickname.substring(0, 1).toUpperCase() ?? 'U',
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
                  user?.nickname ?? '未登录',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
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

  Widget _buildProfileOverview(BuildContext context) {
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
                      '85',
                      '%',
                      AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      '竞争力',
                      '68',
                      '分',
                      AppTheme.warningColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 软能力雷达图预览
              _buildRadarChartPreview(context),
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
        color: color.withOpacity(0.1),
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

  Widget _buildRadarChartPreview(BuildContext context) {
    // 这里应该使用图表库绘制雷达图
    // 暂时使用占位符
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
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              '软能力雷达图',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
            ),
          ],
        ),
      ),
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
