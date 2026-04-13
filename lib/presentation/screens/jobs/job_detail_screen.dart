import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';

/// 岗位详情页
class JobDetailScreen extends StatelessWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    final job = _getJobData(jobId);

    return Scaffold(
      appBar: AppBar(
        title: Text(job['title'] as String),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoCard(context, job),
            const SizedBox(height: 20),
            _buildSectionCard(context, '职位描述', Text(job['description'] as String)),
            const SizedBox(height: 20),
            _buildRequirementsCard(context, job['requirements'] as List<String>),
            const SizedBox(height: 20),
            _buildSkillsFrequencyCard(context, job['skills'] as List<Map<String, dynamic>>),
            const SizedBox(height: 20),
            _buildSoftSkillsCard(context, job['softSkills'] as Map<String, dynamic>),
            const SizedBox(height: 20),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getJobData(String id) {
    return {
      'id': id,
      'title': '前端工程师',
      'company': '字节跳动',
      'salary': '25-45K',
      'location': '北京',
      'experience': '3-5年',
      'education': '本科及以上',
      'description': '负责公司核心产品的前端开发工作，使用React/Vue等现代前端框架，参与产品需求讨论和技术方案设计。',
      'requirements': [
        '精通React/Vue等主流前端框架',
        '熟悉TypeScript/ES6+',
        '具备良好的代码规范和编程习惯',
        '有大型项目开发经验者优先',
      ],
      'skills': [
        {'name': 'React', 'frequency': 85},
        {'name': 'JavaScript', 'frequency': 90},
        {'name': 'CSS/HTML', 'frequency': 95},
        {'name': 'TypeScript', 'frequency': 75},
        {'name': 'Vue', 'frequency': 70},
      ],
      'softSkills': {
        '沟通能力': 85,
        '学习能力': 90,
        '团队协作': 88,
        '问题解决': 82,
      },
    };
  }

  Widget _buildBasicInfoCard(BuildContext context, Map<String, dynamic> job) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.business, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['title'] as String,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job['company'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(context, const Icon(Icons.payment_outlined), '薪资', job['salary'] as String),
            const SizedBox(height: 12),
            _buildInfoRow(context, const Icon(Icons.location_on_outlined), '地点', job['location'] as String),
            const SizedBox(height: 12),
            _buildInfoRow(context, const Icon(Icons.work_outline), '经验要求', job['experience'] as String),
            const SizedBox(height: 12),
            _buildInfoRow(context, const Icon(Icons.school_outlined), '学历要求', job['education'] as String),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, Widget content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementsCard(BuildContext context, List<String> requirements) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '任职要求',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...requirements.map((req) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline,
                       size: 20,
                       color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      req,
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

  Widget _buildSkillsFrequencyCard(BuildContext context, List<Map<String, dynamic>> skills) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '技能要求',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...skills.map((skill) {
              final frequency = skill['frequency'] as int;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          skill['name'] as String,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '$frequency%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondaryLight,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: frequency / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
                        minHeight: 8,
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

  Widget _buildSoftSkillsCard(BuildContext context, Map<String, dynamic> softSkills) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '软能力权重',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...softSkills.entries.map((entry) {
              final name = entry.key;
              final value = (entry.value as int);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: value / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(
                          value >= 85 ? AppTheme.successColor :
                          value >= 70 ? AppTheme.primaryColor :
                          AppTheme.warningColor,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$value%',
                      style: Theme.of(context).textTheme.bodySmall,
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

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border),
            label: const Text('收藏'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () {
              context.push('/matching/process');
            },
            icon: const Icon(Icons.analytics_outlined),
            label: const Text('查看匹配分析'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, Icon icon, String label, String value) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
