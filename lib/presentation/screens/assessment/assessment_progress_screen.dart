import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../data/models/assessment_model.dart';
import '../../providers/assessment_provider.dart';

/// 测评进度总览页面
class AssessmentProgressScreen extends ConsumerWidget {
  const AssessmentProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessmentState = ref.watch(assessmentNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('测评进度'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 总进度卡片
            _buildTotalProgressCard(context, assessmentState),
            const SizedBox(height: 24),

            // 步骤列表
            Text(
              '测评步骤',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildStepsList(context, assessmentState, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalProgressCard(
      BuildContext context, AssessmentStateModel assessmentState) {
    final progress = assessmentState.progress;
    final completedCount =
        assessmentState.completedSteps.values.where((v) => v).length;
    final totalCount = assessmentState.completedSteps.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
            '总体进度',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '已完成 $completedCount/$totalCount 个步骤',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}%',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsList(
      BuildContext context, AssessmentStateModel assessmentState, WidgetRef ref) {
    final steps = [
      _StepInfo(
        step: AssessmentStep.basicInfo,
        icon: Icons.assignment,
        title: '基础信息',
        description: '填写学业背景和基本信息',
        route: '/assessment/basic-info',
      ),
      _StepInfo(
        step: AssessmentStep.skills,
        icon: Icons.build,
        title: '技能自评',
        description: '评估您的专业技能水平',
        route: '/assessment/skills',
      ),
      _StepInfo(
        step: AssessmentStep.questionnaire,
        icon: Icons.quiz,
        title: '软能力问卷',
        description: '通过问卷评估软能力',
        route: '/assessment/questionnaire',
      ),
      _StepInfo(
        step: AssessmentStep.interview,
        icon: Icons.chat,
        title: 'AI情境面试',
        description: '与AI面试官进行模拟面试',
        route: '/assessment/interview',
      ),
      _StepInfo(
        step: AssessmentStep.logic,
        icon: Icons.psychology,
        title: '逻辑探针',
        description: '测试逻辑思维能力',
        route: '/assessment/logic',
      ),
      _StepInfo(
        step: AssessmentStep.resume,
        icon: Icons.upload_file,
        title: '简历上传',
        description: '上传简历进行智能解析（可选）',
        route: '/assessment/resume',
        isOptional: true,
      ),
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final stepInfo = entry.value;
        final isCompleted = assessmentState.completedSteps[stepInfo.step] ?? false;
        final isUnlocked = ref.read(assessmentNotifierProvider.notifier).isStepUnlocked(stepInfo.step);
        final isLast = index == steps.length - 1;

        return Column(
          children: [
            _buildStepCard(
              context,
              stepInfo,
              isCompleted,
              isUnlocked,
              isLast ? null : steps[index + 1].step,
            ),
            if (!isLast) _buildConnector(context, isCompleted, isUnlocked),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildStepCard(
    BuildContext context,
    _StepInfo stepInfo,
    bool isCompleted,
    bool isUnlocked,
    AssessmentStep? nextStep,
  ) {
    IconData statusIcon;
    Color statusColor;
    Color cardColor;
    Color textColor;

    if (isCompleted) {
      statusIcon = Icons.check_circle;
      statusColor = AppTheme.successColor;
      cardColor = AppTheme.successColor.withValues(alpha: 0.1);
      textColor = Colors.black87;
    } else if (isUnlocked) {
      statusIcon = Icons.radio_button_unchecked;
      statusColor = AppTheme.primaryColor;
      cardColor = AppTheme.primaryColor.withValues(alpha: 0.1);
      textColor = Colors.black87;
    } else {
      statusIcon = Icons.lock;
      statusColor = Colors.grey;
      cardColor = Colors.grey.shade100;
      textColor = Colors.grey;
    }

    return InkWell(
      onTap: isUnlocked
          ? () {
              context.push(stepInfo.route);
            }
          : () {
              _showLockedDialog(context);
            },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                statusIcon,
                size: 28,
                color: statusColor,
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
                        stepInfo.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 8),
                      if (stepInfo.isOptional)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '可选',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stepInfo.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor.withValues(alpha: 0.7),
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: statusColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnector(BuildContext context, bool isCompleted, bool isUnlocked) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50),
      height: 30,
      child: CustomPaint(
        size: const Size(2, 30),
        painter: _ConnectorPainter(
          isCompleted: isCompleted,
          isUnlocked: isUnlocked,
        ),
      ),
    );
  }

  void _showLockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.lock,
              color: AppTheme.warningColor,
            ),
            const SizedBox(width: 8),
            const Text('步骤未解锁'),
          ],
        ),
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

class _ConnectorPainter extends CustomPainter {
  final bool isCompleted;
  final bool isUnlocked;

  _ConnectorPainter({required this.isCompleted, required this.isUnlocked});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isCompleted
          ? AppTheme.successColor
          : isUnlocked
              ? AppTheme.primaryColor.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width / 2, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _StepInfo {
  final AssessmentStep step;
  final IconData icon;
  final String title;
  final String description;
  final String route;
  final bool isOptional;

  _StepInfo({
    required this.step,
    required this.icon,
    required this.title,
    required this.description,
    required this.route,
    this.isOptional = false,
  });
}
