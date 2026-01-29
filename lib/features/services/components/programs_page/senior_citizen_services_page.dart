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

class SeniorCitizenServicesPage extends StatefulWidget {
  final String userName;
  final String userAge;

  const SeniorCitizenServicesPage({
    super.key,
    required this.userName,
    required this.userAge,
  });

  @override
  State<SeniorCitizenServicesPage> createState() =>
      _SeniorCitizenServicesPageState();
}

class _SeniorCitizenServicesPageState extends State<SeniorCitizenServicesPage> {
  String? selectedRecipient = Constant.forMe;
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController familyMemberController = TextEditingController();
  final TextEditingController requestTypeController = TextEditingController();
  File? uploadedDocument;

  @override
  void initState() {
    super.initState();
    reasonController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    reasonController.dispose();
    familyMemberController.dispose();
    requestTypeController.dispose();
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
        title: 'Senior Citizen Services',
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
                  ],
                ),
                20.gapH,
                _buildLabel('Senior Request Type'),
                8.gapH,
                Dropdown(
                  controller: requestTypeController,
                  hintText: 'Select request type',
                  items: const [
                    'New OSCA ID Application',
                    'OSCA ID Renewal',
                    'Social Pension Release',
                    'Senior Citizen Assistance',
                  ],
                ),
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
            'Juan Dela Cruz (Father)',
            'Maria Santos (Mother)',
            'Jose Rizal (Grandfather)',
            'Rosa Cruz (Grandmother)',
          ],
        ),
        20.gapH,
        _buildLabel('Senior Request Type'),
        8.gapH,
        Dropdown(
          controller: requestTypeController,
          hintText: 'Select type',
          items: const [
            'New OSCA ID Application',
            'OSCA ID Renewal',
            'Social Pension Release',
            'Senior Citizen Assistance',
          ],
        ),
        20.gapH,
        _buildUploadSection(),
        20.gapH,
        _buildReasonSection(),
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

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(AppString.uploadSupportingDocument),
        4.gapH,
        Text(
          'e.g. Senior Citizen ID',
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
            Assets.seniorCitizenBadge,
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
          '${reasonController.text.length}/20 ${AppString.charactersMinimum}',
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
