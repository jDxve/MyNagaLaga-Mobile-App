import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/strings.dart';
import '../../../common/widgets/text_input.dart';
import '../../../common/widgets/error_modal.dart';
import 'benefits_card.dart';

class PwdForm extends StatefulWidget {
  final TextEditingController existingIdController;
  final Function(bool isValid, VoidCallback showError)? setIsFormValid;

  const PwdForm({
    super.key,
    required this.existingIdController,
    this.setIsFormValid,
  });

  @override
  State<PwdForm> createState() => _PwdFormState();
}

class _PwdFormState extends State<PwdForm> {
  final TextEditingController _disabilityTypeController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  bool _isDropdownOpen = false;
  OverlayEntry? _overlayEntry;

  final List<String> disabilityTypes = [
    'Visual Impairment',
    'Hearing Impairment',
    'Speech Impairment',
    'Physical Disability',
    'Mental Disability',
    'Intellectual Disability',
    'Psychosocial Disability',
    'Multiple Disabilities',
  ];

  @override
  void initState() {
    super.initState();
    _disabilityTypeController.addListener(_validate);
    WidgetsBinding.instance.addPostFrameCallback((_) => _validate());
  }

  void _validate() {
    final isValid = _disabilityTypeController.text.isNotEmpty;
    widget.setIsFormValid?.call(isValid, _showError);
  }

  void _showError() {
    List<String> missingFields = [];
    
    if (_disabilityTypeController.text.isEmpty) {
      missingFields.add("Type of Disability");
    }

    String description = missingFields.isEmpty 
        ? "All fields are complete."
        : "Please complete the following field${missingFields.length > 1 ? 's' : ''}:\n\n${missingFields.map((f) => "• $f").join('\n')}";

    showErrorModal(
      context: context,
      title: "Required Information Missing",
      description: description,
      icon: Icons.accessible_forward_outlined,
      iconColor: AppColors.primary,
    );
  }

  @override
  void dispose() {
    _disabilityTypeController.dispose();
    _removeOverlay();
    super.dispose();
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
    final size = renderBox.size;
    _overlayEntry = _createOverlayEntry(size.width);
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isDropdownOpen = true);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
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
                itemCount: disabilityTypes.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final type = disabilityTypes[index];
                  return ListTile(
                    title: Text(
                      type,
                      style: const TextStyle(fontFamily: 'Segoe UI'),
                    ),
                    onTap: () {
                      setState(() {
                        _disabilityTypeController.text = type;
                      });
                      _toggleDropdown();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.typeOfDisability,
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.semiBold,
            color: Colors.black,
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
                controller: _disabilityTypeController,
                hintText: AppString.selectDisabilityType,
                suffixIcon: Icon(
                  _isDropdownOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ),
            ),
          ),
        ),
        24.gapH,
        BenefitsCard(
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
}