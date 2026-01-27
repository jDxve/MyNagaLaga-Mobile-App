import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../resources/colors.dart';
import '../resources/dimensions.dart';

class OtpInput extends StatefulWidget {
  final Function(String) onCompleted;
  final int length;

  const OtpInput({
    super.key,
    required this.onCompleted,
    this.length = 6,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _getOtpValue() {
    return _controllers.map((controller) => controller.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        widget.length,
        (index) => Flexible(
          child: Container(
            width: 48.w,
            height: 60.h,
            margin: EdgeInsets.symmetric(horizontal: 2.w),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              autofocus: index == 0,
              onChanged: (value) {
                if (value.length == 1 && index < widget.length - 1) {
                  _focusNodes[index + 1].requestFocus();
                }
                if (value.isEmpty && index > 0) {
                  _focusNodes[index - 1].requestFocus();
                }
                if (_getOtpValue().length == widget.length) {
                  widget.onCompleted(_getOtpValue());
                }
              },
              style: TextStyle(
                fontSize: 22.f,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: Colors.white.withOpacity(0.5),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(D.radiusLG),
                  borderSide: BorderSide(color: AppColors.lightGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(D.radiusLG),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}