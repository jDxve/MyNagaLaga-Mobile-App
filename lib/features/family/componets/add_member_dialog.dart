import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';

class AddMemberDialog extends StatefulWidget {
  final int generation;
  final Function(String name, String role, Color color) onAdd;

  const AddMemberDialog({
    super.key,
    required this.generation,
    required this.onAdd,
  });

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.generation == 1
        ? AppColors.lightBlue
        : widget.generation == 2
            ? AppColors.lightGrey
            : AppColors.lightYellow;
  }

  @override
  void dispose() {
    nameController.dispose();
    roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(D.radiusLG),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Family Member',
                style: TextStyle(
                  fontSize: D.textLG,
                  fontWeight: D.bold,
                  color: AppColors.textlogo,
                ),
              ),
              6.gapH,
              Text(
                'Generation ${widget.generation}',
                style: TextStyle(
                  fontSize: D.textSM,
                  color: AppColors.grey,
                ),
              ),
              20.gapH,
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(
                    fontSize: D.textSM,
                    color: AppColors.grey,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(D.radiusMD),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
              ),
              12.gapH,
              TextField(
                controller: roleController,
                decoration: InputDecoration(
                  labelText: 'Role (e.g., Father, Mother, Son)',
                  labelStyle: TextStyle(
                    fontSize: D.textSM,
                    color: AppColors.grey,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(D.radiusMD),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
              ),
              20.gapH,
              Text(
                'Choose Color',
                style: TextStyle(
                  fontSize: D.textBase,
                  fontWeight: D.semiBold,
                  color: AppColors.textlogo,
                ),
              ),
              12.gapH,
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: [
                  _buildColorOption(AppColors.lightBlue),
                  _buildColorOption(AppColors.lightPurple),
                  _buildColorOption(AppColors.lightGrey),
                  _buildColorOption(AppColors.lightYellow),
                  _buildColorOption(AppColors.lightPink),
                  _buildColorOption(AppColors.lightPrimary),
                ],
              ),
              24.gapH,
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
                        if (nameController.text.isNotEmpty &&
                            roleController.text.isNotEmpty) {
                          widget.onAdd(
                            nameController.text,
                            roleController.text,
                            selectedColor,
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(D.radiusMD),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Add',
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
      ),
    );
  }

  Widget _buildColorOption(Color color) {
    final isSelected = color == selectedColor;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.2),
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                size: D.iconSM,
                color: AppColors.primary,
              )
            : null,
      ),
    );
  }
}