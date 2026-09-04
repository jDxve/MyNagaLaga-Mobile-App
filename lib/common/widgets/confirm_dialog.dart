import 'package:flutter/material.dart';
import 'package:mynagalaga_mobile_app/common/resources/colors.dart';
import 'package:mynagalaga_mobile_app/common/resources/dimensions.dart';

/// Generic confirm/cancel modal shared across features (logout, destructive
/// actions, etc.) so each screen doesn't hand-roll its own AlertDialog.
/// Resolves to `false` if dismissed without a choice, never null, so
/// callers never have to null-check the result.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  Color? confirmColor,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(D.radiusLG)),
      title: Text(
        title,
        style: const TextStyle(fontFamily: 'Segoe UI', fontWeight: FontWeight.bold),
      ),
      content: Text(message, style: const TextStyle(fontFamily: 'Segoe UI')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            cancelText,
            style: const TextStyle(fontFamily: 'Segoe UI', color: AppColors.grey),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmText,
            style: TextStyle(
              fontFamily: 'Segoe UI',
              color: confirmColor ?? AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
