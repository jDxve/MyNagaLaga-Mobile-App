import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/strings.dart';
import '../../../common/widgets/text_input.dart';

class EligibilityForm extends StatefulWidget {
  final BuildContext context;
  final String selectedBadge;
  final TextEditingController existingIdController;

  const EligibilityForm({
    super.key,
    required this.context,
    required this.selectedBadge,
    required this.existingIdController,
  });

  @override
  State<EligibilityForm> createState() => _EligibilityFormState();
}

class _EligibilityFormState extends State<EligibilityForm> {
  @override
  Widget build(BuildContext context) {
    return _buildBadgeSpecificForm();
  }

  Widget _buildBadgeSpecificForm() {
    switch (widget.selectedBadge) {
      case 'senior_citizen':
        return _buildSeniorCitizenForm();
      case 'pwd':
        return _buildPWDForm();
      case 'solo_parent':
        return _buildSoloParentForm();
      case 'indigent':
        return _buildIndigentForm();
      case 'student':
        return _buildStudentForm();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildSeniorCitizenForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.existingSeniorCitizenId,
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.semiBold,
            color: Colors.black,
            fontFamily: 'Segoe UI',
          ),
        ),
        8.gapH,
        TextInput(
          controller: widget.existingIdController,
          hintText: AppString.existingIdHint,
        ),
        16.gapH,
        _BenefitsCard(
          title: AppString.seniorCitizenBenefitsTitle,
          benefits: [
            AppString.seniorBenefit1,
            AppString.seniorBenefit2,
            AppString.seniorBenefit3,
          ],
          color: AppColors.lightYellow,
        ),
      ],
    );
  }

  Widget _buildPWDForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.existingPwdId,
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.semiBold,
            color: Colors.black,
            fontFamily: 'Segoe UI',
          ),
        ),
        8.gapH,
        TextInput(
          controller: widget.existingIdController,
          hintText: AppString.existingIdHint,
        ),
        16.gapH,
        _BenefitsCard(
          title: AppString.pwdBenefitsTitle,
          benefits: [
            AppString.pwdBenefit1,
            AppString.pwdBenefit2,
            AppString.pwdBenefit3,
          ],
          color: AppColors.lightPink,
        ),
      ],
    );
  }

  Widget _buildSoloParentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.existingSoloParentId,
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.semiBold,
            color: Colors.black,
            fontFamily: 'Segoe UI',
          ),
        ),
        8.gapH,
        TextInput(
          controller: widget.existingIdController,
          hintText: AppString.existingIdHint,
        ),
        16.gapH,
        _BenefitsCard(
          title: AppString.soloParentBenefitsTitle,
          benefits: [
            AppString.soloParentBenefit1,
            AppString.soloParentBenefit2,
            AppString.soloParentBenefit3,
          ],
          color: AppColors.lightPurple,
        ),
      ],
    );
  }

  Widget _buildIndigentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.existingIndigentId,
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.semiBold,
            color: Colors.black,
            fontFamily: 'Segoe UI',
          ),
        ),
        8.gapH,
        TextInput(
          controller: widget.existingIdController,
          hintText: AppString.existingIdHint,
        ),
        16.gapH,
        _BenefitsCard(
          title: AppString.indigentBenefitsTitle,
          benefits: [
            AppString.indigentBenefit1,
            AppString.indigentBenefit2,
            AppString.indigentBenefit3,
          ],
          color: AppColors.lightPrimary,
        ),
      ],
    );
  }

  Widget _buildStudentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.existingStudentId,
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.semiBold,
            color: Colors.black,
            fontFamily: 'Segoe UI',
          ),
        ),
        8.gapH,
        TextInput(
          controller: widget.existingIdController,
          hintText: AppString.existingIdHint,
        ),
        16.gapH,
        _BenefitsCard(
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

class _BenefitsCard extends StatelessWidget {
  final String title;
  final List<String> benefits;
  final Color color;

  const _BenefitsCard({
    required this.title,
    required this.benefits,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(D.radiusLG),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: D.textBase,
              fontWeight: D.semiBold,
              color: Colors.black,
              fontFamily: 'Segoe UI',
            ),
          ),
          12.gapH,
          ...benefits.map(
            (benefit) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      fontSize: D.textSM,
                      color: AppColors.grey,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                  Expanded(
                    child: Text(
                      benefit,
                      style: TextStyle(
                        fontSize: D.textSM,
                        color: AppColors.grey,
                        height: 1.4,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}