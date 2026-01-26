import 'dart:io';
import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/strings.dart';
import '../../../common/widgets/error_modal.dart';
import '../../../common/widgets/info_card.dart';

class ReviewPage extends StatefulWidget {
  final String? selectedBadge;
  final String fullName;
  final String dateOfBirth;
  final String? gender;
  final String address;
  final String contactNumber;
  final String? existingId;
  final String? selectedIdType;
  final File? frontIdImage;
  final File? backIdImage;
  final File? supportingFile;
  final Function(bool) onConsentChanged;
  final bool isConsentGiven;
  final VoidCallback? onValidationError;

  const ReviewPage({
    super.key,
    required this.selectedBadge,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    required this.contactNumber,
    this.existingId,
    this.selectedIdType,
    this.frontIdImage,
    this.backIdImage,
    this.supportingFile,
    required this.onConsentChanged,
    required this.isConsentGiven,
    this.onValidationError,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  String _getBadgeDisplayName(String? badgeId) {
    switch (badgeId) {
      case 'senior_citizen': return AppString.seniorCitizenTitle;
      case 'pwd': return AppString.pwdTitle;
      case 'solo_parent': return AppString.soloParentTitle;
      case 'indigent': return AppString.indigentTitle;
      case 'student': return AppString.studentTitle;
      default: return 'Unknown';
    }
  }

  String _getGenderDisplayName(String? gender) {
    if (gender == 'male') return AppString.male;
    if (gender == 'female') return AppString.female;
    return '';
  }

  void _showImagePreview(File image) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.all(20.w),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(D.radiusLG),
                child: Image.file(image, fit: BoxFit.contain),
              ),
              Positioned(
                top: 8.h,
                right: 8.w,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 16.w),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageItem(String label, File image, {bool isFullWidth = false}) {
    Widget content = GestureDetector(
      onTap: () => _showImagePreview(image),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: D.textXS,
              color: AppColors.grey,
              fontFamily: 'Segoe UI',
            ),
          ),
          4.gapH,
          ClipRRect(
            borderRadius: BorderRadius.circular(D.radiusMD),
            child: Image.file(
              image,
              height: 120.h,
              width: isFullWidth ? double.infinity : double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );

    return isFullWidth ? content : Expanded(child: content);
  }

  void _showConsentError() {
    showErrorModal(
      context: context,
      title: AppString.consentRequiredTitle,
      description: AppString.consentRequiredDescription,
      icon: Icons.error_outline,
      iconColor: Colors.orange,
      buttonText: AppString.ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoCard(
          icon: Icons.badge_outlined,
          iconColor: AppColors.lightYellow,
          title: AppString.step1Title,
          items: [
            InfoCardItem(
              label: AppString.selectedBadgeLabel,
              value: _getBadgeDisplayName(widget.selectedBadge),
            ),
          ],
        ),
        16.gapH,
        InfoCard(
          icon: Icons.person_outline,
          iconColor: AppColors.lightYellow,
          title: AppString.personalInformationTitle,
          items: [
            InfoCardItem(label: AppString.fullName, value: widget.fullName),
            InfoCardItem(label: AppString.dateOfBirth, value: widget.dateOfBirth),
            InfoCardItem(label: AppString.gender, value: _getGenderDisplayName(widget.gender)),
            InfoCardItem(label: AppString.homeAddress, value: widget.address),
            InfoCardItem(label: AppString.contactNumber, value: '+63 ${widget.contactNumber}'),
          ],
        ),
        16.gapH,
        if (widget.existingId != null && widget.existingId!.isNotEmpty) ...[
          InfoCard(
            icon: Icons.verified_user_outlined,
            iconColor: AppColors.lightYellow,
            title: AppString.eligibilityDetailsTitle,
            items: [
              InfoCardItem(
                label: '${_getBadgeDisplayName(widget.selectedBadge)} ID',
                value: widget.existingId!,
              ),
            ],
          ),
          16.gapH,
        ],
        InfoCard(
          icon: Icons.description_outlined,
          iconColor: AppColors.lightYellow,
          title: AppString.uploadedDocumentTitle,
          items: [
            if (widget.selectedIdType != null)
              InfoCardItem(label: AppString.typeOfId, value: widget.selectedIdType!),
            InfoCardItem(
              customWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (widget.frontIdImage != null)
                        _buildImageItem(AppString.frontIdLabel, widget.frontIdImage!),
                      if (widget.frontIdImage != null && widget.backIdImage != null)
                        12.gapW,
                      if (widget.backIdImage != null)
                        _buildImageItem(AppString.backIdLabel, widget.backIdImage!),
                    ],
                  ),
                  if (widget.supportingFile != null) ...[
                    16.gapH,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _buildImageItem(
                            "Supporting Document", 
                            widget.supportingFile!, 
                            isFullWidth: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        24.gapH,
        _ConsentCheckbox(
          isChecked: widget.isConsentGiven,
          onChanged: widget.onConsentChanged,
          onValidationError: _showConsentError,
        ),
      ],
    );
  }
}

class _ConsentCheckbox extends StatelessWidget {
  final bool isChecked;
  final Function(bool) onChanged;
  final VoidCallback? onValidationError;

  const _ConsentCheckbox({
    required this.isChecked,
    required this.onChanged,
    this.onValidationError,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(D.radiusLG),
          border: Border.all(
            color: isChecked ? AppColors.primary : AppColors.grey.withOpacity(0.2),
            width: isChecked ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 15.h,
              width: 15.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isChecked ? AppColors.primary : AppColors.grey,
                  width: 1,
                ),
              ),
              child: isChecked
                  ? Center(
                      child: Container(
                        height: 8.h,
                        width: 8.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            12.gapW,
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: D.textXS,
                    color: AppColors.grey,
                    height: 1.5,
                    fontFamily: 'Segoe UI',
                  ),
                  children: [
                    TextSpan(text: AppString.consentText1),
                    TextSpan(
                      text: AppString.consentText2,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    TextSpan(text: AppString.consentText3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}