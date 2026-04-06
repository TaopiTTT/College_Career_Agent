import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/config/app_theme.dart';

/// 雷达图组件 - 用于展示软能力维度
class RadarChartWidget extends StatelessWidget {
  final Map<String, double> data;
  final String title;
  final Color? color;

  const RadarChartWidget({
    super.key,
    required this.data,
    this.title = '',
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    const maxValue = 100.0;
    final chartColor = color ?? AppTheme.primaryColor;

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
          height: 250,
          child: RadarChart(
            RadarChartData(
              dataSets: [
                RadarDataSet(
                  fillColor: chartColor.withOpacity(0.3),
                  borderColor: chartColor,
                  borderWidth: 2,
                  entryRadius: 3,
                  dataEntries: data.entries
                      .map((entry) => RadarEntry(value: entry.value / maxValue))
                      .toList(),
                ),
              ],
              radarBackgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              radarBorderData: const BorderSide(
                color: Colors.transparent,
              ),
              tickBorderData: const BorderSide(
                color: Colors.transparent,
              ),
              gridBorderData: BorderSide(
                color: AppTheme.textSecondaryLight.withOpacity(0.3),
                width: 1,
              ),
              tickCount: 5,
              ticksTextStyle: const TextStyle(
                color: AppTheme.textSecondaryLight,
                fontSize: 10,
              ),
              getTitle: (index, angle) {
                final keys = data.keys.toList();
                if (index >= keys.length) {
                  return const RadarChartTitle(text: '');
                }
                return RadarChartTitle(
                  text: keys[index],
                );
              },
            ),
            swapAnimationDuration: const Duration(milliseconds: 400),
            swapAnimationCurve: Curves.easeInOut,
          ),
        ),
      ],
    );
  }
}

/// 双雷达图对比组件
class ComparisonRadarChartWidget extends StatelessWidget {
  final Map<String, double> studentData;
  final Map<String, double> jobData;
  final String title;

  const ComparisonRadarChartWidget({
    super.key,
    required this.studentData,
    required this.jobData,
    this.title = '能力对比',
  });

  @override
  Widget build(BuildContext context) {
    const maxValue = 100.0;

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
          height: 280,
          child: RadarChart(
            RadarChartData(
              dataSets: [
                // 学生数据
                RadarDataSet(
                  fillColor: AppTheme.primaryColor.withOpacity(0.3),
                  borderColor: AppTheme.primaryColor,
                  borderWidth: 2,
                  entryRadius: 3,
                  dataEntries: studentData.entries
                      .map((e) => RadarEntry(value: e.value / maxValue))
                      .toList(),
                ),
                // 岗位数据
                RadarDataSet(
                  fillColor: AppTheme.warningColor.withOpacity(0.3),
                  borderColor: AppTheme.warningColor,
                  borderWidth: 2,
                  entryRadius: 3,
                  dataEntries: jobData.entries
                      .map((e) => RadarEntry(value: e.value / maxValue))
                      .toList(),
                ),
              ],
              radarBackgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              radarBorderData: const BorderSide(
                color: Colors.transparent,
              ),
              tickBorderData: const BorderSide(
                color: Colors.transparent,
              ),
              gridBorderData: BorderSide(
                color: AppTheme.textSecondaryLight.withOpacity(0.3),
                width: 1,
              ),
              tickCount: 5,
              ticksTextStyle: const TextStyle(
                color: AppTheme.textSecondaryLight,
                fontSize: 10,
              ),
              getTitle: (index, angle) {
                final keys = studentData.keys.toList();
                if (index >= keys.length) {
                  return const RadarChartTitle(text: '');
                }
                return RadarChartTitle(
                  text: keys[index],
                );
              },
            ),
            swapAnimationDuration: const Duration(milliseconds: 400),
            swapAnimationCurve: Curves.easeInOut,
          ),
        ),
      ],
    );
  }
}
