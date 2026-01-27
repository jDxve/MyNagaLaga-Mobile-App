import 'package:flutter/material.dart';
import '../../../common/resources/assets.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/widgets/text_input.dart';
import '../../../common/widgets/toggle.dart';
import 'otp_verification_form.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String? selectedSex = 'Male';

  @override
  void dispose() {
    emailController.dispose();
    fullNameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                70.gapH,
                Image.asset(
                  Assets.logo,
                  width: 120.w,
                  height: 85.h,
                  fit: BoxFit.contain,
                ),
                Text(
                  'Welcome back to MyNaga',
                  style: TextStyle(
                    fontSize: D.textLG,
                    fontWeight: D.bold,
                    color: AppColors.black,
                    fontFamily: 'Segoe UI',
                  ),
                ),
                4.gapH,
                Text(
                  'Sign in to your account',
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
                TextInput(
                  controller: emailController,
                  hintText: 'Enter your email address',
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.grey),
                  keyboardType: TextInputType.emailAddress,
                ),
                15.gapH,
                _buildLabel('Full Name'),
                8.gapH,
                TextInput(
                  controller: fullNameController,
                  hintText: 'Enter your first name',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.grey),
                ),
                15.gapH,
                _buildLabel('Complete Address'),
                8.gapH,
                TextInput(
                  controller: addressController,
                  hintText: 'Enter complete address',
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    color: AppColors.grey,
                  ),
                ),
                15.gapH,
                _buildLabel('Sex'),
                8.gapH,
                Toggle(
                  selectedValue: selectedSex,
                  onChanged: (value) => setState(() => selectedSex = value),
                  firstLabel: 'Male',
                  firstValue: 'Male',
                  secondLabel: 'Female',
                  secondValue: 'Female',
                ),
                40.gapH,
                PrimaryButton(
                  text: 'Sign In',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OtpVerificationForm(email: emailController.text),
                      ),
                    );
                  },
                ),
                10.gapH,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: TextStyle(
                        fontSize: D.textXS,
                        color: AppColors.black,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                    3.gapW,
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: D.textXS,
                          color: AppColors.primary,
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
