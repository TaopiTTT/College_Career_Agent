import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../data/models/assessment_model.dart';
import '../../providers/assessment_provider.dart';

/// 硬技能自评页面
class SkillsSelfAssessmentScreen extends ConsumerStatefulWidget {
  const SkillsSelfAssessmentScreen({super.key});

  @override
  ConsumerState<SkillsSelfAssessmentScreen> createState() =>
      _SkillsSelfAssessmentScreenState();
}

class _SkillsSelfAssessmentScreenState
    extends ConsumerState<SkillsSelfAssessmentScreen> {
  // 预定义技能分类
  final Map<String, List<String>> _categorySkills = {
    '编程语言': ['Java', 'Python', 'JavaScript', 'C++', 'Go', 'Rust', 'Swift', 'Kotlin'],
    '前端开发': ['React', 'Vue', 'Angular', 'Flutter', 'HTML/CSS', 'TypeScript'],
    '后端开发': ['Spring Boot', 'Node.js', 'Django', 'Flask', '.NET Core', 'Express'],
    '数据库': ['MySQL', 'PostgreSQL', 'MongoDB', 'Redis', 'Oracle', 'SQL Server'],
    '移动开发': ['Android', 'iOS', 'React Native', 'Flutter', 'SwiftUI', 'Jetpack Compose'],
    '云计算': ['AWS', 'Azure', 'Google Cloud', '阿里云', 'Docker', 'Kubernetes'],
    '大数据': ['Hadoop', 'Spark', 'Flink', 'Kafka', 'Hive', 'HBase'],
    '人工智能': ['TensorFlow', 'PyTorch', 'Keras', 'OpenCV', 'NLP', '机器学习'],
  };

  // 用户选择的技能及熟练度
  final Map<String, Map<String, int>> _selectedSkills = {};

  // 当前显示的分类
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('技能自评'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '步骤 2/5',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 分类Tab
          _buildCategoryTabs(),
          const Divider(height: 1),
          // 技能列表
          Expanded(
            child: _selectedCategory != null
                ? _buildSkillsGrid(_selectedCategory!)
                : _buildEmptyState(),
          ),
          // 底部操作栏
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: _categorySkills.keys.map((category) {
          final isSelected = _selectedCategory == category;
          final skillCount = _selectedSkills[category]?.length ?? 0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(category),
                  if (skillCount > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$skillCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category : null;
                });
              },
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primaryColor,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSkillsGrid(String category) {
    final skills = _categorySkills[category] ?? [];
    final userSkills = _selectedSkills[category] ?? {};

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        final proficiency = userSkills[skill];

        return InkWell(
          onTap: () => _showProficiencyDialog(category, skill, proficiency),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: proficiency != null
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              border: Border.all(
                color: proficiency != null
                    ? AppTheme.primaryColor
                    : Colors.grey.shade300,
                width: proficiency != null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    skill,
                    style: TextStyle(
                      color: proficiency != null
                          ? AppTheme.primaryColor
                          : Colors.black87,
                      fontWeight: proficiency != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (proficiency != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star,
                        size: 14,
                        color: index < proficiency
                            ? AppTheme.warningColor
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                Icon(
                  proficiency != null ? Icons.check_circle : Icons.add_circle_outline,
                  size: 20,
                  color: proficiency != null
                      ? AppTheme.primaryColor
                      : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '请选择技能分类',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击上方的分类标签开始选择',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade400,
                ),
          ),
        ],
      ),
    );
  }

  void _showProficiencyDialog(String category, String skill, int? currentProficiency) {
    showDialog(
      context: context,
      builder: (context) => _ProficiencyDialog(
        skillName: skill,
        currentProficiency: currentProficiency,
        onConfirm: (proficiency) {
          setState(() {
            if (!_selectedSkills.containsKey(category)) {
              _selectedSkills[category] = {};
            }
            if (proficiency == 0) {
              _selectedSkills[category]!.remove(skill);
            } else {
              _selectedSkills[category]![skill] = proficiency;
            }
          });
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    int totalSkills = 0;
    _selectedSkills.forEach((category, skills) {
      totalSkills += skills.length;
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '已选择 $totalSkills 项技能',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: totalSkills > 0 ? _saveAndContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.primaryColor.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('保存并继续'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAndContinue() async {
    // 将选中的技能转换为SkillModel列表
    final skills = <SkillModel>[];
    _selectedSkills.forEach((category, skillMap) {
      skillMap.forEach((skillName, proficiency) {
        skills.add(SkillModel(
          name: skillName,
          category: category,
          proficiency: proficiency,
          isCustom: false,
        ));
      });
    });

    // 更新用户画像
    ref.read(userProfileNotifierProvider.notifier).updateSkills(skills);

    // 保存到本地
    await LocalStorageService.saveUserProfile(
      ref.read(userProfileNotifierProvider) ?? UserProfileModel(),
    );

    // 标记步骤为完成
    ref.read(assessmentNotifierProvider.notifier).completeStep(AssessmentStep.skills);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('技能信息已保存！'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      // 返回进度页面
      context.pop();
    }
  }
}

/// 熟练度选择对话框
class _ProficiencyDialog extends StatefulWidget {
  final String skillName;
  final int? currentProficiency;
  final Function(int) onConfirm;

  const _ProficiencyDialog({
    required this.skillName,
    this.currentProficiency,
    required this.onConfirm,
  });

  @override
  State<_ProficiencyDialog> createState() => _ProficiencyDialogState();
}

class _ProficiencyDialogState extends State<_ProficiencyDialog> {
  late int _proficiency;

  @override
  void initState() {
    super.initState();
    _proficiency = widget.currentProficiency ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        '评估熟练度',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.skillName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            '熟练度评分：$_proficiency',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return IconButton(
                iconSize: 40,
                onPressed: () {
                  setState(() {
                    _proficiency = starValue;
                  });
                },
                icon: Icon(
                  _proficiency >= starValue ? Icons.star : Icons.star_border,
                  color: AppTheme.warningColor,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            _getProficiencyText(_proficiency),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(_proficiency);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('确认'),
        ),
      ],
    );
  }

  String _getProficiencyText(int proficiency) {
    switch (proficiency) {
      case 1:
        return '入门 - 了解基本概念';
      case 2:
        return '初级 - 能完成简单任务';
      case 3:
        return '中级 - 能独立完成工作';
      case 4:
        return '高级 - 能解决复杂问题';
      case 5:
        return '专家 - 能指导他人';
      default:
        return '';
    }
  }
}
