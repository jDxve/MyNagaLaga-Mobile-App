import 'package:flutter/material.dart';
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

class EvacuationCenterPage extends StatefulWidget {
  final String userName;
  final String userAge;

  const EvacuationCenterPage({
    super.key,
    required this.userName,
    required this.userAge,
  });

  @override
  State<EvacuationCenterPage> createState() => _EvacuationCenterPageState();
}

class _EvacuationCenterPageState extends State<EvacuationCenterPage> {
  String? selectedRecipient = Constant.forMe;
  final TextEditingController familyMemberController = TextEditingController();
  final TextEditingController requestAssistanceController = TextEditingController();
  final TextEditingController urgencyController = TextEditingController();
  final TextEditingController specificDetailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    specificDetailsController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    familyMemberController.dispose();
    requestAssistanceController.dispose();
    urgencyController.dispose();
    specificDetailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Evacuation Center',
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
        _buildLabel('Request Assistance'),
        8.gapH,
        Dropdown(
          controller: requestAssistanceController,
          hintText: 'Select request type',
          items: const [
            'Emergency Shelter',
            'Food Assistance',
            'Medical Support',
            'Water Supply',
            'Clothing and Blankets',
          ],
        ),
        20.gapH,
        _buildLabel('Urgency'),
        8.gapH,
        Dropdown(
          controller: urgencyController,
          hintText: 'Select request type',
          items: const [
            'Critical - Immediate',
            'High - Within 24 hours',
            'Medium - Within 48 hours',
            'Low - Within a week',
          ],
        ),
        20.gapH,
        _buildSpecificDetailsSection(),
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
        _buildLabel('Request Assistance'),
        8.gapH,
        Dropdown(
          controller: requestAssistanceController,
          hintText: 'Select request type',
          items: const [
            'Emergency Shelter',
            'Food Assistance',
            'Medical Support',
            'Water Supply',
            'Clothing and Blankets',
          ],
        ),
        20.gapH,
        _buildLabel('Urgency'),
        8.gapH,
        Dropdown(
          controller: urgencyController,
          hintText: 'Select request type',
          items: const [
            'Critical - Immediate',
            'High - Within 24 hours',
            'Medium - Within 48 hours',
            'Low - Within a week',
          ],
        ),
        20.gapH,
        _buildSpecificDetailsSection(),
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

  Widget _buildSpecificDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Specific Details'),
        8.gapH,
        TextInput(
          controller: specificDetailsController,
          hintText: 'Please explain why you need this assistance',
          maxLines: 4,
        ),
        4.gapH,
        Text(
          '${specificDetailsController.text.length}/20 ${AppString.charactersMinimum}',
          style: TextStyle(
            fontSize: D.textXS,
            color: AppColors.grey,
            fontFamily: 'Segoe UI',
          ),
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
            Assets.indigentFamilyBadge,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}