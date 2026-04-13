import 'package:json_annotation/json_annotation.dart';

part 'assessment_model.g.dart';

/// 基础信息模型
@JsonSerializable()
class BasicInfoModel {
  final String? name;
  final String? gender; // male/female/other
  final DateTime? birthDate;
  final String? education; // 本科/硕士/博士/大专/高中
  final String? major;
  final String? school;
  final int? graduationYear;
  final String? phone;
  final List<String>? tags;

  BasicInfoModel({
    this.name,
    this.gender,
    this.birthDate,
    this.education,
    this.major,
    this.school,
    this.graduationYear,
    this.phone,
    this.tags,
  });

  factory BasicInfoModel.fromJson(Map<String, dynamic> json) =>
      _$BasicInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$BasicInfoModelToJson(this);

  BasicInfoModel copyWith({
    String? name,
    String? gender,
    DateTime? birthDate,
    String? education,
    String? major,
    String? school,
    int? graduationYear,
    String? phone,
    List<String>? tags,
  }) {
    return BasicInfoModel(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      education: education ?? this.education,
      major: major ?? this.major,
      school: school ?? this.school,
      graduationYear: graduationYear ?? this.graduationYear,
      phone: phone ?? this.phone,
      tags: tags ?? this.tags,
    );
  }
}

/// 评估步骤状态
enum AssessmentStep {
  basicInfo, // 基础信息
  skills, // 技能自评
  questionnaire, // 软能力问卷
  interview, // AI面试
  logic, // 逻辑探针
  resume, // 简历上传
}

/// 评估状态模型
@JsonSerializable()
class AssessmentStateModel {
  final Map<AssessmentStep, bool> completedSteps;
  final AssessmentStep? currentStep;
  final DateTime? updatedAt;

  AssessmentStateModel({
    required this.completedSteps,
    this.currentStep,
    this.updatedAt,
  });

  factory AssessmentStateModel.fromJson(Map<String, dynamic> json) =>
      _$AssessmentStateModelFromJson(json);

  Map<String, dynamic> toJson() => _$AssessmentStateModelToJson(this);

  double get progress {
    if (completedSteps.isEmpty) return 0.0;
    final completedCount = completedSteps.values.where((v) => v).length;
    return completedCount / completedSteps.length;
  }

  AssessmentStateModel copyWith({
    Map<AssessmentStep, bool>? completedSteps,
    AssessmentStep? currentStep,
    DateTime? updatedAt,
  }) {
    return AssessmentStateModel(
      completedSteps: completedSteps ?? this.completedSteps,
      currentStep: currentStep ?? this.currentStep,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 能力画像模型
@JsonSerializable()
class UserProfileModel {
  final String? id;
  final BasicInfoModel? basicInfo;
  final List<SkillModel>? skills;
  final Map<String, double>? softSkills; // 软技能评分
  final double? overallScore;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfileModel({
    this.id,
    this.basicInfo,
    this.skills,
    this.softSkills,
    this.overallScore,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);

  UserProfileModel copyWith({
    String? id,
    BasicInfoModel? basicInfo,
    List<SkillModel>? skills,
    Map<String, double>? softSkills,
    double? overallScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      basicInfo: basicInfo ?? this.basicInfo,
      skills: skills ?? this.skills,
      softSkills: softSkills ?? this.softSkills,
      overallScore: overallScore ?? this.overallScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 技能模型
@JsonSerializable()
class SkillModel {
  final String? id;
  final String? name;
  final String? category;
  final int? proficiency; // 1-5
  final bool? isCustom;

  SkillModel({
    this.id,
    this.name,
    this.category,
    this.proficiency,
    this.isCustom,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) =>
      _$SkillModelFromJson(json);

  Map<String, dynamic> toJson() => _$SkillModelToJson(this);

  SkillModel copyWith({
    String? id,
    String? name,
    String? category,
    int? proficiency,
    bool? isCustom,
  }) {
    return SkillModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      proficiency: proficiency ?? this.proficiency,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}
