import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../common/resources/colors.dart';
import '../../../../common/resources/dimensions.dart';
import '../../../../common/resources/assets.dart';
import '../../../../common/resources/strings.dart';
import '../../../../common/utils/constant.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../common/widgets/drop_down.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/info_card.dart';
import '../../../../common/widgets/toggle.dart';
import '../../../../common/widgets/text_input.dart';
import '../../../../common/widgets/upload_image_card.dart';

class SanggawadanPage extends StatefulWidget {
  final String userName;
  final String userAge;
  final String userSchool;
  final String userGradeLevel;

  const SanggawadanPage({
    super.key,
    required this.userName,
    required this.userAge,
    required this.userSchool,
    required this.userGradeLevel,
  });

  @override
  State<SanggawadanPage> createState() => _SanggawadanPageState();
}

class _SanggawadanPageState extends State<SanggawadanPage> {
  String? selectedRecipient = Constant.forMe;
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController familyMemberController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();
  final TextEditingController educationLevelController =
      TextEditingController();
  final TextEditingController gradeLevelController = TextEditingController();
  File? uploadedDocument;

  @override
  void initState() {
    super.initState();
    reasonController.addListener(() => setState(() {}));
    educationLevelController.addListener(() {
      setState(() {
        gradeLevelController.clear();
      });
    });
  }

  @override
  void dispose() {
    reasonController.dispose();
    familyMemberController.dispose();
    schoolController.dispose();
    educationLevelController.dispose();
    gradeLevelController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          uploadedDocument = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: AppString.sanggawadanTitle,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Toggle(
                selectedValue: selectedRecipient,
                onChanged: (value) => setState(() => selectedRecipient = value),
                firstLabel: AppString.forMe,
                firstValue: Constant.forMe,
                secondLabel: AppString.forFamilyMember,
                secondValue: Constant.forFamily,
              ),
              20.gapH,
              if (selectedRecipient == Constant.forMe) ...[
                InfoCard(
                  title: AppString.applicantDetails,
                  items: [
                    InfoCardItem(
                      label: AppString.fullName,
                      value: widget.userName,
                    ),
                    InfoCardItem(label: AppString.age, value: widget.userAge),
                    InfoCardItem(
                      label: AppString.schoolName,
                      value: widget.userSchool,
                    ),
                    InfoCardItem(
                      label: AppString.yearGradeLevel,
                      value: widget.userGradeLevel,
                    ),
                  ],
                ),
                20.gapH,
                _buildReasonSection(),
                20.gapH,
                _buildAttachedBadge(),
                24.gapH,
              ] else ...[
                _buildFamilyMemberForm(),
              ],
              PrimaryButton(text: AppString.submitRequest, onPressed: () {}),
              20.gapH,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFamilyMemberForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(AppString.familyMember),
        8.gapH,
        Dropdown(
          controller: familyMemberController,
          hintText: AppString.selectFamilyMember,
          items: const [
            'John Santos (Son)',
            'Jane Santos (Daughter)',
            'Maria Santos (Mother)',
            'Jose Santos (Father)',
          ],
        ),
        20.gapH,
        _buildLabel(AppString.requestDetails),
        12.gapH,
        _buildSubLabel(AppString.schoolName),
        8.gapH,
        TextInput(
          controller: schoolController,
          hintText: AppString.searchSchoolName,
        ),
        16.gapH,
        _buildSubLabel(AppString.educationLevel),
        8.gapH,
        Dropdown(
          controller: educationLevelController,
          hintText: AppString.selectLevel,
          items: Constant.educationLevels,
        ),
        16.gapH,
        _buildSubLabel(AppString.yearGradeLevel),
        8.gapH,
        Dropdown(
          controller: gradeLevelController,
          hintText: AppString.selectYearLevel,
          items: Constant.yearLevelMap[educationLevelController.text] ?? [],
        ),
        20.gapH,
        _buildReasonSection(),
        20.gapH,
        _buildUploadSection(),
        24.gapH,
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: D.textBase,
        fontWeight: D.semiBold,
        fontFamily: 'Segoe UI',
        color: AppColors.black,
      ),
    );
  }

  Widget _buildSubLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: D.textSM,
        fontWeight: D.medium,
        fontFamily: 'Segoe UI',
        color: AppColors.black,
      ),
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(AppString.uploadSupportingDocument),
        4.gapH,
        Text(
          AppString.enrollmentCertExample,
          style: TextStyle(
            fontSize: D.textXS,
            color: AppColors.grey,
            fontFamily: 'Segoe UI',
          ),
        ),
        12.gapH,
        UploadImage(
          image: uploadedDocument,
          title: AppString.uploadYourFile,
          subtitle: AppString.dragOrChoose,
          height: 150.h,
          showActions: true,
          onPickImage: _pickImage,
          onRemove: () => setState(() => uploadedDocument = null),
        ),
      ],
    );
  }

  Widget _buildAttachedBadge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(AppString.attachedBadge),
        12.gapH,
        ClipRRect(
          borderRadius: BorderRadius.circular(D.radiusLG),
          child: Image.asset(
            Assets.studentBadge,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Widget _buildReasonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(AppString.reasonForRequest),
        8.gapH,
        TextInput(
          controller: reasonController,
          hintText: AppString.reasonHint,
          maxLines: 4,
        ),
        4.gapH,
        Text(
          '${reasonController.text.length}/1020 ${AppString.charactersMinimum}',
          style: TextStyle(
            fontSize: D.textXS,
            color: AppColors.grey,
            fontFamily: 'Segoe UI',
          ),
        ),
      ],
    );
  }
}
