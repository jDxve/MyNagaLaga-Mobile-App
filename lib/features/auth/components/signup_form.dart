import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/resources/assets.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/widgets/text_input.dart';
import '../../../common/widgets/toggle.dart';
import '../../../common/utils/ui_utils.dart';
import '../../../common/widgets/error_modal.dart';
import '../notifier/auth_notifier.dart';
import 'otp_verification_form.dart';

class SignUpForm extends ConsumerStatefulWidget {
  const SignUpForm({super.key});

  @override
  ConsumerState<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends ConsumerState<SignUpForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? selectedSex = 'Male';

  @override
  void dispose() {
    emailController.dispose();
    fullNameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    final emailError = UIUtils.validateEmail(emailController.text);
    if (emailError != null) {
      showErrorModal(
        context: context,
        title: 'Invalid Email',
        description: emailError,
        icon: Icons.email_outlined,
        iconColor: Colors.orange,
      );
      return false;
    }

    final nameError = UIUtils.validateFullName(fullNameController.text);
    if (nameError != null) {
      showErrorModal(
        context: context,
        title: 'Invalid Name',
        description: nameError,
        icon: Icons.person_outline,
        iconColor: Colors.orange,
      );
      return false;
    }

    final addressError = UIUtils.validateAddress(addressController.text);
    if (addressError != null) {
      showErrorModal(
        context: context,
        title: 'Invalid Address',
        description: addressError,
        icon: Icons.location_on_outlined,
        iconColor: Colors.orange,
      );
      return false;
    }

    final phoneError = UIUtils.validatePhoneNumber(phoneController.text);
    if (phoneError != null) {
      showErrorModal(
        context: context,
        title: 'Invalid Phone Number',
        description: phoneError,
        icon: Icons.phone_outlined,
        iconColor: Colors.orange,
      );
      return false;
    }

    if (selectedSex == null) {
      showErrorModal(
        context: context,
        title: 'Sex Required',
        description: 'Please select your sex',
        icon: Icons.wc,
        iconColor: Colors.orange,
      );
      return false;
    }

    return true;
  }

  void _handleSignup() async {
    if (!_validateForm()) return;

    final signupNotifier = ref.read(signupNotifierProvider.notifier);

    await signupNotifier.requestSignupOtp(
      email: emailController.text.trim(),
      fullName: fullNameController.text.trim(),
      sex: selectedSex!,
      address: addressController.text.trim(),
      phoneNumber: phoneController.text.trim().isEmpty
          ? null
          : phoneController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signupNotifierProvider);

    ref.listen(signupNotifierProvider, (previous, next) {
      next.when(
        started: () {},
        loading: () {},
        success: (data) {
          if (data.sent) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpVerificationForm(
                  email: emailController.text.trim(),
                ),
              ),
            );
          }
        },
        error: (error) {
          showErrorModal(
            context: context,
            title: 'Signup Failed',
            description: error ?? 'Failed to send OTP. Please try again.',
            icon: Icons.error_outline,
            iconColor: Colors.red,
          );
        },
      );
    });

    final isLoading = signupState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Colors.white],
          stops: const [0.0, 0.45],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              70.gapH,
              Image.asset(
                Assets.logo,
                width: 120.w,
                height: 85.h,
                fit: BoxFit.contain,
              ),
              20.gapH,
              Text(
                'Welcome to MyNaga',
                style: TextStyle(
                  fontSize: D.textLG,
                  fontWeight: D.bold,
                  color: AppColors.black,
                  fontFamily: 'Segoe UI',
                ),
              ),
              4.gapH,
              Text(
                'Create your account',
                style: TextStyle(
                  fontSize: D.textBase,
                  fontWeight: D.semiBold,
                  color: AppColors.grey,
                  fontFamily: 'Segoe UI',
                ),
              ),
              30.gapH,
              _buildLabel('Email Address'),
              8.gapH,
              AbsorbPointer(
                absorbing: isLoading,
                child: Opacity(
                  opacity: isLoading ? 0.5 : 1.0,
                  child: TextInput(
                    controller: emailController,
                    hintText: 'Enter your email address',
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.grey),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ),
              15.gapH,
              _buildLabel('Full Name'),
              8.gapH,
              AbsorbPointer(
                absorbing: isLoading,
                child: Opacity(
                  opacity: isLoading ? 0.5 : 1.0,
                  child: TextInput(
                    controller: fullNameController,
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline, color: AppColors.grey),
                  ),
                ),
              ),
              15.gapH,
              _buildLabel('Complete Address'),
              8.gapH,
              AbsorbPointer(
                absorbing: isLoading,
                child: Opacity(
                  opacity: isLoading ? 0.5 : 1.0,
                  child: TextInput(
                    controller: addressController,
                    hintText: 'Enter complete address',
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ),
              15.gapH,
              _buildLabel('Phone Number (Optional)'),
              8.gapH,
              AbsorbPointer(
                absorbing: isLoading,
                child: Opacity(
                  opacity: isLoading ? 0.5 : 1.0,
                  child: TextInput(
                    controller: phoneController,
                    hintText: 'Enter phone number',
                    prefixIcon: Icon(Icons.phone_outlined, color: AppColors.grey),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ),
              15.gapH,
              _buildLabel('Sex'),
              8.gapH,
              AbsorbPointer(
                absorbing: isLoading,
                child: Opacity(
                  opacity: isLoading ? 0.5 : 1.0,
                  child: Toggle(
                    selectedValue: selectedSex,
                    onChanged: (value) {
                      setState(() {
                        selectedSex = value;
                      });
                    },
                    firstLabel: 'Male',
                    firstValue: 'Male',
                    secondLabel: 'Female',
                    secondValue: 'Female',
                  ),
                ),
              ),
              40.gapH,
              PrimaryButton(
                text: isLoading ? 'Sending OTP...' : 'Sign Up',
                onPressed: isLoading ? () {} : _handleSignup,
              ),
              20.gapH,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontSize: D.textSM,
                      color: AppColors.black,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                  GestureDetector(
                    onTap: isLoading ? null : () => Navigator.pop(context),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: D.textSM,
                        fontWeight: D.semiBold,
                        color: isLoading ? AppColors.grey : AppColors.primary,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: D.textBase,
        fontWeight: D.medium,
        color: AppColors.black,
        fontFamily: 'Segoe UI',
      ),
    );
  }
}