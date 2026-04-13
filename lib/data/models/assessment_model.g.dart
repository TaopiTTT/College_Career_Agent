// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BasicInfoModel _$BasicInfoModelFromJson(Map<String, dynamic> json) =>
    BasicInfoModel(
      name: json['name'] as String?,
      gender: json['gender'] as String?,
      birthDate: json['birthDate'] == null
          ? null
          : DateTime.parse(json['birthDate'] as String),
      education: json['education'] as String?,
      major: json['major'] as String?,
      school: json['school'] as String?,
      graduationYear: (json['graduationYear'] as num?)?.toInt(),
      phone: json['phone'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$BasicInfoModelToJson(BasicInfoModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'gender': instance.gender,
      'birthDate': instance.birthDate?.toIso8601String(),
      'education': instance.education,
      'major': instance.major,
      'school': instance.school,
      'graduationYear': instance.graduationYear,
      'phone': instance.phone,
      'tags': instance.tags,
    };

AssessmentStateModel _$AssessmentStateModelFromJson(
        Map<String, dynamic> json) =>
    AssessmentStateModel(
      completedSteps: (json['completedSteps'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$AssessmentStepEnumMap, k), e as bool),
      ),
      currentStep:
          $enumDecodeNullable(_$AssessmentStepEnumMap, json['currentStep']),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AssessmentStateModelToJson(
        AssessmentStateModel instance) =>
    <String, dynamic>{
      'completedSteps': instance.completedSteps
          .map((k, e) => MapEntry(_$AssessmentStepEnumMap[k]!, e)),
      'currentStep': _$AssessmentStepEnumMap[instance.currentStep],
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$AssessmentStepEnumMap = {
  AssessmentStep.basicInfo: 'basicInfo',
  AssessmentStep.skills: 'skills',
  AssessmentStep.questionnaire: 'questionnaire',
  AssessmentStep.interview: 'interview',
  AssessmentStep.logic: 'logic',
  AssessmentStep.resume: 'resume',
};

UserProfileModel _$UserProfileModelFromJson(Map<String, dynamic> json) =>
    UserProfileModel(
      id: json['id'] as String?,
      basicInfo: json['basicInfo'] == null
          ? null
          : BasicInfoModel.fromJson(json['basicInfo'] as Map<String, dynamic>),
      skills: (json['skills'] as List<dynamic>?)
          ?.map((e) => SkillModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      softSkills: (json['softSkills'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      overallScore: (json['overallScore'] as num?)?.toDouble(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserProfileModelToJson(UserProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'basicInfo': instance.basicInfo,
      'skills': instance.skills,
      'softSkills': instance.softSkills,
      'overallScore': instance.overallScore,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

SkillModel _$SkillModelFromJson(Map<String, dynamic> json) => SkillModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      category: json['category'] as String?,
      proficiency: (json['proficiency'] as num?)?.toInt(),
      isCustom: json['isCustom'] as bool?,
    );

Map<String, dynamic> _$SkillModelToJson(SkillModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'proficiency': instance.proficiency,
      'isCustom': instance.isCustom,
    };
