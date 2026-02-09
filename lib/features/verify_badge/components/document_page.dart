import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/strings.dart';
import '../../../common/utils/ui_utils.dart'; // ADD THIS IMPORT
import '../../../common/widgets/secondary_button.dart';
import '../../../common/widgets/text_input.dart';
import '../../../common/widgets/error_modal.dart';
import '../../../common/widgets/upload_image_card.dart';

class DocumentPage extends StatefulWidget {
  final BuildContext context;
  final String? selectedIdType;
  final File? frontImage;
  final File? backImage;
  final File? supportingFile;
  final Function(String?) onIdTypeChanged;
  final Function(File?) onFrontImageChanged;
  final Function(File?) onBackImageChanged;
  final Function(File?) onSupportingFileChanged;
  final Function(bool isValid, VoidCallback showError)? setIsFormValid;

  const DocumentPage({
    super.key,
    required this.context,
    required this.selectedIdType,
    this.frontImage,
    this.backImage,
    this.supportingFile,
    required this.onIdTypeChanged,
    required this.onFrontImageChanged,
    required this.onBackImageChanged,
    required this.onSupportingFileChanged,
    this.setIsFormValid,
  });

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  final ImagePicker _picker = ImagePicker();
  final PageController _pageController = PageController();
  final TextEditingController _idTypeController = TextEditingController();
  final LayerLink _layerLink = LayerLink();

  bool _isDropdownOpen = false;
  OverlayEntry? _overlayEntry;
  int _currentPage = 0;
  String? _selectedIdType;

  // REMOVED: local idTypes list - now using UIUtils.idTypes

  @override
  void initState() {
    super.initState();
    _selectedIdType = widget.selectedIdType;
    _idTypeController.text = widget.selectedIdType ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) => _validateForm());
  }

  void _validateForm() {
    bool isValid = _selectedIdType != null &&
        _selectedIdType!.isNotEmpty &&
        widget.frontImage != null &&
        widget.backImage != null &&
        widget.supportingFile != null;
    widget.setIsFormValid?.call(isValid, _showValidationError);
  }

  void _showValidationError() {
    if (_selectedIdType == null || _selectedIdType!.isEmpty) {
      showErrorModal(
        context: widget.context,
        title: AppString.idTypeNotSelectedTitle,
        description: AppString.idTypeNotSelectedDescription,
        icon: Icons.badge_outlined,
        iconColor: Colors.orange,
        buttonText: AppString.ok,
      );
      return;
    }
    List<String> missingItems = [];
    if (widget.frontImage == null) missingItems.add(AppString.frontOfId);
    if (widget.backImage == null) missingItems.add(AppString.backOfId);
    if (widget.supportingFile == null) missingItems.add("Supporting File");

    if (missingItems.isNotEmpty) {
      showErrorModal(
        context: widget.context,
        title: AppString.requiredItemsMissingTitle,
        description: '${AppString.requiredItemsMissingDescription}${missingItems.join(', ')}',
        icon: Icons.image_outlined,
        iconColor: Colors.orange,
        buttonText: AppString.ok,
      );
    }
  }

  Future<void> _pickImage(ImageSource source, {required bool isSupporting}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 90,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: isSupporting ? "Crop Supporting File" : AppString.cropIdCard,
              toolbarColor: AppColors.primary,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.ratio3x2,
            ),
            IOSUiSettings(title: AppString.cropIdCard),
          ],
        );

        if (croppedFile != null) {
          if (isSupporting) {
            widget.onSupportingFileChanged(File(croppedFile.path));
          } else {
            if (_currentPage == 0) {
              widget.onFrontImageChanged(File(croppedFile.path));
            } else {
              widget.onBackImageChanged(File(croppedFile.path));
            }
          }
          _validateForm();
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    _overlayEntry = _createOverlayEntry(renderBox.size.width);
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isDropdownOpen = true);
  }

  void _removeOverlay({bool isDisposing = false}) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (!isDisposing && mounted) {
      setState(() => _isDropdownOpen = false);
    }
  }

  OverlayEntry _createOverlayEntry(double width) {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, 42.h),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(D.radiusLG),
            child: Container(
              constraints: BoxConstraints(maxHeight: 250.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(D.radiusLG),
                border: Border.all(color: AppColors.grey.withOpacity(0.2)),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: UIUtils.idTypes.length, // CHANGED: Use UIUtils.idTypes
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(UIUtils.idTypes[index], style: const TextStyle(fontFamily: 'Segoe UI')), // CHANGED
                    onTap: () {
                      setState(() {
                        _idTypeController.text = UIUtils.idTypes[index]; // CHANGED
                        _selectedIdType = UIUtils.idTypes[index]; // CHANGED
                      });
                      widget.onIdTypeChanged(UIUtils.idTypes[index]); // CHANGED
                      _toggleDropdown();
                      _validateForm();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppString.typeOfId, style: TextStyle(fontSize: D.textBase, fontWeight: D.semiBold, fontFamily: 'Segoe UI')),
          8.gapH,
          CompositedTransformTarget(
            link: _layerLink,
            child: GestureDetector(
              onTap: _toggleDropdown,
              child: AbsorbPointer(
                child: TextInput(
                  controller: _idTypeController,
                  hintText: AppString.selectTypeOfId,
                  suffixIcon: Icon(_isDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                ),
              ),
            ),
          ),
          24.gapH,
          SizedBox(
            height: 200.h,
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                UploadImage(
                  image: widget.frontImage,
                  title: AppString.uploadFrontId,
                  subtitle: AppString.takePhotoOrUpload,
                  onTap: () => _showImagePreview(widget.frontImage!),
                  onRemove: () {
                    widget.onFrontImageChanged(null);
                    _validateForm();
                    setState(() {});
                  },
                ),
                UploadImage(
                  image: widget.backImage,
                  title: AppString.uploadBackId,
                  subtitle: AppString.takePhotoOrUpload,
                  onTap: () => _showImagePreview(widget.backImage!),
                  onRemove: () {
                    widget.onBackImageChanged(null);
                    _validateForm();
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          12.gapH,
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(2, (index) => _buildPageIndicator(index))),
          16.gapH,
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: AppString.takePhoto,
                  isFilled: true,
                  icon: Icons.camera_alt_outlined,
                  onPressed: () => _pickImage(ImageSource.camera, isSupporting: false),
                ),
              ),
              12.gapW,
              Expanded(
                child: SecondaryButton(
                  text: AppString.upload,
                  icon: Icons.file_upload_outlined,
                  onPressed: () => _pickImage(ImageSource.gallery, isSupporting: false),
                ),
              ),
            ],
          ),
          24.gapH,
          Text("Upload a supporting file", style: TextStyle(fontSize: D.textBase, fontWeight: D.semiBold, fontFamily: 'Segoe UI', color: AppColors.black)),
          Text("e.g Birth Certificate, Barangay clearance", style: TextStyle(fontSize: D.textSM, color: AppColors.grey, fontFamily: 'Segoe UI')),
          12.gapH,
          UploadImage(
            image: widget.supportingFile,
            title: "Upload your ID",

            onPickImage: (source) => _pickImage(source, isSupporting: true),
            onRemove: () {
              widget.onSupportingFileChanged(null);
              _validateForm();
              setState(() {});
            },
            onTap: () => _showImagePreview(widget.supportingFile!),
          ),
          24.gapH,
          _buildTipsSection(),
          24.gapH,
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      height: 7.h,
      width: (isActive ? 30 : 7).w,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildTipsSection() {
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
          Text(AppString.tipsForGoodCapture, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Segoe UI')),
          const SizedBox(height: 12),
          _tipRow(AppString.tip1),
          _tipRow(AppString.tip2),
          _tipRow(AppString.tip3),
          _tipRow(AppString.tip4),
        ],
      ),
    );
  }

  Widget _tipRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.grey)),
          Expanded(child: Text(text, style: TextStyle(color: AppColors.grey, fontSize: D.textSM, fontFamily: 'Segoe UI'))),
        ],
      ),
    );
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(D.radiusLG),
            child: Image.file(image, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _idTypeController.dispose();
    _removeOverlay(isDisposing: true);
    super.dispose();
  }
}