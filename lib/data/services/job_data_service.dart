import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/job_model.dart';

/// 岗位数据服务
class JobDataService {
  static List<JobModel>? _cachedJobs;

  /// 加载所有岗位数据
  static Future<List<JobModel>> loadJobs() async {
    // 如果已缓存，直接返回
    if (_cachedJobs != null) {
      debugPrint('✅ 从缓存加载岗位数据: ${_cachedJobs!.length} 条');
      return _cachedJobs!;
    }

    try {
      debugPrint('🔄 开始加载岗位数据...');
      // 从assets加载JSON数据
      final jsonString = await rootBundle.loadString('assets/data/jobs.json');
      debugPrint('✅ JSON文件加载成功，大小: ${jsonString.length} 字符');

      final List<dynamic> jsonList = jsonDecode(jsonString);
      debugPrint('✅ JSON解析成功，共 ${jsonList.length} 条数据');

      // 转换为JobModel列表
      _cachedJobs = jsonList
          .map((json) => JobModel.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('✅ 岗位数据加载完成: ${_cachedJobs!.length} 条');
      return _cachedJobs!;
    } catch (e, stackTrace) {
      debugPrint('❌ 加载岗位数据失败: $e');
      debugPrint('❌ 堆栈跟踪: $stackTrace');
      return [];
    }
  }

  /// 根据关键词搜索岗位
  static Future<List<JobModel>> searchJobs(String keyword) async {
    final jobs = await loadJobs();

    if (keyword.isEmpty) {
      return jobs;
    }

    final lowerKeyword = keyword.toLowerCase();
    return jobs.where((job) {
      return job.jobName.toLowerCase().contains(lowerKeyword) ||
          job.companyName.toLowerCase().contains(lowerKeyword) ||
          job.location.toLowerCase().contains(lowerKeyword) ||
          job.industry.toLowerCase().contains(lowerKeyword) ||
          job.jobDetails.toLowerCase().contains(lowerKeyword);
    }).toList();
  }

  /// 获取所有行业类型
  static Future<List<String>> getIndustries() async {
    final jobs = await loadJobs();
    final industries = jobs.map((job) => job.industry).toSet().toList();
    industries.sort();
    return industries;
  }

  /// 根据行业筛选岗位
  static Future<List<JobModel>> filterByIndustry(String industry) async {
    final jobs = await loadJobs();
    return jobs.where((job) => job.industry.contains(industry)).toList();
  }

  /// 获取所有地址
  static Future<List<String>> getLocations() async {
    final jobs = await loadJobs();
    final locations = jobs.map((job) => job.location).toSet().toList();
    locations.sort();
    return locations;
  }

  /// 根据地址筛选岗位
  static Future<List<JobModel>> filterByLocation(String location) async {
    final jobs = await loadJobs();
    return jobs.where((job) => job.location.contains(location)).toList();
  }

  /// 根据岗位名称筛选
  static Future<List<JobModel>> filterByJobName(String jobName) async {
    final jobs = await loadJobs();
    return jobs.where((job) => job.jobName.contains(jobName)).toList();
  }

  /// 清除缓存
  static void clearCache() {
    _cachedJobs = null;
  }
}
