import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../resources/colors.dart';
import '../resources/dimensions.dart';
import '../resources/assets.dart';
import '../resources/strings.dart';
import 'secondary_button.dart';

class UploadImage extends StatelessWidget {
  final File? image;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final Function(ImageSource source)? onPickImage;
  final bool showActions;
  final Color iconBackgroundColor;
  final Color iconColor;
  final double? height;

  const UploadImage({
    super.key,
    this.image,
    required this.title,
    this.subtitle = 'Take a photo or upload an image file',
    this.onTap,
    this.onRemove,
    this.onPickImage,
    this.showActions = false,
    this.iconBackgroundColor = AppColors.lightYellow, // Updated
    this.iconColor = AppColors.darkYellow, // Updated
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: image != null ? onTap : null,
          child: CustomPaint(
            painter: DashedRectPainter(color: AppColors.grey.withOpacity(0.3)),
            child: Container(
              height: height ?? 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(D.radiusLG),
              ),
              child: image != null ? _buildImagePreview() : _buildUploadPlaceholder(),
            ),
          ),
        ),
        if (showActions) ...[
          16.gapH,
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: AppString.takePhoto,
                  isFilled: true,
                  icon: Icons.camera_alt_outlined,
                  onPressed: () => onPickImage?.call(ImageSource.camera),
                ),
              ),
              12.gapW,
              Expanded(
                child: SecondaryButton(
                  text: AppString.upload,
                  icon: Icons.file_upload_outlined,
                  onPressed: () => onPickImage?.call(ImageSource.gallery),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(D.radiusLG),
          child: Image.file(image!, fit: BoxFit.cover),
        ),
        if (onRemove != null)
          Positioned(
            top: 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: AppColors.white, size: 16.w),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: iconBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SvgPicture.asset(
           Assets.imageUploadIcon,
            width: 32.w,
            height: 32.w,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          title,
          style: TextStyle(
            fontSize: D.textBase,
            fontWeight: D.semiBold,
            color: AppColors.black,
            fontFamily: 'Segoe UI',
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: D.textSM,
            color: AppColors.grey,
            fontFamily: 'Segoe UI',
          ),
        ),
      ],
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 6;
    double dashSpace = 4;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(D.radiusLG),
    );
    Path path = Path()..addRRect(rrect);

    for (var measurePath in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < measurePath.length) {
        canvas.drawPath(
          measurePath.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}