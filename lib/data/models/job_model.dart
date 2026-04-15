import 'package:json_annotation/json_annotation.dart';

part 'job_model.g.dart';

/// 岗位信息模型
@JsonSerializable()
class JobModel {
  final String jobName; // 岗位名称
  final String location; // 地址
  final String salaryRange; // 薪资范围
  final String companyName; // 公司名称
  final String industry; // 所属行业
  final String companySize; // 公司规模
  final String companyType; // 公司类型
  final String jobCode; // 岗位编码
  final String jobDetails; // 岗位详情
  final String updateDate; // 更新日期
  final String companyDetails; // 公司详情
  final String sourceUrl; // 岗位来源地址

  JobModel({
    required this.jobName,
    required this.location,
    required this.salaryRange,
    required this.companyName,
    required this.industry,
    required this.companySize,
    required this.companyType,
    required this.jobCode,
    required this.jobDetails,
    required this.updateDate,
    required this.companyDetails,
    required this.sourceUrl,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) =>
      _$JobModelFromJson(json);

  Map<String, dynamic> toJson() => _$JobModelToJson(this);

  JobModel copyWith({
    String? jobName,
    String? location,
    String? salaryRange,
    String? companyName,
    String? industry,
    String? companySize,
    String? companyType,
    String? jobCode,
    String? jobDetails,
    String? updateDate,
    String? companyDetails,
    String? sourceUrl,
  }) {
    return JobModel(
      jobName: jobName ?? this.jobName,
      location: location ?? this.location,
      salaryRange: salaryRange ?? this.salaryRange,
      companyName: companyName ?? this.companyName,
      industry: industry ?? this.industry,
      companySize: companySize ?? this.companySize,
      companyType: companyType ?? this.companyType,
      jobCode: jobCode ?? this.jobCode,
      jobDetails: jobDetails ?? this.jobDetails,
      updateDate: updateDate ?? this.updateDate,
      companyDetails: companyDetails ?? this.companyDetails,
      sourceUrl: sourceUrl ?? this.sourceUrl,
    );
  }
}
