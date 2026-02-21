import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/strings.dart';
import '../../../common/utils/ui_utils.dart';
import '../../../common/widgets/text_input.dart';
import '../../../common/widgets/error_modal.dart';
import '../../../common/widgets/upload_image_card.dart';
import '../../../common/models/dio/data_state.dart';
import '../notifier/badge_requirements_notifier.dart';
import '../models/badge_requirement_model.dart';

class DocumentPage extends ConsumerStatefulWidget {
  final BuildContext context;
  final String badgeTypeId;
  final String? selectedIdType;
  final Map<String, List<File>> uploadedFiles;
  final Function(String?) onIdTypeChanged;
  final Function(String key, List<File> files) onFilesChanged;
  final Function(bool isValid, VoidCallback showError)? setIsFormValid;

  const DocumentPage({
    super.key,
    required this.context,
    required this.badgeTypeId,
    required this.selectedIdType,
    required this.uploadedFiles,
    required this.onIdTypeChanged,
    required this.onFilesChanged,
    this.setIsFormValid,
  });

  @override
  ConsumerState<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends ConsumerState<DocumentPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _idTypeController = TextEditingController();
  final LayerLink _layerLink = LayerLink();

  bool _isDropdownOpen = false;
  OverlayEntry? _overlayEntry;
  String? _selectedIdType;

  @override
  void initState() {
    super.initState();
    _selectedIdType = widget.selectedIdType;
    _idTypeController.text = widget.selectedIdType ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.badgeTypeId.isNotEmpty) {
        ref.read(badgeRequirementsNotifierProvider.notifier).fetch(widget.badgeTypeId);
      }
      _validateForm();
    });
  }

  @override
  void didUpdateWidget(DocumentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.badgeTypeId != widget.badgeTypeId && widget.badgeTypeId.isNotEmpty) {
      ref.read(badgeRequirementsNotifierProvider.notifier).fetch(widget.badgeTypeId);
      _validateForm();
    }
  }

  // Called only when the parent wizard explicitly presses Next/Submit.
  void _onSubmitAttempt() {
    _showValidationError();
  }

  void _validateForm() {
    final requirementsState = ref.read(badgeRequirementsNotifierProvider)[widget.badgeTypeId];

    if (requirementsState is! Success<BadgeRequirementsData>) {
      widget.setIsFormValid?.call(false, _onSubmitAttempt);
      return;
    }

    final requirements = requirementsState.data.requirements;
    bool isValid = _selectedIdType != null && _selectedIdType!.isNotEmpty;

    for (var req in requirements) {
      final files = widget.uploadedFiles[req.key] ?? [];
      if (req.isRequired && files.isEmpty) {
        isValid = false;
        break;
      }
    }

    widget.setIsFormValid?.call(isValid, _onSubmitAttempt);
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

    final requirementsState = ref.read(badgeRequirementsNotifierProvider)[widget.badgeTypeId];
    if (requirementsState is! Success<BadgeRequirementsData>) return;

    final requirements = requirementsState.data.requirements;
    final List<String> missingItems = [];

    for (var req in requirements) {
      final files = widget.uploadedFiles[req.key] ?? [];
      if (req.isRequired && files.isEmpty) {
        missingItems.add(req.label);
      }
    }

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

  Future<void> _pickImage(ImageSource source, String requirementKey, int maxFiles) async {
    try {
      final currentFiles = widget.uploadedFiles[requirementKey] ?? [];
      if (currentFiles.length >= maxFiles) {
        showErrorModal(
          context: widget.context,
          title: 'Maximum Files Reached',
          description: 'You can only upload up to $maxFiles file(s) for this requirement.',
          icon: Icons.warning_outlined,
          iconColor: Colors.orange,
          buttonText: AppString.ok,
        );
        return;
      }

      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 90,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: AppString.cropIdCard,
              toolbarColor: AppColors.primary,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.ratio3x2,
            ),
            IOSUiSettings(title: AppString.cropIdCard),
          ],
        );

        if (croppedFile != null) {
          final updatedFiles = List<File>.from(currentFiles);
          updatedFiles.add(File(croppedFile.path));
          widget.onFilesChanged(requirementKey, updatedFiles);
          _validateForm();
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _removeFile(String requirementKey, int index) {
    final currentFiles = List<File>.from(widget.uploadedFiles[requirementKey] ?? []);
    currentFiles.removeAt(index);
    widget.onFilesChanged(requirementKey, currentFiles);
    _validateForm();
    setState(() {});
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
                itemCount: UIUtils.idTypes.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      UIUtils.idTypes[index],
                      style: const TextStyle(fontFamily: 'Segoe UI'),
                    ),
                    onTap: () {
                      setState(() {
                        _idTypeController.text = UIUtils.idTypes[index];
                        _selectedIdType = UIUtils.idTypes[index];
                      });
                      widget.onIdTypeChanged(UIUtils.idTypes[index]);
                      _removeOverlay();
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
    if (widget.badgeTypeId.isEmpty) {
      return const Center(child: Text('Please select a badge type'));
    }

    final requirementsState = ref.watch(badgeRequirementsNotifierProvider)[widget.badgeTypeId];

    return requirementsState?.when(
          started: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(error ?? 'Failed to load requirements'),
                16.gapH,
                TextButton(
                  onPressed: () =>
                      ref.read(badgeRequirementsNotifierProvider.notifier).fetch(widget.badgeTypeId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          success: (data) => _buildContent(data.requirements),
        ) ??
        const SizedBox.shrink();
  }

  Widget _buildContent(List<BadgeRequirement> requirements) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppString.typeOfId,
            style: TextStyle(
              fontSize: D.textBase,
              fontWeight: D.semiBold,
              fontFamily: 'Segoe UI',
            ),
          ),
          8.gapH,
          CompositedTransformTarget(
            link: _layerLink,
            child: GestureDetector(
              onTap: _toggleDropdown,
              child: AbsorbPointer(
                child: TextInput(
                  controller: _idTypeController,
                  hintText: AppString.selectTypeOfId,
                  suffixIcon: Icon(
                    _isDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  ),
                ),
              ),
            ),
          ),
          24.gapH,
          ...requirements.map((req) => _buildRequirementSection(req)),
          _buildTipsSection(),
          24.gapH,
        ],
      ),
    );
  }

  Widget _buildRequirementSection(BadgeRequirement requirement) {
    final files = widget.uploadedFiles[requirement.key] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                requirement.label,
                style: TextStyle(
                  fontSize: D.textBase,
                  fontWeight: D.semiBold,
                  fontFamily: 'Segoe UI',
                  color: AppColors.black,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: requirement.isRequired
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                requirement.isRequired ? 'Required' : 'Optional',
                style: TextStyle(
                  fontSize: D.textXS,
                  color: requirement.isRequired ? AppColors.primary : AppColors.grey,
                  fontWeight: D.medium,
                ),
              ),
            ),
          ],
        ),
        12.gapH,
        ...files.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: UploadImage(
              image: entry.value,
              title: requirement.label,
              onTap: () => _showImagePreview(entry.value),
              onRemove: () => _removeFile(requirement.key, entry.key),
            ),
          );
        }),
        if (files.length < requirement.maxFiles)
          UploadImage(
            title: requirement.label,
            subtitle: AppString.takePhotoOrUpload,
            onPickImage: (source) => _pickImage(source, requirement.key, requirement.maxFiles),
          ),
        24.gapH,
      ],
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
          Text(
            AppString.tipsForGoodCapture,
            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Segoe UI'),
          ),
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
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.grey,
                fontSize: D.textSM,
                fontFamily: 'Segoe UI',
              ),
            ),
          ),
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
    _idTypeController.dispose();
    _removeOverlay(isDisposing: true);
    super.dispose();
  }
}