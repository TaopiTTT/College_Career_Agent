import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../data/models/assessment_model.dart';
import '../../../data/models/questionnaire_model.dart';
import '../../providers/assessment_provider.dart';
import '../../widgets/assessment_bottom_nav.dart';

/// 软能力问卷页面
class QuestionnaireScreen extends ConsumerStatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  ConsumerState<QuestionnaireScreen> createState() =>
      _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends ConsumerState<QuestionnaireScreen> {
  final PageController _pageController = PageController();
  int _currentQuestionIndex = 0;
  final Map<String, int> _answers = {};
  final List<QuestionModel> _questions = _getQuestions();
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 获取问卷问题
  static List<QuestionModel> _getQuestions() {
    return [
      // 领导力问题
      QuestionModel(
        id: 'q1',
        question: '在团队项目中，你通常扮演什么角色？',
        options: ['领导者，主动协调团队', '积极参与者，配合团队', '跟随者，完成分配任务', '观察者，很少主动参与'],
        category: '领导力',
        weight: 5,
      ),
      QuestionModel(
        id: 'q2',
        question: '面对团队冲突时，你会怎么做？',
        options: ['主动调解，寻求共识', '私下沟通，缓和矛盾', '保持中立，不介入', '回避冲突'],
        category: '领导力',
        weight: 5,
      ),

      // 沟通能力问题
      QuestionModel(
        id: 'q3',
        question: '在向他人解释复杂概念时，你的表现如何？',
        options: ['能够用简单语言清晰表达', '基本能表达，但需要反复说明', '表达不太清晰', '难以表达清楚'],
        category: '沟通能力',
        weight: 5,
      ),
      QuestionModel(
        id: 'q4',
        question: '在公共场合发言时，你的感受是？',
        options: ['自信流畅，享受表达', '有些紧张但能正常发挥', '比较紧张，影响发挥', '非常紧张，难以表达'],
        category: '沟通能力',
        weight: 5,
      ),

      // 团队协作问题
      QuestionModel(
        id: 'q5',
        question: '当团队成员需要帮助时，你会？',
        options: ['主动提供帮助', '在完成自己的工作后帮助', '视情况而定', '专注于自己的任务'],
        category: '团队协作',
        weight: 5,
      ),
      QuestionModel(
        id: 'q6',
        question: '你认为团队合作的重要性如何？',
        options: ['非常重要，团队成果优先', '重要，但也要考虑个人贡献', '一般，个人能力更重要', '不重要'],
        category: '团队协作',
        weight: 5,
      ),

      // 问题解决能力
      QuestionModel(
        id: 'q7',
        question: '遇到困难问题时，你通常会？',
        options: ['主动分析，寻找多种解决方案', '尝试解决，不行再求助', '等待他人指导', '感到无助，放弃尝试'],
        category: '问题解决',
        weight: 5,
      ),
      QuestionModel(
        id: 'q8',
        question: '面对压力和挑战时，你的反应是？',
        options: ['积极应对，视作成长机会', '努力适应，逐步克服', '感到压力，但能坚持', '容易焦虑，影响表现'],
        category: '问题解决',
        weight: 5,
      ),

      // 学习能力
      QuestionModel(
        id: 'q9',
        question: '学习新技能时，你的方式是？',
        options: ['主动探索，快速掌握', '系统学习，循序渐进', '需要指导，慢慢掌握', '学习较慢，需要反复练习'],
        category: '学习能力',
        weight: 5,
      ),
      QuestionModel(
        id: 'q10',
        question: '你对新知识和新技术的态度是？',
        options: ['非常感兴趣，主动学习', '有兴趣，会了解', '按需学习', '不太感兴趣'],
        category: '学习能力',
        weight: 5,
      ),
    ];
  }

  /// 计算分数
  Map<String, int> _calculateScores() {
    final categoryScores = <String, int>{};

    for (var i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final answerIndex = _answers[question.id] ?? 0;
      final category = question.category ?? '其他';

      // 分数计算：选项索引越小，分数越高（4分、3分、2分、1分）
      final score = (4 - answerIndex) * (question.weight ?? 1);
      categoryScores[category] = (categoryScores[category] ?? 0) + score;
    }

    return categoryScores;
  }

  /// 保存答案并继续
  Future<void> _saveAndContinue() async {
    if (_answers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请完成所有问题后再提交'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 计算分数
      final categoryScores = _calculateScores();
      final totalScore = categoryScores.values.reduce((a, b) => a + b);

      // 保存答案到本地
      final answersData = {
        'answers': _answers,
        'categoryScores': categoryScores,
        'totalScore': totalScore,
        'completedAt': DateTime.now().toIso8601String(),
      };

      await LocalStorageService.saveQuestionnaireAnswers(answersData);

      // 更新用户画像的软技能评分
      ref.read(userProfileNotifierProvider.notifier).updateSoftSkills(
        categoryScores.map((key, value) => MapEntry(key, value.toDouble())),
      );

      // 标记问卷步骤为完成
      ref.read(assessmentNotifierProvider.notifier).completeStep(AssessmentStep.questionnaire);

      // 保存评估状态到本地
      final assessmentState = ref.read(assessmentNotifierProvider);
      await LocalStorageService.saveAssessmentState(assessmentState);

      if (mounted) {
        // 显示成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('问卷已完成！'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        // 跳转到画像生成过渡页
        context.push('/assessment/profile-generation');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败：$e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('软能力问卷'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '步骤 3/5',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 进度条
          _buildProgressBar(progress),
          Expanded(
            child: SingleChildScrollView(
              child: _buildQuestionCard(_questions[_currentQuestionIndex], _currentQuestionIndex),
            ),
          ),
          // 底部导航
          _buildBottomNavigation(),
          // 添加底部间距
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: const AssessmentBottomNav(currentStep: 3),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
          minHeight: 6,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            '问题 ${_currentQuestionIndex + 1}/${_questions.length}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(QuestionModel question, int index) {
    final selectedAnswer = _answers[question.id];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 问题分类标签
          if (question.category != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                question.category!,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 20),

          // 问题文本
          Text(
            question.question,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 32),

          // 选项列表
          ...question.options.asMap().entries.map((entry) {
            final optionIndex = entry.key;
            final optionText = entry.value;
            final isSelected = selectedAnswer == optionIndex;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _answers[question.id] = optionIndex;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor.withValues(alpha: 0.1)
                        : Colors.grey.shade50,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          optionText,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.black87,
                                fontWeight:
                                    isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 上一题按钮
            Expanded(
              child: ElevatedButton(
                onPressed: _currentQuestionIndex > 0
                    ? () {
                        setState(() {
                          _currentQuestionIndex--;
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black87,
                  disabledBackgroundColor: Colors.grey.shade100,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('上一题'),
              ),
            ),
            const SizedBox(width: 16),

            // 下一题/提交按钮
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        if (_currentQuestionIndex < _questions.length - 1) {
                          setState(() {
                            _currentQuestionIndex++;
                          });
                        } else {
                          _saveAndContinue();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.primaryColor.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        _currentQuestionIndex < _questions.length - 1
                            ? '下一题'
                            : '提交问卷',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
