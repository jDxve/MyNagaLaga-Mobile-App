import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/strings.dart';
import '../../../common/utils/ui_utils.dart';
import '../../../common/widgets/error_modal.dart';
import '../../../common/widgets/text_input.dart';
import '../../../common/widgets/toggle.dart';

class BasicInfoPage extends StatefulWidget {
  final BuildContext context;
  final TextEditingController fullNameController;
  final TextEditingController dateOfBirthController;
  final String? selectedGender;
  final Function(String?) onGenderChanged;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final Function(VoidCallback) setIsFormValid;

  const BasicInfoPage({
    super.key,
    required this.context,
    required this.fullNameController,
    required this.dateOfBirthController,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.addressController,
    required this.phoneController,
    required this.setIsFormValid,
  });

  @override
  State<BasicInfoPage> createState() => _BasicInfoPageState();
}

class _BasicInfoPageState extends State<BasicInfoPage> {
  @override
  void initState() {
    super.initState();
    _initDefaults();
    _attachListeners();
  }

  void _initDefaults() {
    if (widget.selectedGender == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onGenderChanged('male'));
    }
  }

  void _attachListeners() {
    final controllers = [
      widget.fullNameController,
      widget.dateOfBirthController,
      widget.addressController,
      widget.phoneController
    ];
    for (var c in controllers) {
      c.addListener(_validateForm);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _validateForm());
  }

  @override
  void dispose() {
    widget.fullNameController.removeListener(_validateForm);
    widget.dateOfBirthController.removeListener(_validateForm);
    widget.addressController.removeListener(_validateForm);
    widget.phoneController.removeListener(_validateForm);
    super.dispose();
  }

  void _validateForm() {
    final isValid = UIUtils.validateFullName(widget.fullNameController.text) == null &&
        widget.dateOfBirthController.text.length == 10 &&
        UIUtils.validateAddress(widget.addressController.text) == null &&
        UIUtils.validatePhoneNumber(widget.phoneController.text) == null;

    widget.setIsFormValid(() {
      if (!isValid) _showValidationError();
    });
  }

  void _showValidationError() {
    final nameErr = UIUtils.validateFullName(widget.fullNameController.text);
    final addrErr = UIUtils.validateAddress(widget.addressController.text);
    final phoneErr = UIUtils.validatePhoneNumber(widget.phoneController.text);

    if (nameErr != null) {
      _triggerError(AppString.requiredFieldsMissingTitle, nameErr);
    } else if (widget.dateOfBirthController.text.length < 10) {
      _triggerError(AppString.requiredFieldsMissingTitle, "Please enter a valid date (MM/DD/YYYY)");
    } else if (addrErr != null) {
      _triggerError(AppString.requiredFieldsMissingTitle, addrErr);
    } else if (phoneErr != null) {
      _triggerError(AppString.invalidContactNumberTitle, phoneErr);
    }
  }

  void _triggerError(String title, String desc) {
    showErrorModal(
      context: widget.context,
      title: title,
      description: desc,
      icon: Icons.error_outline,
      iconColor: Colors.orange,
      buttonText: AppString.ok,
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: widget.context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      widget.dateOfBirthController.text = UIUtils.formatDateForDisplay(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(AppString.fullName),
        8.gapH,
        TextInput(
          controller: widget.fullNameController,
          hintText: AppString.fullNameHint,
          inputFormatters: [UIUtils.upperCaseWordsFormatter],
        ),
        20.gapH,
        _buildLabel(AppString.dateOfBirth),
        8.gapH,
        TextInput(
          controller: widget.dateOfBirthController,
          hintText: "MM/DD/YYYY",
          keyboardType: TextInputType.number,
          inputFormatters: [UIUtils.dateTextFormatter],
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today, color: AppColors.grey, size: 20.w),
            onPressed: _selectDate,
          ),
        ),
        20.gapH,
        _buildLabel(AppString.sex),
        8.gapH,
        Toggle(
          selectedValue: widget.selectedGender,
          onChanged: widget.onGenderChanged,
          firstLabel: AppString.male,
          secondLabel: AppString.female,
          firstValue: 'male',
          secondValue: 'female',
        ),
        20.gapH,
        _buildLabel(AppString.homeAddress),
        8.gapH,
        TextInput(
          controller: widget.addressController,
          hintText: AppString.homeAddressHint,
          maxLines: 3,
          inputFormatters: [UIUtils.upperCaseWordsFormatter],
        ),
        20.gapH,
        _buildLabel(AppString.contactNumber),
        8.gapH,
        TextInput(
          controller: widget.phoneController,
          hintText: AppString.contactNumberHint,
          keyboardType: TextInputType.phone,
          prefixText: AppString.phonePrefix,
          inputFormatters: [
            UIUtils.digitsOnly,
            UIUtils.lengthLimit(10),
            UIUtils.phoneNumberFormatter,
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: D.textBase,
        fontWeight: D.semiBold,
        color: Colors.black,
        fontFamily: 'Segoe UI',
      ),
    );
  }
}