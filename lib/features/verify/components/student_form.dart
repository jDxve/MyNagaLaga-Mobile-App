import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/strings.dart';
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
  final TextEditingController _educationLevelController =
      TextEditingController();
  final TextEditingController _yearLevelController = TextEditingController();

  final LayerLink _educationLayerLink = LayerLink();
  final LayerLink _yearLayerLink = LayerLink();

  bool _isEducationDropdownOpen = false;
  bool _isYearDropdownOpen = false;

  OverlayEntry? _educationOverlayEntry;
  OverlayEntry? _yearOverlayEntry;

  final List<String> educationLevels = [
    'Elementary',
    'Junior High School',
    'Senior High School',
    'College',
    'Graduate School',
  ];

  final Map<String, List<String>> yearLevels = {
    'Elementary': [
      'Grade 1',
      'Grade 2',
      'Grade 3',
      'Grade 4',
      'Grade 5',
      'Grade 6',
    ],
    'Junior High School': ['Grade 7', 'Grade 8', 'Grade 9', 'Grade 10'],
    'Senior High School': ['Grade 11', 'Grade 12'],
    'College': ['1st Year', '2nd Year', '3rd Year', '4th Year', '5th Year'],
    'Graduate School': ['1st Year', '2nd Year', '3rd Year'],
  };

  @override
  void initState() {
    super.initState();
    _schoolNameController.addListener(_validate);
    _educationLevelController.addListener(_validate);
    _yearLevelController.addListener(_validate);
    WidgetsBinding.instance.addPostFrameCallback((_) => _validate());
  }

  void _validate() {
    final isValid =
        _schoolNameController.text.isNotEmpty &&
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
    _removeAllOverlays();
    super.dispose();
  }

  void _removeAllOverlays() {
    _educationOverlayEntry?.remove();
    _yearOverlayEntry?.remove();
    _educationOverlayEntry = null;
    _yearOverlayEntry = null;
  }

  void _toggleEducationDropdown() {
    if (_isEducationDropdownOpen) {
      _educationOverlayEntry?.remove();
      _educationOverlayEntry = null;
      setState(() => _isEducationDropdownOpen = false);
    } else {
      _removeAllOverlays();
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final size = renderBox.size;
      _educationOverlayEntry = _createDropdownOverlay(
        _educationLayerLink,
        size.width,
        educationLevels,
        (value) {
          setState(() {
            _educationLevelController.text = value;
            _yearLevelController.clear();
          });
          _toggleEducationDropdown();
        },
      );
      Overlay.of(context).insert(_educationOverlayEntry!);
      setState(() => _isEducationDropdownOpen = true);
    }
  }

  void _toggleYearDropdown() {
    if (_educationLevelController.text.isEmpty ||
        !yearLevels.containsKey(_educationLevelController.text)) {
      return;
    }

    if (_isYearDropdownOpen) {
      _yearOverlayEntry?.remove();
      _yearOverlayEntry = null;
      setState(() => _isYearDropdownOpen = false);
    } else {
      _removeAllOverlays();
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final size = renderBox.size;
      final years = yearLevels[_educationLevelController.text] ?? [];
      _yearOverlayEntry = _createDropdownOverlay(
        _yearLayerLink,
        size.width,
        years,
        (value) {
          setState(() => _yearLevelController.text = value);
          _toggleYearDropdown();
        },
      );
      Overlay.of(context).insert(_yearOverlayEntry!);
      setState(() => _isYearDropdownOpen = true);
    }
  }

  OverlayEntry _createDropdownOverlay(
    LayerLink link,
    double width,
    List<String> items,
    Function(String) onSelect,
  ) {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: width,
        child: CompositedTransformFollower(
          link: link,
          showWhenUnlinked: false,
          offset: Offset(0, 42.h),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(D.radiusLG),
            child: Container(
              constraints: BoxConstraints(maxHeight: 200.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(D.radiusLG),
                border: Border.all(color: AppColors.grey.withOpacity(0.2)),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(
                      item,
                      style: const TextStyle(fontFamily: 'Segoe UI'),
                    ),
                    onTap: () => onSelect(item),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
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
        CompositedTransformTarget(
          link: _educationLayerLink,
          child: GestureDetector(
            onTap: _toggleEducationDropdown,
            child: AbsorbPointer(
              child: TextInput(
                controller: _educationLevelController,
                hintText: AppString.selectLevel,
                suffixIcon: Icon(
                  _isEducationDropdownOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ),
            ),
          ),
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
        CompositedTransformTarget(
          link: _yearLayerLink,
          child: GestureDetector(
            onTap: _toggleYearDropdown,
            child: AbsorbPointer(
              child: TextInput(
                controller: _yearLevelController,
                hintText: AppString.selectYearLevel,
                suffixIcon: Icon(
                  _isYearDropdownOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ),
            ),
          ),
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
