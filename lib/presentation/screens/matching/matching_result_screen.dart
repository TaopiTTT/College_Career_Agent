import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../data/models/assessment_model.dart';
import '../../providers/assessment_provider.dart';

/// 匹配分析结果页 - 最终匹配结果展示
class MatchingResultScreen extends ConsumerWidget {
  const MatchingResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileNotifierProvider);

    // 模拟匹配数据
    final matchData = _getMockMatchData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('匹配分析结果'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 总分卡片
            _buildTotalScoreCard(context, matchData),
            const SizedBox(height: 20),

            // 四维能力仪表盘
            _buildAbilityDashboard(context, matchData),
            const SizedBox(height: 20),

            // 雷达图对比
            _buildRadarChartComparison(context, userProfile, matchData),
            const SizedBox(height: 20),

            // 详细分析
            _buildDetailedAnalysis(context, matchData),
            const SizedBox(height: 20),

            // 提升建议
            _buildImprovementSuggestions(context, matchData),
            const SizedBox(height: 32),

            // CTA按钮
            _buildCTAButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalScoreCard(BuildContext context, MatchData matchData) {
    final score = matchData.totalScore;
    final scoreColor = _getScoreColor(score);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scoreColor.withValues(alpha: 0.8),
            scoreColor,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '综合匹配度',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '分',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getScoreLabel(score),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbilityDashboard(BuildContext context, MatchData matchData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '四维能力匹配',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildAbilityGauge(
                    context,
                    '硬技能',
                    matchData.hardSkillsScore,
                    Icons.build_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAbilityGauge(
                    context,
                    '软能力',
                    matchData.softSkillsScore,
                    Icons.psychology_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAbilityGauge(
                    context,
                    '经验',
                    matchData.experienceScore,
                    Icons.work_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAbilityGauge(
                    context,
                    '潜力',
                    matchData.potentialScore,
                    Icons.trending_up_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbilityGauge(
    BuildContext context,
    String label,
    int score,
    IconData icon,
  ) {
    final color = _getScoreColor(score);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '$score',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarChartComparison(
    BuildContext context,
    UserProfileModel? userProfile,
    MatchData matchData,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '能力雷达图对比',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '对比您的能力与岗位要求',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
            ),
            const SizedBox(height: 20),
            _buildRadarChartLegend(context),
            const SizedBox(height: 16),
            ...matchData.softSkillsComparison.entries.map((entry) {
              final dimension = entry.key;
              final comparison = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildSkillComparisonBar(
                  context,
                  dimension,
                  comparison.userScore,
                  comparison.jobScore,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarChartLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(context, '您的能力', AppTheme.primaryColor),
        const SizedBox(width: 24),
        _buildLegendItem(context, '岗位要求', AppTheme.warningColor),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSkillComparisonBar(
    BuildContext context,
    String dimension,
    double userScore,
    double jobScore,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dimension,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Text(
              '您: ${userScore.toInt()} | 岗位: ${jobScore.toInt()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            // 背景条
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // 岗位要求条
            FractionallySizedBox(
              widthFactor: jobScore / 100,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            // 用户能力条
            FractionallySizedBox(
              widthFactor: userScore / 100,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailedAnalysis(BuildContext context, MatchData matchData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '详细分析',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...matchData.analysisPoints.map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        point.isPositive
                            ? Icons.check_circle_outline
                            : Icons.info_outline,
                        color: point.isPositive
                            ? AppTheme.successColor
                            : AppTheme.warningColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          point.text,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildImprovementSuggestions(
    BuildContext context,
    MatchData matchData,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '提升建议',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...matchData.suggestions.asMap().entries.map((entry) {
              final index = entry.key;
              final suggestion = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suggestion.title,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            suggestion.description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondaryLight,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCTAButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.list_alt),
            label: const Text('查看更多岗位'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              // 分享功能
            },
            icon: const Icon(Icons.share),
            label: const Text('分享报告'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: BorderSide(color: AppTheme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 85) return AppTheme.successColor;
    if (score >= 70) return AppTheme.primaryColor;
    if (score >= 60) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  String _getScoreLabel(int score) {
    if (score >= 85) return '高度匹配';
    if (score >= 70) return '较为匹配';
    if (score >= 60) return '基本匹配';
    return '匹配度较低';
  }

  MatchData _getMockMatchData() {
    return MatchData(
      totalScore: 78,
      hardSkillsScore: 82,
      softSkillsScore: 75,
      experienceScore: 70,
      potentialScore: 85,
      softSkillsComparison: {
        '领导力': SkillComparison(userScore: 72, jobScore: 80),
        '沟通能力': SkillComparison(userScore: 85, jobScore: 85),
        '团队协作': SkillComparison(userScore: 78, jobScore: 75),
        '问题解决': SkillComparison(userScore: 80, jobScore: 82),
        '学习能力': SkillComparison(userScore: 88, jobScore: 80),
      },
      analysisPoints: [
        AnalysisPoint(
          text: '您的沟通能力和学习能力突出，完全满足岗位需求',
          isPositive: true,
        ),
        AnalysisPoint(
          text: '硬技能基础扎实，但在高级特性应用上还有提升空间',
          isPositive: true,
        ),
        AnalysisPoint(
          text: '项目经验相对较少，建议积累更多实战经验',
          isPositive: false,
        ),
        AnalysisPoint(
          text: '领导力方面需要加强，可以通过团队项目来锻炼',
          isPositive: false,
        ),
      ],
      suggestions: [
        Suggestion(
          title: '加强高级框架学习',
          description: '深入学习React/Vue的高级特性和最佳实践',
        ),
        Suggestion(
          title: '参与开源项目',
          description: '通过参与开源项目积累实战经验',
        ),
        Suggestion(
          title: '提升团队协作能力',
          description: '主动参与团队项目，锻炼领导和协作能力',
        ),
        Suggestion(
          title: '学习系统设计',
          description: '提升架构设计能力，为高级岗位做准备',
        ),
      ],
    );
  }
}

class MatchData {
  final int totalScore;
  final int hardSkillsScore;
  final int softSkillsScore;
  final int experienceScore;
  final int potentialScore;
  final Map<String, SkillComparison> softSkillsComparison;
  final List<AnalysisPoint> analysisPoints;
  final List<Suggestion> suggestions;

  MatchData({
    required this.totalScore,
    required this.hardSkillsScore,
    required this.softSkillsScore,
    required this.experienceScore,
    required this.potentialScore,
    required this.softSkillsComparison,
    required this.analysisPoints,
    required this.suggestions,
  });
}

class SkillComparison {
  final double userScore;
  final double jobScore;

  SkillComparison({required this.userScore, required this.jobScore});
}

class AnalysisPoint {
  final String text;
  final bool isPositive;

  AnalysisPoint({required this.text, required this.isPositive});
}

class Suggestion {
  final String title;
  final String description;

  Suggestion({required this.title, required this.description});
}
