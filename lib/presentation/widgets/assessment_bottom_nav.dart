import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';

/// 评估页面专用的底部导航栏
class AssessmentBottomNav extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const AssessmentBottomNav({
    super.key,
    required this.currentStep,
    this.totalSteps = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_outlined,
                label: '首页',
                onTap: () => context.go('/'),
              ),
              _buildNavItem(
                context,
                icon: Icons.psychology_outlined,
                label: '测评',
                onTap: () => context.go('/assessment/home'),
              ),
              _buildNavItem(
                context,
                icon: Icons.work_outline,
                label: '岗位',
                onTap: () => context.go('/jobs/list'),
              ),
              _buildNavItem(
                context,
                icon: Icons.message_outlined,
                label: '消息',
                onTap: () => context.go('/'),
              ),
              _buildNavItem(
                context,
                icon: Icons.person_outline,
                label: '我的',
                onTap: () => context.go('/'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: AppTheme.textSecondaryLight,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
