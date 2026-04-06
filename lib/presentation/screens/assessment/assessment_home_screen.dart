import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';

/// 职业能力测评主页
class AssessmentHomeScreen extends ConsumerStatefulWidget {
  const AssessmentHomeScreen({super.key});

  @override
  ConsumerState<AssessmentHomeScreen> createState() =>
      _AssessmentHomeScreenState();
}

class _AssessmentHomeScreenState extends ConsumerState<AssessmentHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('职业能力测评'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // 查看测评历史
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 欢迎卡片
            _buildWelcomeCard(),
            const SizedBox(height: 24),

            // 测评进度概览
            _buildProgressOverview(),
            const SizedBox(height: 24),

            // 测评入口列表
            _buildAssessmentItems(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '欢迎来到职业能力测评',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '通过多维度测评,全面了解您的职业能力,为您匹配最适合的岗位',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '测评进度',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                _buildProgressBadge(),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: const LinearProgressIndicator(
                value: 0.4,
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '已完成 2/5 步骤',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '进行中',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildAssessmentItems() {
    final items = [
      _AssessmentItem(
        icon: Icons.assignment,
        title: '基础信息',
        description: '填写学业背景和基本信息',
        status: _AssessmentStatus.completed,
        onTap: () => context.push('/assessment/basic-info'),
      ),
      _AssessmentItem(
        icon: Icons.build,
        title: '技能自评',
        description: '评估您的专业技能水平',
        status: _AssessmentStatus.completed,
        onTap: () => context.push('/assessment/skills'),
      ),
      _AssessmentItem(
        icon: Icons.quiz,
        title: '软能力问卷',
        description: '通过问卷评估软能力',
        status: _AssessmentStatus.inProgress,
        onTap: () => context.push('/assessment/questionnaire'),
      ),
      _AssessmentItem(
        icon: Icons.chat,
        title: 'AI情境面试',
        description: '与AI面试官进行模拟面试',
        status: _AssessmentStatus.locked,
        onTap: () => _showLockedDialog(context),
      ),
      _AssessmentItem(
        icon: Icons.psychology,
        title: '逻辑探针',
        description: '测试逻辑思维能力',
        status: _AssessmentStatus.locked,
        onTap: () => _showLockedDialog(context),
      ),
      _AssessmentItem(
        icon: Icons.upload_file,
        title: '简历上传',
        description: '上传简历进行智能解析',
        status: _AssessmentStatus.optional,
        onTap: () => context.push('/assessment/resume'),
      ),
    ];

    return Column(
      children: items.map((item) => _buildAssessmentCard(item)).toList(),
    );
  }

  Widget _buildAssessmentCard(_AssessmentItem item) {
    IconData statusIcon;
    Color statusColor;

    switch (item.status) {
      case _AssessmentStatus.completed:
        statusIcon = Icons.check_circle;
        statusColor = AppTheme.successColor;
        break;
      case _AssessmentStatus.inProgress:
        statusIcon = Icons.pending;
        statusColor = AppTheme.warningColor;
        break;
      case _AssessmentStatus.locked:
        statusIcon = Icons.lock;
        statusColor = AppTheme.textSecondaryLight;
        break;
      case _AssessmentStatus.optional:
        statusIcon = Icons.add_circle_outline;
        statusColor = AppTheme.primaryColor;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: item.status == _AssessmentStatus.locked
                      ? Colors.grey.shade100
                      : AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  size: 28,
                  color: item.status == _AssessmentStatus.locked
                      ? Colors.grey
                      : AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          statusIcon,
                          size: 16,
                          color: statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryLight,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('步骤未解锁'),
        content: const Text('请先完成前面的测评步骤'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}

enum _AssessmentStatus {
  completed,
  inProgress,
  locked,
  optional,
}

class _AssessmentItem {
  final IconData icon;
  final String title;
  final String description;
  final _AssessmentStatus status;
  final VoidCallback onTap;

  _AssessmentItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    required this.onTap,
  });
}
