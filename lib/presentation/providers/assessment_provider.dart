import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/assessment_model.dart';
import '../../core/storage/local_storage_service.dart';

/// 评估状态Provider
class AssessmentNotifier extends StateNotifier<AssessmentStateModel> {
  AssessmentNotifier() : super(_initialState()) {
    _loadSavedState();
  }

  static AssessmentStateModel _initialState() {
    return AssessmentStateModel(
      completedSteps: {
        AssessmentStep.basicInfo: false,
        AssessmentStep.skills: false,
        AssessmentStep.questionnaire: false,
        AssessmentStep.interview: false,
        AssessmentStep.logic: false,
        AssessmentStep.resume: false,
      },
      currentStep: AssessmentStep.basicInfo,
      updatedAt: DateTime.now(),
    );
  }

  /// 加载保存的评估状态
  Future<void> _loadSavedState() async {
    try {
      final savedState = await LocalStorageService.getAssessmentState();
      if (savedState != null) {
        state = savedState;
      }
    } catch (e) {
      // 加载失败，使用默认状态
      debugPrint('加载评估状态失败: $e');
    }
  }

  /// 标记步骤为完成
  void completeStep(AssessmentStep step) {
    final newCompletedSteps = Map<AssessmentStep, bool>.from(state.completedSteps);
    newCompletedSteps[step] = true;

    // 找到下一个未完成的步骤
    AssessmentStep? nextStep;
    for (final s in AssessmentStep.values) {
      if (!newCompletedSteps[s]!) {
        nextStep = s;
        break;
      }
    }

    state = state.copyWith(
      completedSteps: newCompletedSteps,
      currentStep: nextStep,
      updatedAt: DateTime.now(),
    );
    // 保存到本地存储
    LocalStorageService.saveAssessmentState(state);
  }

  /// 设置当前步骤
  void setCurrentStep(AssessmentStep step) {
    state = state.copyWith(
      currentStep: step,
      updatedAt: DateTime.now(),
    );
    // 保存到本地存储
    LocalStorageService.saveAssessmentState(state);
  }

  /// 重置评估状态
  void reset() {
    state = _initialState();
    // 保存到本地存储
    LocalStorageService.saveAssessmentState(state);
  }

  /// 检查步骤是否已完成
  bool isStepCompleted(AssessmentStep step) {
    return state.completedSteps[step] ?? false;
  }

  /// 检查步骤是否解锁（上一步已完成）
  bool isStepUnlocked(AssessmentStep step) {
    final stepIndex = AssessmentStep.values.indexOf(step);
    if (stepIndex == 0) return true; // 第一步总是解锁的

    // 特殊处理：问卷（index 2）可以在基础信息完成后解锁
    if (step == AssessmentStep.questionnaire) {
      final basicInfoCompleted = state.completedSteps[AssessmentStep.basicInfo] ?? false;
      return basicInfoCompleted;
    }

    final previousStep = AssessmentStep.values[stepIndex - 1];
    return state.completedSteps[previousStep] ?? false;
  }
}

/// 评估状态Provider
final assessmentNotifierProvider =
    StateNotifierProvider<AssessmentNotifier, AssessmentStateModel>((ref) {
  return AssessmentNotifier();
});

/// 用户画像Provider
class UserProfileNotifier extends StateNotifier<UserProfileModel?> {
  UserProfileNotifier() : super(null) {
    _loadSavedProfile();
  }

  /// 加载保存的用户画像
  Future<void> _loadSavedProfile() async {
    try {
      // 先尝试加载完整的用户画像
      var savedProfile = await LocalStorageService.getUserProfile();
      if (savedProfile != null) {
        state = savedProfile;
      } else {
        // 如果没有完整的用户画像，尝试加载基础信息
        final basicInfo = await LocalStorageService.getBasicInfo();
        if (basicInfo != null) {
          state = UserProfileModel(
            basicInfo: basicInfo,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          // 保存完整的用户画像
          LocalStorageService.saveUserProfile(state!);
        }
      }
    } catch (e) {
      debugPrint('加载用户画像失败: $e');
    }
  }

  /// 更新基础信息
  void updateBasicInfo(BasicInfoModel basicInfo) {
    state = (state ?? UserProfileModel()).copyWith(
      basicInfo: basicInfo,
      updatedAt: DateTime.now(),
    );
    // 保存到本地存储（同时保存用户画像和基础信息）
    if (state != null) {
      LocalStorageService.saveUserProfile(state!);
      LocalStorageService.saveBasicInfo(basicInfo);
    }
  }

  /// 更新技能列表
  void updateSkills(List<SkillModel> skills) {
    state = (state ?? UserProfileModel()).copyWith(
      skills: skills,
      updatedAt: DateTime.now(),
    );
    // 保存到本地存储
    if (state != null) {
      LocalStorageService.saveUserProfile(state!);
    }
  }

  /// 更新软技能评分
  void updateSoftSkills(Map<String, double> softSkills) {
    state = (state ?? UserProfileModel()).copyWith(
      softSkills: softSkills,
      updatedAt: DateTime.now(),
    );
    // 保存到本地存储
    if (state != null) {
      LocalStorageService.saveUserProfile(state!);
    }
  }

  /// 更新总分
  void updateOverallScore(double score) {
    state = (state ?? UserProfileModel()).copyWith(
      overallScore: score,
      updatedAt: DateTime.now(),
    );
    // 保存到本地存储
    if (state != null) {
      LocalStorageService.saveUserProfile(state!);
    }
  }

  /// 重置用户画像
  void reset() {
    state = null;
  }
}

/// 用户画像Provider
final userProfileNotifierProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileModel?>((ref) {
  return UserProfileNotifier();
});

/// 基础信息表单Provider
class BasicInfoFormNotifier extends StateNotifier<BasicInfoModel> {
  BasicInfoFormNotifier() : super(BasicInfoModel()) {
    _loadSavedBasicInfo();
  }

  /// 加载保存的基础信息
  Future<void> _loadSavedBasicInfo() async {
    try {
      final savedInfo = await LocalStorageService.getBasicInfo();
      if (savedInfo != null) {
        state = savedInfo;
      }
    } catch (e) {
      debugPrint('加载基础信息失败: $e');
    }
  }

  void updateField<K>(K Function(BasicInfoModel) field, K value) {
    // 简单的字段更新方法
    if (field == (p) => p.name) {
      state = state.copyWith(name: value as String?);
    } else if (field == (p) => p.gender) {
      state = state.copyWith(gender: value as String?);
    } else if (field == (p) => p.birthDate) {
      state = state.copyWith(birthDate: value as DateTime?);
    } else if (field == (p) => p.education) {
      state = state.copyWith(education: value as String?);
    } else if (field == (p) => p.major) {
      state = state.copyWith(major: value as String?);
    } else if (field == (p) => p.school) {
      state = state.copyWith(school: value as String?);
    } else if (field == (p) => p.graduationYear) {
      state = state.copyWith(graduationYear: value as int?);
    } else if (field == (p) => p.phone) {
      state = state.copyWith(phone: value as String?);
    } else if (field == (p) => p.tags) {
      state = state.copyWith(tags: value as List<String>?);
    }
    // 保存到本地存储
    LocalStorageService.saveBasicInfo(state);
  }

  void reset() {
    state = BasicInfoModel();
  }
}

/// 基础信息表单Provider
final basicInfoFormProvider =
    StateNotifierProvider<BasicInfoFormNotifier, BasicInfoModel>((ref) {
  return BasicInfoFormNotifier();
});
