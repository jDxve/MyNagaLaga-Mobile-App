import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/images_icons.dart';
import '../../../common/resources/strings.dart';
import '../../../common/widgets/secondary_button.dart';
import '../../../common/widgets/text_input.dart';
import '../../../common/widgets/error_modal.dart';

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
  static const Color darkYellow = Color(0xFFE5C565);
  final ImagePicker _picker = ImagePicker();
  final PageController _pageController = PageController();
  final TextEditingController _idTypeController = TextEditingController();
  final LayerLink _layerLink = LayerLink();

  bool _isDropdownOpen = false;
  OverlayEntry? _overlayEntry;
  int _currentPage = 0;
  String? _selectedIdType;

  final List<String> idTypes = [
    AppString.nationalId,
    AppString.driversLicense,
    AppString.passport,
    AppString.votersId,
    AppString.philhealthId,
    AppString.sssId,
    AppString.umid,
    AppString.postalId,
  ];

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

  Future<void> _pickImage(ImageSource source, {bool isSupporting = false}) async {
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

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isDropdownOpen = false);
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
                itemCount: idTypes.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(idTypes[index], style: const TextStyle(fontFamily: 'Segoe UI')),
                    onTap: () {
                      setState(() {
                        _idTypeController.text = idTypes[index];
                        _selectedIdType = idTypes[index];
                      });
                      widget.onIdTypeChanged(idTypes[index]);
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
                _buildImageCard(widget.frontImage, AppString.uploadFrontId, () => widget.onFrontImageChanged(null)),
                _buildImageCard(widget.backImage, AppString.uploadBackId, () => widget.onBackImageChanged(null)),
              ],
            ),
          ),
          12.gapH,
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(2, (index) => _buildPageIndicator(index))),
          16.gapH,
          _buildActionButtons(isSupporting: false),
          24.gapH,
          Text("Upload a supporting file", style: TextStyle(fontSize: D.textBase, fontWeight: D.semiBold, fontFamily: 'Segoe UI')),
          Text("e.g Birth Certificate, Barangay clearance", style: TextStyle(fontSize: D.textSM, color: AppColors.grey, fontFamily: 'Segoe UI')),
          12.gapH,
          _buildImageCard(widget.supportingFile, "Upload your ID", () => widget.onSupportingFileChanged(null), isSupporting: true),
          16.gapH,
          _buildActionButtons(isSupporting: true),
          24.gapH,
          _buildTipsSection(),
          24.gapH,
        ],
      ),
    );
  }

  Widget _buildActionButtons({required bool isSupporting}) {
    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            text: AppString.takePhoto,
            isFilled: true,
            icon: Icons.camera_alt_outlined,
            onPressed: () => _pickImage(ImageSource.camera, isSupporting: isSupporting),
          ),
        ),
        12.gapW,
        Expanded(
          child: SecondaryButton(
            text: AppString.upload,
            icon: Icons.file_upload_outlined,
            onPressed: () => _pickImage(ImageSource.gallery, isSupporting: isSupporting),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard(File? image, String uploadText, VoidCallback onRemove, {bool isSupporting = false}) {
    return GestureDetector(
      onTap: image != null ? () => _showImagePreview(image) : null,
      child: CustomPaint(
        painter: DashedRectPainter(color: AppColors.grey.withOpacity(0.3)),
        child: Container(
          height: 200.h,
          width: double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(D.radiusLG)),
          child: image != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(borderRadius: BorderRadius.circular(D.radiusLG), child: Image.file(image, fit: BoxFit.cover)),
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: GestureDetector(
                        onTap: () {
                          onRemove();
                          _validateForm();
                          setState(() {});
                        },
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.7), shape: BoxShape.circle),
                          child: Icon(Icons.close, color: Colors.white, size: 16.w),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(color: darkYellow.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: SvgPicture.asset(AppImages.imageUploadIcon, width: 32.w, height: 32.w, colorFilter: const ColorFilter.mode(darkYellow, BlendMode.srcIn)),
                    ),
                    12.gapH,
                    Text(uploadText, style: TextStyle(fontSize: D.textBase, fontWeight: FontWeight.bold, fontFamily: 'Segoe UI')),
                    4.gapH,
                    Text(AppString.takePhotoOrUpload, style: TextStyle(fontSize: D.textSM, color: AppColors.grey, fontFamily: 'Segoe UI')),
                  ],
                ),
        ),
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
    _removeOverlay();
    super.dispose();
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 6, dashSpace = 4;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    RRect rrect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(D.radiusLG));
    Path path = Path()..addRRect(rrect);

    for (var measurePath in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < measurePath.length) {
        canvas.drawPath(measurePath.extractPath(distance, distance + dashWidth), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}