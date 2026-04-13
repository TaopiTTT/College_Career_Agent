import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../data/models/assessment_model.dart';
import '../../providers/assessment_provider.dart';

/// 职业能力测评主页
class AssessmentHomeScreen extends ConsumerWidget {
  const AssessmentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessmentState = ref.watch(assessmentNotifierProvider);

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
            _buildWelcomeCard(context),
            const SizedBox(height: 24),

            // 测评进度概览
            _buildProgressOverview(context, assessmentState),
            const SizedBox(height: 24),

            // 开始测评按钮
            _buildStartButton(context, assessmentState),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      width: double.infinity,
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

  Widget _buildProgressOverview(
      BuildContext context, AssessmentStateModel assessmentState) {
    final progress = assessmentState.progress;
    final completedCount =
        assessmentState.completedSteps.values.where((v) => v).length;
    final totalCount = assessmentState.completedSteps.length;

    String statusText;
    Color statusColor;
    if (progress == 0) {
      statusText = '未开始';
      statusColor = Colors.grey;
    } else if (progress < 1) {
      statusText = '进行中';
      statusColor = AppTheme.warningColor;
    } else {
      statusText = '已完成';
      statusColor = AppTheme.successColor;
    }

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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation(statusColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '已完成 $completedCount/$totalCount 步骤',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(
      BuildContext context, AssessmentStateModel assessmentState) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          context.push('/assessment/progress');
        },
        icon: const Icon(Icons.play_arrow, size: 28),
        label: Text(
          assessmentState.progress == 0 ? '开始测评' : '继续测评',
          style: const TextStyle(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
