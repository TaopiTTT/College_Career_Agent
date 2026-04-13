import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';

/// 岗位列表页
class JobListScreen extends ConsumerStatefulWidget {
  const JobListScreen({super.key});

  @override
  ConsumerState<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends ConsumerState<JobListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '全部';
  int _selectedTabIndex = 0;

  final List<String> _categories = [
    '全部',
    '技术研发',
    '产品设计',
    '运营',
    '市场',
  ];

  // 模拟岗位数据
  final List<Map<String, dynamic>> _jobs = [
    {
      'id': '1',
      'title': '前端工程师',
      'company': '字节跳动',
      'salary': '25-45K',
      'location': '北京',
      'category': '技术研发',
      'tags': ['React', 'Vue', 'TypeScript', '3-5年经验'],
      'match': 92,
    },
    {
      'id': '2',
      'title': '全栈工程师',
      'company': '阿里巴巴',
      'salary': '30-50K',
      'location': '杭州',
      'category': '技术研发',
      'tags': ['Java', 'Vue', 'MySQL', '3-5年经验'],
      'match': 88,
    },
    {
      'id': '3',
      'title': '产品经理',
      'company': '腾讯',
      'salary': '20-35K',
      'location': '深圳',
      'category': '产品设计',
      'tags': ['产品思维', '数据分析', '沟通能力', '2-4年经验'],
      'match': 85,
    },
    {
      'id': '4',
      'title': 'UI设计师',
      'company': '美团',
      'salary': '18-30K',
      'location': '北京',
      'category': '产品设计',
      'tags': ['Figma', 'Sketch', 'Photoshop', '2-4年经验'],
      'match': 80,
    },
    {
      'id': '5',
      'title': '运营专员',
      'company': '京东',
      'salary': '15-25K',
      'location': '北京',
      'category': '运营',
      'tags': ['数据分析', '文案策划', '活动执行', '1-3年经验'],
      'match': 75,
    },
  ];

  List<Map<String, dynamic>> get _filteredJobs {
    var jobs = _jobs;

    // 分类筛选
    if (_selectedCategory != '全部') {
      jobs = jobs.where((job) => job['category'] == _selectedCategory).toList();
    }

    // 搜索筛选
    if (_searchController.text.isNotEmpty) {
      final keyword = _searchController.text.toLowerCase();
      jobs = jobs.where((job) =>
        (job['title'] as String).toLowerCase().contains(keyword) ||
        (job['company'] as String).toLowerCase().contains(keyword)
      ).toList();
    }

    return jobs;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('岗位列表'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(),
          // 分类Tab
          _buildCategoryTabs(),
          // 岗位列表
          Expanded(
            child: _filteredJobs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredJobs.length,
                    itemBuilder: (context, index) {
                      return _buildJobCard(_filteredJobs[index]);
                    },
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
          hintText: '搜索岗位或公司',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    final match = job['match'] as int;
    final tags = job['tags'] as List<String>;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push('/jobs/${job['id']}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job['title'] as String,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getMatchColor(match).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$match%匹配',
                      style: TextStyle(
                        color: _getMatchColor(match),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.business_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    job['company'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.payment_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    job['salary'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) => Chip(
                  label: Text(tag),
                  labelStyle: const TextStyle(fontSize: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  backgroundColor: Colors.grey.shade200,
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            '暂无相关岗位',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }

  Color _getMatchColor(int match) {
    if (match >= 90) return AppTheme.successColor;
    if (match >= 80) return AppTheme.primaryColor;
    if (match >= 70) return AppTheme.warningColor;
    return Colors.grey;
  }
}
