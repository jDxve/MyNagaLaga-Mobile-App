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

class SoloParentServicesPage extends StatefulWidget {
  final String userName;
  final String userAge;

  const SoloParentServicesPage({
    super.key,
    required this.userName,
    required this.userAge,
  });

  @override
  State<SoloParentServicesPage> createState() => _SoloParentServicesPageState();
}

class _SoloParentServicesPageState extends State<SoloParentServicesPage> {
  String? selectedRecipient = Constant.forMe;
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController familyMemberController = TextEditingController();
  final TextEditingController applicationTypeController = TextEditingController();
  
  // List to store multiple children
  List<TextEditingController> childrenControllers = [TextEditingController()];
  
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
    applicationTypeController.dispose();
    for (var controller in childrenControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addChildField() {
    setState(() {
      childrenControllers.add(TextEditingController());
    });
  }

  void _removeChildField(int index) {
    setState(() {
      childrenControllers[index].dispose();
      childrenControllers.removeAt(index);
    });
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
        title: 'Solo Parent Services',
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
                    InfoCardItem(
                      label: AppString.age,
                      value: widget.userAge,
                    ),
                  ],
                ),
                20.gapH,
                _buildReasonSection(),
                20.gapH,
                _buildAttachedBadge(),
                24.gapH,
              ] else ...[
                _buildFamilyMemberForm(),
              ],
              PrimaryButton(
                text: AppString.submitRequest,
                onPressed: () {
                  // Handle submit
                },
              ),
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
            'Maria Santos (Spouse)',
            'John Santos (Son)',
            'Jane Santos (Daughter)',
            'Jose Santos (Father)',
          ],
        ),
        20.gapH,
        _buildLabel('Application Type'),
        8.gapH,
        Dropdown(
          controller: applicationTypeController,
          hintText: 'Select type',
          items: const [
            'New Application',
            'Renewal',
            'Lost ID Replacement',
          ],
        ),
        16.gapH,
        _buildChildrenNamesSection(),
        20.gapH,
        _buildUploadSection(),
        20.gapH,
        _buildReasonSection(),
        24.gapH,
      ],
    );
  }

  Widget _buildChildrenNamesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Names of Children'),
        8.gapH,
        ...List.generate(childrenControllers.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: TextInput(
              controller: childrenControllers[index],
              hintText: 'Enter name',
              suffixIcon: childrenControllers.length > 1
                  ? GestureDetector(
                      onTap: () => _removeChildField(index),
                      child: Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                        size: 20.w,
                      ),
                    )
                  : null,
            ),
          );
        }),
        GestureDetector(
          onTap: _addChildField,
          child: Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: AppColors.black,
                size: 24.w,
              ),
              8.gapW,
              Text(
                'Add another child',
                style: TextStyle(
                  fontSize: D.textSM,
                  color: AppColors.black,
                  fontFamily: 'Segoe UI',
                ),
              ),
            ],
          ),
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
          'e.g. Solo Parent ID, Birth Certificate of children',
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
            Assets.soloParentBadge,
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