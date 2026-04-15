import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/assessment_model.dart';

/// 本地存储服务
class LocalStorageService {
  static const String _basicInfoKey = 'basic_info';
  static const String _assessmentStateKey = 'assessment_state';
  static const String _userProfileKey = 'user_profile';
  static const String _questionnaireAnswersKey = 'questionnaire_answers';
  static const String _skillsKey = 'user_skills';
  static const String _userCredentialsKey = 'user_credentials'; // 新增：用户登录凭据

  /// 保存用户登录凭据（记住密码功能）
  static Future<void> saveUserCredentials({
    required String email,
    required String password,
    bool rememberPassword = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = {
        'email': email,
        'password': rememberPassword ? password : '',
        'rememberPassword': rememberPassword,
        'lastLoginTime': DateTime.now().toIso8601String(),
      };
      final jsonString = jsonEncode(credentials);
      await prefs.setString(_userCredentialsKey, jsonString);
      debugPrint('✅ 用户登录凭据已保存');
    } catch (e) {
      debugPrint('❌ 保存用户登录凭据失败: $e');
    }
  }

  /// 获取用户登录凭据
  static Future<Map<String, dynamic>?> getUserCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_userCredentialsKey);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('❌ 读取用户登录凭据失败: $e');
    }
    return null;
  }

  /// 清除用户登录凭据
  static Future<void> clearUserCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userCredentialsKey);
      debugPrint('✅ 用户登录凭据已清除');
    } catch (e) {
      debugPrint('❌ 清除用户登录凭据失败: $e');
    }
  }

  /// 保存基础信息
  static Future<void> saveBasicInfo(BasicInfoModel basicInfo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(basicInfo.toJson());
      await prefs.setString(_basicInfoKey, jsonString);
      debugPrint('✅ 基础信息已保存到本地');
    } catch (e) {
      debugPrint('❌ 保存基础信息失败: $e');
    }
  }

  /// 获取基础信息
  static Future<BasicInfoModel?> getBasicInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_basicInfoKey);
      if (jsonString != null) {
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        return BasicInfoModel.fromJson(jsonMap);
      }
    } catch (e) {
      debugPrint('❌ 读取基础信息失败: $e');
    }
    return null;
  }

  /// 保存技能列表
  static Future<void> saveSkills(List<SkillModel> skills) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(skills.map((s) => s.toJson()).toList());
      await prefs.setString(_skillsKey, jsonString);
      debugPrint('✅ 技能列表已保存到本地');
    } catch (e) {
      debugPrint('❌ 保存技能列表失败: $e');
    }
  }

  /// 获取技能列表
  static Future<List<SkillModel>?> getSkills() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_skillsKey);
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List;
        return jsonList
            .map((json) => SkillModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('❌ 读取技能列表失败: $e');
    }
    return null;
  }

  /// 保存评估状态
  static Future<void> saveAssessmentState(AssessmentStateModel state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // 将Map转换为可序列化的格式
      final serializedCompletedSteps = <String, bool>{};
      state.completedSteps.forEach((key, value) {
        serializedCompletedSteps[key.name] = value;
      });

      final data = {
        'completedSteps': serializedCompletedSteps,
        'currentStep': state.currentStep?.name,
        'updatedAt': state.updatedAt?.toIso8601String(),
      };

      final jsonString = jsonEncode(data);
      await prefs.setString(_assessmentStateKey, jsonString);
      debugPrint('✅ 评估状态已保存到本地');
    } catch (e) {
      debugPrint('❌ 保存评估状态失败: $e');
    }
  }

  /// 获取评估状态
  static Future<AssessmentStateModel?> getAssessmentState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_assessmentStateKey);
      if (jsonString != null) {
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

        // 反序列化completedSteps
        final completedSteps = <AssessmentStep, bool>{};
        final serializedSteps =
            jsonMap['completedSteps'] as Map<String, dynamic>;
        serializedSteps.forEach((key, value) {
          final step = AssessmentStep.values.firstWhere(
            (e) => e.name == key,
            orElse: () => AssessmentStep.basicInfo,
          );
          completedSteps[step] = value as bool;
        });

        // 反序列化currentStep
        AssessmentStep? currentStep;
        if (jsonMap['currentStep'] != null) {
          currentStep = AssessmentStep.values.firstWhere(
            (e) => e.name == jsonMap['currentStep'],
            orElse: () => AssessmentStep.basicInfo,
          );
        }

        // 反序列化updatedAt
        DateTime? updatedAt;
        if (jsonMap['updatedAt'] != null) {
          updatedAt = DateTime.parse(jsonMap['updatedAt'] as String);
        }

        return AssessmentStateModel(
          completedSteps: completedSteps,
          currentStep: currentStep,
          updatedAt: updatedAt,
        );
      }
    } catch (e) {
      debugPrint('❌ 读取评估状态失败: $e');
    }
    return null;
  }

  /// 保存用户画像
  static Future<void> saveUserProfile(UserProfileModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(profile.toJson());
      await prefs.setString(_userProfileKey, jsonString);
      debugPrint('✅ 用户画像已保存到本地');
    } catch (e) {
      debugPrint('❌ 保存用户画像失败: $e');
    }
  }

  /// 获取用户画像
  static Future<UserProfileModel?> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_userProfileKey);
      if (jsonString != null) {
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        return UserProfileModel.fromJson(jsonMap);
      }
    } catch (e) {
      debugPrint('❌ 读取用户画像失败: $e');
    }
    return null;
  }

  /// 保存问卷答案
  static Future<void> saveQuestionnaireAnswers(
      Map<String, dynamic> answers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(answers);
      await prefs.setString(_questionnaireAnswersKey, jsonString);
      debugPrint('✅ 问卷答案已保存到本地');
    } catch (e) {
      debugPrint('❌ 保存问卷答案失败: $e');
    }
  }

  /// 获取问卷答案
  static Future<Map<String, dynamic>?> getQuestionnaireAnswers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_questionnaireAnswersKey);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('❌ 读取问卷答案失败: $e');
    }
    return null;
  }

  /// 清除所有数据
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_basicInfoKey);
      await prefs.remove(_assessmentStateKey);
      await prefs.remove(_userProfileKey);
      await prefs.remove(_questionnaireAnswersKey);
      await prefs.remove(_skillsKey);
      await prefs.remove(_userCredentialsKey);
      debugPrint('✅ 所有本地数据已清除');
    } catch (e) {
      debugPrint('❌ 清除数据失败: $e');
    }
  }

  /// 清除特定键的数据
  static Future<void> clearKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      debugPrint('✅ 数据已清除: $key');
    } catch (e) {
      debugPrint('❌ 清除数据失败: $e');
    }
  }
}
