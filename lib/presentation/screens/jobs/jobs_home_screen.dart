import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';

/// 了解岗位主页
class JobsHomeScreen extends ConsumerStatefulWidget {
  const JobsHomeScreen({super.key});

  @override
  ConsumerState<JobsHomeScreen> createState() => _JobsHomeScreenState();
}

class _JobsHomeScreenState extends ConsumerState<JobsHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('了解岗位'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // 显示筛选器
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(),
          // 分类标签
          _buildCategoryTabs(),
          // 岗位列表
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildJobList('后端开发'),
                _buildJobList('前端开发'),
                _buildJobList('测试工程'),
                _buildJobList('数据分析'),
                _buildJobList('产品经理'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索岗位名称或技能',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabs: const [
        Tab(text: '后端开发'),
        Tab(text: '前端开发'),
        Tab(text: '测试工程'),
        Tab(text: '数据分析'),
        Tab(text: '产品经理'),
      ],
      labelColor: AppTheme.primaryColor,
      unselectedLabelColor: AppTheme.textSecondaryLight,
      indicatorColor: AppTheme.primaryColor,
    );
  }

  Widget _buildJobList(String category) {
    // 模拟岗位数据
    final jobs = [
      {
        'name': '后端开发工程师',
        'sample_count': 850,
        'salary': '8K-30K',
        'core_skills': ['Java', 'Spring Boot', 'MySQL', 'Redis'],
        'match_score': 72,
        'market_demand': 'high',
      },
      {
        'name': 'Go后端开发',
        'sample_count': 420,
        'salary': '12K-35K',
        'core_skills': ['Go', 'Microservices', 'Docker', 'Kubernetes'],
        'match_score': 65,
        'market_demand': 'high',
      },
      {
        'name': 'Java开发工程师',
        'sample_count': 1200,
        'salary': '8K-25K',
        'core_skills': ['Java', 'Spring', 'MyBatis', 'MySQL'],
        'match_score': 68,
        'market_demand': 'medium',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return _buildJobCard(job);
      },
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    final matchScore = job['match_score'] as int;
    final demand = job['market_demand'] as String;
    final demandColor = demand == 'high'
        ? AppTheme.successColor
        : demand == 'medium'
            ? AppTheme.warningColor
            : AppTheme.textSecondaryLight;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          context.push('/jobs/${job['name']}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题和匹配分
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job['name'] as String,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (matchScore > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getMatchColor(matchScore).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '匹配度',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getMatchColor(matchScore),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$matchScore%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _getMatchColor(matchScore),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // 薪资和市场需求
              Row(
                children: [
                  const Icon(
                    Icons.payments_outlined,
                    size: 18,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    job['salary'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.trending_up,
                    size: 18,
                    color: demandColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    demand == 'high' ? '需求旺盛' : '需求一般',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: demandColor,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    '样本量 ${job['sample_count']}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 核心技能标签
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (job['core_skills'] as List<String>)
                    .map((skill) => Chip(
                          label: Text(skill),
                          backgroundColor:
                              AppTheme.primaryColor.withOpacity(0.1),
                          labelStyle: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMatchColor(int score) {
    if (score >= 80) return AppTheme.successColor;
    if (score >= 60) return AppTheme.warningColor;
    return AppTheme.textSecondaryLight;
  }
}
