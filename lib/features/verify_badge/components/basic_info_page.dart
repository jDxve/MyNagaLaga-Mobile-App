import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/strings.dart';
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
    if (widget.selectedGender == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onGenderChanged('male');
      });
    }
    widget.fullNameController.addListener(_validateForm);
    widget.dateOfBirthController.addListener(_validateForm);
    widget.addressController.addListener(_validateForm);
    widget.phoneController.addListener(_validateForm);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateForm();
    });
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
    bool isValid = widget.fullNameController.text.trim().isNotEmpty &&
        widget.dateOfBirthController.text.trim().isNotEmpty &&
        widget.addressController.text.trim().isNotEmpty &&
        widget.phoneController.text.trim().isNotEmpty &&
        widget.phoneController.text.trim().length >= 10;
    widget.setIsFormValid(() {
      if (!isValid) {
        _showValidationError();
      }
    });
  }

  void _showValidationError() {
    List<String> missingFields = [];
    if (widget.fullNameController.text.trim().isEmpty) {
      missingFields.add(AppString.fullName);
    }
    if (widget.dateOfBirthController.text.trim().isEmpty) {
      missingFields.add(AppString.dateOfBirth);
    }
    if (widget.addressController.text.trim().isEmpty) {
      missingFields.add(AppString.homeAddress);
    }
    if (widget.phoneController.text.trim().isEmpty) {
      missingFields.add(AppString.contactNumber);
    } else if (widget.phoneController.text.trim().length < 10) {
      showErrorModal(
        context: widget.context,
        title: AppString.invalidContactNumberTitle,
        description: AppString.invalidContactNumberDescription,
        icon: Icons.phone_outlined,
        iconColor: Colors.orange,
        buttonText: AppString.ok,
      );
      return;
    }
    if (missingFields.isNotEmpty) {
      String fieldsList = missingFields.join(', ');
      showErrorModal(
        context: widget.context,
        title: AppString.requiredFieldsMissingTitle,
        description: '${AppString.requiredFieldsMissingDescription}$fieldsList',
        icon: Icons.error_outline,
        iconColor: Colors.orange,
        buttonText: AppString.ok,
      );
    }
  }

  bool get isFormValid {
    return widget.fullNameController.text.trim().isNotEmpty &&
        widget.dateOfBirthController.text.trim().isNotEmpty &&
        widget.addressController.text.trim().isNotEmpty &&
        widget.phoneController.text.trim().isNotEmpty &&
        widget.phoneController.text.trim().length >= 10;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: widget.context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      widget.dateOfBirthController.text = DateFormat('MM/dd/yyyy').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.fullName,
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.semiBold,
            color: Colors.black,
            fontFamily: 'Segoe UI',
          ),
        ),
        8.gapH,
        TextInput(
          controller: widget.fullNameController,
          hintText: AppString.fullNameHint,
        ),
        20.gapH,
        Text(
          AppString.dateOfBirth,
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.semiBold,
            color: Colors.black,
            fontFamily: 'Segoe UI',
          ),
        ),
        8.gapH,
        TextInput(
          controller: widget.dateOfBirthController,
          hintText: AppString.dateOfBirthHint,
          keyboardType: TextInputType.datetime,
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today, color: AppColors.grey, size: 20.w),
            onPressed: _selectDate,
          ),
        ),
        20.gapH,
        Text(
          AppString.sex,
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.semiBold,
            color: Colors.black,
            fontFamily: 'Segoe UI',
          ),
        ),
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
        Text(
          AppString.homeAddress,
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.semiBold,
            color: Colors.black,
            fontFamily: 'Segoe UI',
          ),
        ),
        8.gapH,
        TextInput(
          controller: widget.addressController,
          hintText: AppString.homeAddressHint,
          maxLines: 3,
        ),
        20.gapH,
        Text(
          AppString.contactNumber,
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.semiBold,
            color: Colors.black,
            fontFamily: 'Segoe UI',
          ),
        ),
        8.gapH,
        TextInput(
          controller: widget.phoneController,
          hintText: AppString.contactNumberHint,
          keyboardType: TextInputType.phone,
          prefixText: AppString.phonePrefix,
        ),
      ],
    );
  }
}