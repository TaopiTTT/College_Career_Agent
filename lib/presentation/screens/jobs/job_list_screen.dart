import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../data/models/job_model.dart';
import '../../../data/services/job_data_service.dart';

/// 岗位列表页
class JobListScreen extends ConsumerStatefulWidget {
  const JobListScreen({super.key});

  @override
  ConsumerState<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends ConsumerState<JobListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedIndustry = '全部';
  String _selectedLocation = '全部';

  List<String> _industries = ['全部'];
  List<String> _locations = ['全部'];
  List<JobModel> _allJobs = [];
  List<JobModel> _filteredJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJobData();
  }

  /// 加载岗位数据
  Future<void> _loadJobData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('🔄 JobListScreen: 开始加载岗位数据...');
      // 加载所有岗位
      _allJobs = await JobDataService.loadJobs();
      debugPrint('✅ JobListScreen: 加载了 ${_allJobs.length} 个岗位');

      // 获取所有行业和地址
      final industries = await JobDataService.getIndustries();
      final locations = await JobDataService.getLocations();
      debugPrint('✅ JobListScreen: 行业数量: ${industries.length}, 地址数量: ${locations.length}');

      setState(() {
        _industries = ['全部', ...industries];
        _locations = ['全部', ...locations];
        _filteredJobs = _allJobs;
        _isLoading = false;
      });
      debugPrint('✅ JobListScreen: 数据加载完成');
    } catch (e) {
      debugPrint('❌ JobListScreen: 加载数据失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 过滤岗位
  void _filterJobs() {
    setState(() {
      _filteredJobs = _allJobs;

      // 行业筛选
      if (_selectedIndustry != '全部') {
        _filteredJobs = _filteredJobs
            .where((job) => job.industry.contains(_selectedIndustry))
            .toList();
      }

      // 地址筛选
      if (_selectedLocation != '全部') {
        _filteredJobs = _filteredJobs
            .where((job) => job.location.contains(_selectedLocation))
            .toList();
      }

      // 搜索筛选
      if (_searchController.text.isNotEmpty) {
        final keyword = _searchController.text.toLowerCase();
        _filteredJobs = _filteredJobs.where((job) {
          return job.jobName.toLowerCase().contains(keyword) ||
              job.companyName.toLowerCase().contains(keyword) ||
              job.location.toLowerCase().contains(keyword);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('了解岗位'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(),
          // 筛选器
          _buildFilters(),
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
          hintText: '搜索岗位名称、公司或地点',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _filterJobs();
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
          _filterJobs();
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 行业筛选
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedIndustry,
              decoration: InputDecoration(
                labelText: '行业',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: _industries.take(10).map((industry) {
                return DropdownMenuItem(
                  value: industry,
                  child: Text(
                    industry,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedIndustry = value ?? '全部';
                  _filterJobs();
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          // 地点筛选
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedLocation,
              decoration: InputDecoration(
                labelText: '地点',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: _locations.take(10).map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(
                    location,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLocation = value ?? '全部';
                  _filterJobs();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(JobModel job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push('/jobs/detail', extra: job),
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
                      job.jobName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      job.updateDate,
                      style: TextStyle(
                        color: Colors.blue.shade700,
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
                  Expanded(
                    child: Text(
                      job.companyName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.payment_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    job.salaryRange,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job.location,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.business_center_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job.industry,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
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
          const SizedBox(height: 8),
          Text(
            '尝试调整搜索条件',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ],
      ),
    );
  }
}
