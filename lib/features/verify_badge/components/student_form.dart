import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/strings.dart';
import '../../../common/utils/constant.dart';
import '../../../common/widgets/drop_down.dart';
import '../../../common/widgets/text_input.dart';
import '../../../common/widgets/error_modal.dart';
import 'benefits_card.dart';

class StudentForm extends StatefulWidget {
  final TextEditingController existingIdController;
  final Function(bool isValid, VoidCallback showError)? setIsFormValid;

  const StudentForm({
    super.key,
    required this.existingIdController,
    this.setIsFormValid,
  });

  @override
  State<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _educationLevelController = TextEditingController();
  final TextEditingController _yearLevelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _schoolNameController.addListener(_validate);
    _educationLevelController.addListener(_validate);
    _yearLevelController.addListener(_validate);
    WidgetsBinding.instance.addPostFrameCallback((_) => _validate());
  }

  void _validate() {
    final isValid = _schoolNameController.text.isNotEmpty &&
        _educationLevelController.text.isNotEmpty &&
        _yearLevelController.text.isNotEmpty;

    widget.setIsFormValid?.call(isValid, _showError);
  }

  void _showError() {
    List<String> missingFields = [];
    
    if (_schoolNameController.text.isEmpty) {
      missingFields.add("School Name");
    }
    if (_educationLevelController.text.isEmpty) {
      missingFields.add("Education Level");
    }
    if (_yearLevelController.text.isEmpty) {
      missingFields.add("Year/Grade Level");
    }

    String description = missingFields.isEmpty 
        ? "All fields are complete."
        : "Please complete the following field${missingFields.length > 1 ? 's' : ''}:\n\n${missingFields.map((f) => "• $f").join('\n')}";

    showErrorModal(
      context: context,
      title: "Required Information Missing",
      description: description,
      icon: Icons.school_outlined,
      iconColor: AppColors.primary,
    );
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _educationLevelController.dispose();
    _yearLevelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.schoolName,
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.semiBold,
            color: Colors.black,
            fontFamily: 'Segoe UI',
          ),
        ),
        8.gapH,
        TextInput(
          controller: _schoolNameController,
          hintText: AppString.searchSchoolName,
        ),
        16.gapH,
        Text(
          AppString.educationLevel,
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.semiBold,
            color: Colors.black,
            fontFamily: 'Segoe UI',
          ),
        ),
        8.gapH,
        Dropdown(
          controller: _educationLevelController,
          hintText: AppString.selectLevel,
          items: Constant.educationLevels,
          onChanged: (value) {
            setState(() {
              _yearLevelController.clear();
            });
          },
        ),
        16.gapH,
        Text(
          AppString.yearGradeLevel,
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.semiBold,
            color: Colors.black,
            fontFamily: 'Segoe UI',
          ),
        ),
        8.gapH,
        Dropdown(
          controller: _yearLevelController,
          hintText: AppString.selectYearLevel,
          items: Constant.yearLevelMap[_educationLevelController.text] ?? [],
        ),
        24.gapH,
        BenefitsCard(
          title: AppString.studentBenefitsTitle,
          benefits: [
            AppString.studentBenefit1,
            AppString.studentBenefit2,
            AppString.studentBenefit3,
          ],
          color: AppColors.lightBlue,
        ),
      ],
    );
  }
}