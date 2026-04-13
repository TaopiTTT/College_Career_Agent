import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../data/models/assessment_model.dart';
import '../../providers/assessment_provider.dart';
import '../../widgets/assessment_bottom_nav.dart';

/// 基础信息填报表单页
class BasicInfoScreen extends ConsumerStatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  ConsumerState<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends ConsumerState<BasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _majorController = TextEditingController();
  final _schoolController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _gender;
  DateTime? _birthDate;
  String? _education;
  int? _graduationYear;
  final List<String> _tags = [];
  final List<String> _availableTags = [
    '英语六级',
    '计算机二级',
    '学生会干部',
    '社团负责人',
    '奖学金获得者',
    '竞赛获奖',
    '实习经历',
    '志愿者',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _majorController.dispose();
    _schoolController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    if (_gender == null) {
      setState(() {
        _genderError = '请选择性别';
      });
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final basicInfo = BasicInfoModel(
      name: _nameController.text.trim(),
      gender: _gender,
      birthDate: _birthDate,
      education: _education,
      major: _majorController.text.trim(),
      school: _schoolController.text.trim(),
      graduationYear: _graduationYear,
      phone: _phoneController.text.trim(),
      tags: _toList(_tags),
    );

    // 更新用户画像
    ref.read(userProfileNotifierProvider.notifier).updateBasicInfo(basicInfo);

    // 保存基础信息到本地
    await LocalStorageService.saveBasicInfo(basicInfo);

    // 标记步骤为完成
    ref.read(assessmentNotifierProvider.notifier).completeStep(AssessmentStep.basicInfo);

    // 保存评估状态到本地
    final assessmentState = ref.read(assessmentNotifierProvider);
    await LocalStorageService.saveAssessmentState(assessmentState);

    // 跳转到问卷页面
    if (mounted) {
      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('基础信息已保存！'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      // 跳转到问卷
      context.push('/assessment/questionnaire');
    }
  }

  List<String> _toList(List<String> list) {
    return List<String>.from(list);
  }

  String? _genderError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('基础信息'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '步骤 1/5',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 进度条
              _buildProgressBar(),
              const SizedBox(height: 24),

              // 基本信息表单
              _buildSectionTitle('基本信息'),
              const SizedBox(height: 16),
              _buildNameField(),
              const SizedBox(height: 16),
              _buildGenderField(),
              const SizedBox(height: 16),
              _buildBirthDateField(),
              const SizedBox(height: 24),

              // 学业信息表单
              _buildSectionTitle('学业信息'),
              const SizedBox(height: 16),
              _buildEducationField(),
              const SizedBox(height: 16),
              _buildMajorField(),
              const SizedBox(height: 16),
              _buildSchoolField(),
              const SizedBox(height: 16),
              _buildGraduationYearField(),
              const SizedBox(height: 24),

              // 联系方式
              _buildSectionTitle('联系方式'),
              const SizedBox(height: 16),
              _buildPhoneField(),
              const SizedBox(height: 24),

              // 个人标签
              _buildSectionTitle('个人标签'),
              const SizedBox(height: 16),
              _buildTagsField(),
              const SizedBox(height: 32),

              // 提交按钮
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '保存并继续',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 添加底部间距，避免内容被底部导航栏遮挡
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AssessmentBottomNav(currentStep: 1),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: const LinearProgressIndicator(
            value: 0.2,
            backgroundColor: Colors.grey,
            valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '完成度 20%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: '姓名',
        hintText: '请输入您的姓名',
        prefixIcon: Icon(Icons.person_outlined),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入姓名';
        }
        return null;
      },
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('性别'),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'male',
              label: Text('男'),
              icon: Icon(Icons.male),
            ),
            ButtonSegment(
              value: 'female',
              label: Text('女'),
              icon: Icon(Icons.female),
            ),
            ButtonSegment(
              value: 'other',
              label: Text('其他'),
              icon: Icon(Icons.transgender),
            ),
          ],
          selected: _gender != null ? {_gender!} : {},
          emptySelectionAllowed: true,
          onSelectionChanged: (Set<String> selection) {
            setState(() {
              _gender = selection.isNotEmpty ? selection.first : null;
              _genderError = null;
            });
          },
        ),
        if (_genderError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _genderError!,
              style: TextStyle(
                color: AppTheme.errorColor,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBirthDateField() {
    return InkWell(
      onTap: () => _selectBirthDate(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: '出生日期',
          hintText: '请选择出生日期',
          prefixIcon: Icon(Icons.calendar_today_outlined),
          border: OutlineInputBorder(),
        ),
        child: Text(
          _birthDate == null
              ? '请选择日期'
              : '${_birthDate!.year}年${_birthDate!.month}月${_birthDate!.day}日',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: _birthDate == null ? Colors.grey : Colors.black,
              ),
        ),
      ),
    );
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 50);
    final lastDate = DateTime(now.year - 15);

    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20),
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('zh', 'CN'),
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Widget _buildEducationField() {
    return DropdownButtonFormField<String>(
      initialValue: _education,
      decoration: const InputDecoration(
        labelText: '学历',
        hintText: '请选择您的学历',
        prefixIcon: Icon(Icons.school_outlined),
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: '高中', child: Text('高中')),
        DropdownMenuItem(value: '大专', child: Text('大专')),
        DropdownMenuItem(value: '本科', child: Text('本科')),
        DropdownMenuItem(value: '硕士', child: Text('硕士')),
        DropdownMenuItem(value: '博士', child: Text('博士')),
      ],
      onChanged: (value) {
        setState(() {
          _education = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return '请选择学历';
        }
        return null;
      },
    );
  }

  Widget _buildMajorField() {
    return TextFormField(
      controller: _majorController,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: '专业',
        hintText: '请输入您的专业',
        prefixIcon: Icon(Icons.menu_book_outlined),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入专业';
        }
        return null;
      },
    );
  }

  Widget _buildSchoolField() {
    return TextFormField(
      controller: _schoolController,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: '学校',
        hintText: '请输入您的学校',
        prefixIcon: Icon(Icons.apartment_outlined),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入学校';
        }
        return null;
      },
    );
  }

  Widget _buildGraduationYearField() {
    final now = DateTime.now();
    final years = List.generate(6, (index) => now.year + index);

    return DropdownButtonFormField<int>(
      initialValue: _graduationYear,
      decoration: const InputDecoration(
        labelText: '毕业年份',
        hintText: '请选择毕业年份',
        prefixIcon: Icon(Icons.event_outlined),
        border: OutlineInputBorder(),
      ),
      items: years.map((year) {
        return DropdownMenuItem(
          value: year,
          child: Text('$year年'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _graduationYear = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return '请选择毕业年份';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        labelText: '手机号码',
        hintText: '请输入手机号码',
        prefixIcon: Icon(Icons.phone_outlined),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入手机号码';
        }
        if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
          return '请输入有效的手机号码';
        }
        return null;
      },
    );
  }

  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('选择您的标签（可多选）'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTags.map((tag) {
            final isSelected = _tags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _tags.add(tag);
                  } else {
                    _tags.remove(tag);
                  }
                });
              },
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }
}
