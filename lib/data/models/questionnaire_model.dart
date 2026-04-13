import 'package:json_annotation/json_annotation.dart';

part 'questionnaire_model.g.dart';

/// 问卷问题模型
@JsonSerializable()
class QuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final String? category; // 问题分类：领导力、沟通能力、团队协作等
  final int? weight; // 权重，用于计算分数

  QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    this.category,
    this.weight,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionModelToJson(this);
}

/// 问卷答案模型
@JsonSerializable()
class QuestionAnswer {
  final String questionId;
  final int answerIndex; // 选项索引（0-3）
  final int? score; // 分数（可选，如果没有直接给出分数会根据选项计算）

  QuestionAnswer({
    required this.questionId,
    required this.answerIndex,
    this.score,
  });

  factory QuestionAnswer.fromJson(Map<String, dynamic> json) =>
      _$QuestionAnswerFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionAnswerToJson(this);
}

/// 问卷结果模型
@JsonSerializable()
class QuestionnaireResult {
  final Map<String, int> categoryScores; // 各分类得分
  final int totalScore; // 总分
  final Map<String, dynamic> details; // 详细信息

  QuestionnaireResult({
    required this.categoryScores,
    required this.totalScore,
    required this.details,
  });

  factory QuestionnaireResult.fromJson(Map<String, dynamic> json) =>
      _$QuestionnaireResultFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionnaireResultToJson(this);
}
