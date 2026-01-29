import 'package:flutter/material.dart';
import '../../../../common/resources/colors.dart';
import '../../../../common/resources/dimensions.dart';
import '../../../../common/widgets/primary_button.dart';

class RateServiceDialog extends StatefulWidget {
  final String serviceType;
  final String caseId;
  final Function(int rating) onSubmit;

  const RateServiceDialog({
    super.key,
    required this.serviceType,
    required this.caseId,
    required this.onSubmit,
  });

  @override
  State<RateServiceDialog> createState() => _RateServiceDialogState();

  static Future<void> show({
    required BuildContext context,
    required String serviceType,
    required String caseId,
    required Function(int rating) onSubmit,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => RateServiceDialog(
        serviceType: serviceType,
        caseId: caseId,
        onSubmit: onSubmit,
      ),
    );
  }
}

class _RateServiceDialogState extends State<RateServiceDialog> {
  int _selectedRating = 0;

  void _handleSubmit() {
    if (_selectedRating > 0) {
      widget.onSubmit(_selectedRating);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(D.radiusLG),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(D.radiusLG),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          
            Text(
              'Rate Your Experience',
              style: TextStyle(
                fontSize: D.textLG,
                fontWeight: D.bold,
                color: Colors.black87,
                fontFamily: 'Segoe UI',
              ),
              textAlign: TextAlign.center,
            ),
            12.gapH,
            Text(
              'How was your experience with "${widget.serviceType}"?',
              style: TextStyle(
                fontSize: D.textSM,
                color: AppColors.grey,
                fontFamily: 'Segoe UI',
              ),
              textAlign: TextAlign.center,
            ),
            24.gapH,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRating = starIndex;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Icon(
                      _selectedRating >= starIndex
                          ? Icons.star
                          : Icons.star_border,
                      size: 40.w,
                      color: _selectedRating >= starIndex
                          ? Colors.amber
                          : Colors.grey.shade300,
                    ),
                  ),
                );
              }),
            ),
            32.gapH,
            Opacity(
              opacity: _selectedRating > 0 ? 1.0 : 0.5,
              child: IgnorePointer(
                ignoring: _selectedRating == 0,
                child: PrimaryButton(
                  text: 'Submit',
                  onPressed: _handleSubmit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}