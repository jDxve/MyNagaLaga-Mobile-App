import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';

class DeleteMemberDialog extends StatelessWidget {
  final String memberName;
  final VoidCallback onDelete;

  const DeleteMemberDialog({
    super.key,
    required this.memberName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(D.radiusLG),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                color: AppColors.red,
                size: D.iconMD,
              ),
            ),
            16.gapH,
            Text(
              'Delete $memberName?',
              style: TextStyle(
                fontSize: D.textLG,
                fontWeight: D.bold,
                color: AppColors.textlogo,
              ),
            ),
            8.gapH,
            Text(
              'Are you sure you want to remove this\nfamily member from the registry?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: D.textSM,
                color: AppColors.grey,
                height: 1.4,
              ),
            ),
            20.gapH,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(D.radiusMD),
                      ),
                      side: BorderSide(
                        color: AppColors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: D.textBase,
                        fontWeight: D.medium,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                ),
                12.gapW,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onDelete();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(D.radiusMD),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: D.textBase,
                        fontWeight: D.semiBold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}