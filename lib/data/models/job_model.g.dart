// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobModel _$JobModelFromJson(Map<String, dynamic> json) => JobModel(
      jobName: json['jobName'] as String,
      location: json['location'] as String,
      salaryRange: json['salaryRange'] as String,
      companyName: json['companyName'] as String,
      industry: json['industry'] as String,
      companySize: json['companySize'] as String,
      companyType: json['companyType'] as String,
      jobCode: json['jobCode'] as String,
      jobDetails: json['jobDetails'] as String,
      updateDate: json['updateDate'] as String,
      companyDetails: json['companyDetails'] as String,
      sourceUrl: json['sourceUrl'] as String,
    );

Map<String, dynamic> _$JobModelToJson(JobModel instance) => <String, dynamic>{
      'jobName': instance.jobName,
      'location': instance.location,
      'salaryRange': instance.salaryRange,
      'companyName': instance.companyName,
      'industry': instance.industry,
      'companySize': instance.companySize,
      'companyType': instance.companyType,
      'jobCode': instance.jobCode,
      'jobDetails': instance.jobDetails,
      'updateDate': instance.updateDate,
      'companyDetails': instance.companyDetails,
      'sourceUrl': instance.sourceUrl,
    };
