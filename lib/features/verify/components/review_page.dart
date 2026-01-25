import 'dart:io';
import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/strings.dart';
import '../../../common/widgets/error_modal.dart';

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
      case 'senior_citizen':
        return AppString.seniorCitizenTitle;
      case 'pwd':
        return AppString.pwdTitle;
      case 'solo_parent':
        return AppString.soloParentTitle;
      case 'indigent':
        return AppString.indigentTitle;
      case 'student':
        return AppString.studentTitle;
      default:
        return 'Unknown';
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
        _ReviewSection(
          icon: Icons.badge_outlined,
          iconColor: AppColors.lightYellow,
          title: AppString.step1Title,
          children: [
            _ReviewItem(
              label: AppString.selectedBadgeLabel,
              value: _getBadgeDisplayName(widget.selectedBadge),
            ),
          ],
        ),
        16.gapH,

        _ReviewSection(
          icon: Icons.person_outline,
          iconColor: AppColors.lightYellow,
          title: AppString.personalInformationTitle,
          children: [
            _ReviewItem(label: AppString.fullName, value: widget.fullName),
            _ReviewItem(
              label: AppString.dateOfBirth,
              value: widget.dateOfBirth,
            ),
            _ReviewItem(
              label: AppString.gender,
              value: _getGenderDisplayName(widget.gender),
            ),
            _ReviewItem(label: AppString.homeAddress, value: widget.address),
            _ReviewItem(
              label: AppString.contactNumber,
              value: '+63 ${widget.contactNumber}',
            ),
          ],
        ),
        16.gapH,

        if (widget.existingId != null && widget.existingId!.isNotEmpty) ...[
          _ReviewSection(
            icon: Icons.verified_user_outlined,
            iconColor: AppColors.lightYellow,
            title: AppString.eligibilityDetailsTitle,
            children: [
              _ReviewItem(
                label: '${_getBadgeDisplayName(widget.selectedBadge)} ID',
                value: widget.existingId!,
              ),
            ],
          ),
          16.gapH,
        ],

        _ReviewSection(
          icon: Icons.description_outlined,
          iconColor: AppColors.lightYellow,
          title: AppString.uploadedDocumentTitle,
          children: [
            if (widget.selectedIdType != null)
              _ReviewItem(
                label: AppString.typeOfId,
                value: widget.selectedIdType!,
              ),
            12.gapH,
            if (widget.frontIdImage != null || widget.backIdImage != null)
              Row(
                children: [
                  if (widget.frontIdImage != null)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showImagePreview(widget.frontIdImage!),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppString.frontIdLabel,
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
                                widget.frontIdImage!,
                                height: 100.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (widget.frontIdImage != null && widget.backIdImage != null)
                    12.gapW,
                  if (widget.backIdImage != null)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showImagePreview(widget.backIdImage!),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppString.backIdLabel,
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
                                widget.backIdImage!,
                                height: 100.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
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

class _ReviewSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;

  const _ReviewSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(D.radiusLG),
        border: Border.all(color: AppColors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(D.radiusMD),
                ),
                child: Icon(icon, color: Colors.black, size: 20.w),
              ),
              12.gapW,
              Text(
                title,
                style: TextStyle(
                  fontSize: D.textBase,
                  fontWeight: D.semiBold,
                  color: Colors.black,
                  fontFamily: 'Segoe UI',
                ),
              ),
            ],
          ),
          16.gapH,
          ...children,
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: D.textSM,
                color: AppColors.grey,
                fontFamily: 'Segoe UI',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: D.textSM,
                fontWeight: D.medium,
                color: Colors.black,
                fontFamily: 'Segoe UI',
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
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
            color: isChecked
                ? AppColors.primary
                : AppColors.grey.withOpacity(0.2),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
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