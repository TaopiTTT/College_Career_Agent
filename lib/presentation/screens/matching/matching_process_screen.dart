import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';

/// 匹配分析过程页 - SSE流式传输分析步骤
class MatchingProcessScreen extends StatefulWidget {
  const MatchingProcessScreen({super.key});

  @override
  State<MatchingProcessScreen> createState() => _MatchingProcessScreenState();
}

class _MatchingProcessScreenState extends State<MatchingProcessScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;

  final List<AnalysisStep> _analysisSteps = [
    AnalysisStep(
      title: '解析岗位描述',
      description: '正在提取岗位关键要求和能力需求...',
      icon: Icons.description_outlined,
    ),
    AnalysisStep(
      title: '能力匹配分析',
      description: '正在对比您的技能与岗位要求的匹配度...',
      icon: Icons.analytics_outlined,
    ),
    AnalysisStep(
      title: '差距分析',
      description: '正在识别能力差距和提升建议...',
      icon: Icons.trending_up_outlined,
    ),
    AnalysisStep(
      title: '生成匹配报告',
      description: '正在生成详细的匹配分析报告...',
      icon: Icons.assessment_outlined,
    ),
  ];

  int _currentStep = 0;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _startAnalysis();
  }

  void _startAnalysis() async {
    for (int i = 0; i < _analysisSteps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        setState(() {
          _currentStep = i;
        });
        _progressController.forward(from: 0);
      }

      // 模拟每个步骤的处理时间
      await Future.delayed(const Duration(seconds: 2));
    }

    if (mounted) {
      setState(() {
        _isComplete = true;
      });

      // 延迟后跳转到结果页
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        context.pushReplacement('/matching/result');
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 顶部图标动画
                  _buildAnimatedIcon(),
                  const SizedBox(height: 32),

                  // 标题
                  Text(
                    _isComplete ? '分析完成！' : '正在分析匹配度',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // 副标题
                  Text(
                    _isComplete
                        ? '即将跳转到结果页面...'
                        : '请稍候，系统正在为您进行智能分析',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // 进度条
                  _buildProgressBar(),
                  const SizedBox(height: 32),

                  // 分析步骤列表
                  _buildAnalysisSteps(),
                  const SizedBox(height: 48),

                  // 跳过按钮
                  if (!_isComplete)
                    TextButton(
                      onPressed: () {
                        context.pushReplacement('/matching/result');
                      },
                      child: const Text(
                        '跳过分析',
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
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.1);
        final opacity = 0.8 + (_pulseController.value * 0.2);

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 120,
              height: 120,
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
                _isComplete ? Icons.check_circle : Icons.psychology_outlined,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentStep + 1) / _analysisSteps.length;

    return Column(
      children: [
        // 进度条
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 12),
        // 进度文本
        Text(
          '${((progress * 100).toInt())}%',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildAnalysisSteps() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        children: List.generate(_analysisSteps.length, (index) {
          final step = _analysisSteps[index];
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.2)
                  : (isCompleted
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
                width: isActive ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // 步骤图标
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.successColor
                        : (isActive
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.3)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : step.icon,
                    color: isCompleted || isActive
                        ? AppTheme.primaryColor
                        : Colors.white,
                  ),
                ),
                const SizedBox(width: 16),

                // 步骤信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ],
                  ),
                ),

                // 当前步骤指示器
                if (isActive)
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
          );
        }),
      ),
    );
  }
}

class AnalysisStep {
  final String title;
  final String description;
  final IconData icon;

  AnalysisStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}
