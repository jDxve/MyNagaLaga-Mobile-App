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

class MedicalAssistancePage extends StatefulWidget {
  final String userName;
  final String userAge;

  const MedicalAssistancePage({
    super.key,
    required this.userName,
    required this.userAge,
  });

  @override
  State<MedicalAssistancePage> createState() => _MedicalAssistancePageState();
}

class _MedicalAssistancePageState extends State<MedicalAssistancePage> {
  String? selectedRecipient = Constant.forMe;
  final TextEditingController familyMemberController = TextEditingController();
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController diagnosisController = TextEditingController();
  final TextEditingController billAmountController = TextEditingController();
  File? uploadedDocument;

  @override
  void dispose() {
    familyMemberController.dispose();
    hospitalController.dispose();
    diagnosisController.dispose();
    billAmountController.dispose();
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
        title: 'Medical Assistance',
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
                _buildForMeForm(),
              ] else ...[
                _buildFamilyMemberForm(),
              ],
              PrimaryButton(
                text: AppString.submitRequest,
                onPressed: () {},
              ),
              20.gapH,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForMeForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoCard(
          title: AppString.applicantDetails,
          items: [
            InfoCardItem(
              label: AppString.fullName,
              value: widget.userName,
            ),
            InfoCardItem(
              label: AppString.age,
              value: widget.userAge,
            ),
          ],
        ),
        20.gapH,
        _buildLabel('Hospital/Clinic Name'),
        8.gapH,
        Dropdown(
          controller: hospitalController,
          hintText: 'Select or enter hospital name',
          items: const [
            'Bicol Medical Center',
            'Albay Provincial Hospital',
            'Legazpi City General Hospital',
            'St. Gregory The Great Medical Center',
          ],
        ),
        20.gapH,
        _buildLabel('Diagnosis / Medical Condition'),
        8.gapH,
        TextInput(
          controller: diagnosisController,
          hintText: 'Description',
          maxLines: 4,
        ),
        20.gapH,
        _buildLabel('Bill Amount'),
        8.gapH,
        Dropdown(
          controller: billAmountController,
          hintText: 'Select or enter hospital name',
          items: const [
            '₱5,000 - ₱10,000',
            '₱10,000 - ₱20,000',
            '₱20,000 - ₱50,000',
            '₱50,000 and above',
          ],
        ),
        20.gapH,
        _buildUploadSection(),
        20.gapH,
        _buildAttachedBadge(),
        24.gapH,
      ],
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
        _buildLabel('Hospital/Clinic Name'),
        8.gapH,
        Dropdown(
          controller: hospitalController,
          hintText: 'Select or enter hospital name',
          items: const [
            'Bicol Medical Center',
            'Albay Provincial Hospital',
            'Legazpi City General Hospital',
            'St. Gregory The Great Medical Center',
          ],
        ),
        20.gapH,
        _buildLabel('Diagnosis / Medical Condition'),
        8.gapH,
        TextInput(
          controller: diagnosisController,
          hintText: 'Description',
          maxLines: 4,
        ),
        20.gapH,
        _buildLabel('Bill Amount'),
        8.gapH,
        Dropdown(
          controller: billAmountController,
          hintText: 'Select or enter hospital name',
          items: const [
            '₱5,000 - ₱10,000',
            '₱10,000 - ₱20,000',
            '₱20,000 - ₱50,000',
            '₱50,000 and above',
          ],
        ),
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

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(AppString.uploadSupportingDocument),
        4.gapH,
        Text(
          'e.g. Valid Hospital Bill or Medical Abstract (Signed by Doctor)',
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
       //  showActions: true,
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
}