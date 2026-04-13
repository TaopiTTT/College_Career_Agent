import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';

/// 画像生成过渡页 - 庆祝动画和步骤完成展示
class ProfileGenerationTransitionScreen extends StatefulWidget {
  const ProfileGenerationTransitionScreen({super.key});

  @override
  State<ProfileGenerationTransitionScreen> createState() =>
      _ProfileGenerationTransitionScreenState();
}

class _ProfileGenerationTransitionScreenState
    extends State<ProfileGenerationTransitionScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _checkmarkController;
  late AnimationController _progressController;

  final List<String> _completedSteps = [
    '基础信息填写',
    '硬技能自评',
    '软能力问卷',
  ];

  int _currentStepIndex = 0;
  bool _allComplete = false;

  @override
  void initState() {
    super.initState();

    _confettiController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // 启动彩带动画
    _confettiController.forward();

    // 逐步显示完成的步骤
    for (int i = 0; i < _completedSteps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() {
          _currentStepIndex = i;
        });
        _progressController.forward(from: 0);
      }
    }

    // 显示完成标记
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _allComplete = true;
      });
      _checkmarkController.forward();
    }

    // 自动跳转到画像结果页
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.pushReplacement('/assessment/profile-result');
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _checkmarkController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 彩带动画
                SizedBox(
                  height: 200,
                  child: _buildConfettiAnimation(),
                ),
                const SizedBox(height: 40),

                // 完成标记
                _buildCompletionIcon(),
                const SizedBox(height: 24),

                // 标题
                Text(
                  _allComplete ? '测评完成！' : '正在生成您的画像...',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // 副标题
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _allComplete
                        ? '您的个性化能力画像已准备就绪'
                        : '正在分析您的评估数据',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 48),

                // 完成的步骤列表
                _buildCompletedStepsList(),
                const SizedBox(height: 48),

                // 跳过按钮
                if (!_allComplete)
                  TextButton(
                    onPressed: () {
                      context.pushReplacement('/assessment/profile-result');
                    },
                    child: const Text(
                      '跳过动画',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfettiAnimation() {
    return AnimatedBuilder(
      animation: _confettiController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(300, 200),
          painter: _ConfettiPainter(_confettiController.value),
        );
      },
    );
  }

  Widget _buildCompletionIcon() {
    return AnimatedBuilder(
      animation: _checkmarkController,
      builder: (context, child) {
        final scale = _checkmarkController.value *
            Curves.elasticOut.transform(_checkmarkController.value);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 60,
              color: AppTheme.successColor,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompletedStepsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: List.generate(_completedSteps.length, (index) {
          final isActive = index <= _currentStepIndex;
          final isCurrent = index == _currentStepIndex;

          return AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.3,
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  // 完成图标
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      isActive ? Icons.check : Icons.radio_button_unchecked,
                      size: 20,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // 步骤名称
                  Expanded(
                    child: Text(
                      _completedSteps[index],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),

                  // 当前步骤指示器
                  if (isCurrent)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double animationValue;

  _ConfettiPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (animationValue == 0) return;

    final paint = Paint()..style = PaintingStyle.fill;

    // 彩色纸屑
    final colors = [
      AppTheme.primaryColor,
      AppTheme.warningColor,
      AppTheme.successColor,
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
    ];

    for (int i = 0; i < 50; i++) {
      final color = colors[i % colors.length];
      paint.color = color.withValues(
        alpha: (1 - animationValue).clamp(0.0, 1.0),
      );

      final x = (size.width * ((i * 137.5) % 100) / 100);
      final y = (animationValue * size.height * ((i * 73.3) % 100) / 100);

      final confettiSize = 8.0 + (i % 4) * 2.0;

      canvas.drawCircle(
        Offset(x, y),
        confettiSize * (1 - animationValue / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
