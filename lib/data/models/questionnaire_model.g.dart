// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'questionnaire_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionModel _$QuestionModelFromJson(Map<String, dynamic> json) =>
    QuestionModel(
      id: json['id'] as String,
      question: json['question'] as String,
      options:
          (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      category: json['category'] as String?,
      weight: (json['weight'] as num?)?.toInt(),
    );

Map<String, dynamic> _$QuestionModelToJson(QuestionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'options': instance.options,
      'category': instance.category,
      'weight': instance.weight,
    };

QuestionAnswer _$QuestionAnswerFromJson(Map<String, dynamic> json) =>
    QuestionAnswer(
      questionId: json['questionId'] as String,
      answerIndex: (json['answerIndex'] as num).toInt(),
      score: (json['score'] as num?)?.toInt(),
    );

Map<String, dynamic> _$QuestionAnswerToJson(QuestionAnswer instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'answerIndex': instance.answerIndex,
      'score': instance.score,
    };

QuestionnaireResult _$QuestionnaireResultFromJson(Map<String, dynamic> json) =>
    QuestionnaireResult(
      categoryScores: Map<String, int>.from(json['categoryScores'] as Map),
      totalScore: (json['totalScore'] as num).toInt(),
      details: json['details'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$QuestionnaireResultToJson(
        QuestionnaireResult instance) =>
    <String, dynamic>{
      'categoryScores': instance.categoryScores,
      'totalScore': instance.totalScore,
      'details': instance.details,
    };
