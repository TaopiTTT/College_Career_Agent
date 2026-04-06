import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/config/app_theme.dart';

/// 环形进度条组件
class CircularProgressChartWidget extends StatelessWidget {
  final double progress;
  final String label;
  final Color? color;
  final double size;

  const CircularProgressChartWidget({
    super.key,
    required this.progress,
    required this.label,
    this.color,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final chartColor = color ?? AppTheme.primaryColor;
    final progressValue = (progress / 100).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: size * 0.4,
                startDegreeOffset: 270,
                sections: [
                  PieChartSectionData(
                    value: progressValue * 100,
                    color: chartColor,
                    radius: size * 0.4,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: (1 - progressValue) * 100,
                    color: AppTheme.textSecondaryLight.withOpacity(0.2),
                    radius: size * 0.4,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${progress.toInt()}%',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: chartColor,
                      fontWeight: FontWeight.bold,
                      fontSize: size * 0.15,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                      fontSize: size * 0.08,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 线性进度条组件
class LinearProgressChartWidget extends StatelessWidget {
  final double progress;
  final String label;
  final Color? color;
  final double height;
  final String? valueLabel;

  const LinearProgressChartWidget({
    super.key,
    required this.progress,
    required this.label,
    this.color,
    this.height = 8,
    this.valueLabel,
  });

  @override
  Widget build(BuildContext context) {
    final chartColor = color ?? AppTheme.primaryColor;
    final progressValue = (progress / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (valueLabel != null)
              Text(
                valueLabel!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: chartColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: progressValue,
            backgroundColor: AppTheme.textSecondaryLight.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(chartColor),
            minHeight: height,
          ),
        ),
      ],
    );
  }
}

/// 柱状图组件
class BarChartWidget extends StatelessWidget {
  final Map<String, double> data;
  final String title;
  final Color? color;

  const BarChartWidget({
    super.key,
    required this.data,
    this.title = '',
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chartColor = color ?? AppTheme.primaryColor;
    final maxValue =
        data.values.reduce((a, b) => a > b ? a : b).ceilToDouble();

    return Column(
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxValue * 1.2,
              minY: 0,
              barTouchData: BarTouchData(
                enabled: true,
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      final keys = data.keys.toList();
                      if (index < 0 || index >= keys.length) {
                        return const Text('');
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          keys[index],
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondaryLight,
                          ),
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondaryLight,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppTheme.textSecondaryLight.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(
                show: false,
              ),
              barGroups: data.entries.map((entry) {
                final index = data.keys.toList().indexOf(entry.key);
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value,
                      color: chartColor,
                      width: 16,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

/// 技能匹配柱状图(带缺口标记)
class SkillMatchBarChartWidget extends StatelessWidget {
  final Map<String, SkillMatchData> data;
  final String title;

  const SkillMatchBarChartWidget({
    super.key,
    required this.data,
    this.title = '技能匹配度',
  });

  @override
  Widget build(BuildContext context) {
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => a.value.matchScore.compareTo(b.value.matchScore));

    return Column(
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedEntries.length,
          itemBuilder: (context, index) {
            final entry = sortedEntries[index];
            return _buildSkillBar(context, entry.key, entry.value);
          },
        ),
      ],
    );
  }

  Widget _buildSkillBar(
    BuildContext context,
    String skillName,
    SkillMatchData data,
  ) {
    final isGap = data.isGap;
    final barColor = isGap ? AppTheme.errorColor : AppTheme.primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  skillName,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (data.matchScore > 0)
                Text(
                  '${data.matchScore}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: barColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: data.matchScore / 100,
              backgroundColor: AppTheme.textSecondaryLight.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(barColor),
              minHeight: 8,
            ),
          ),
          if (data.description != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                data.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                      fontSize: 10,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

class SkillMatchData {
  final int matchScore;
  final bool isGap;
  final String? description;

  SkillMatchData({
    required this.matchScore,
    required this.isGap,
    this.description,
  });
}
