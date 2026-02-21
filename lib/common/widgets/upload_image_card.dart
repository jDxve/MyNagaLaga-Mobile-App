import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../resources/colors.dart';
import '../resources/dimensions.dart';
import '../resources/assets.dart';
import '../resources/strings.dart';
import 'secondary_button.dart';

enum FileOrientation { portrait, landscape, square }

class UploadImage extends StatefulWidget {
  final File? image;
  final String? title;
  final String subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final Function(ImageSource source)? onPickImage;
  final Color iconBackgroundColor;
  final Color iconColor;
  final double? height;
  final double? width;
  /// Force a specific orientation layout regardless of image dimensions.
  /// If null, orientation is auto-detected from the image file.
  final FileOrientation? orientation;
  /// Aspect ratio override. If null, defaults to detected/forced orientation.
  final double? aspectRatio;

  const UploadImage({
    super.key,
    this.image,
    this.title,
    this.subtitle = 'Take a photo or upload an image file',
    this.onTap,
    this.onRemove,
    this.onPickImage,
    this.iconBackgroundColor = AppColors.lightYellow,
    this.iconColor = AppColors.darkYellow,
    this.height,
    this.width,
    this.orientation,
    this.aspectRatio,
  });

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  FileOrientation _detectedOrientation = FileOrientation.landscape;
  double? _detectedAspectRatio;
  bool _isResolvingOrientation = false;

  @override
  void initState() {
    super.initState();
    _resolveImageOrientation();
  }

  @override
  void didUpdateWidget(UploadImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image?.path != widget.image?.path) {
      _resolveImageOrientation();
    }
  }

  Future<void> _resolveImageOrientation() async {
    if (widget.image == null) return;
    // If caller forced an orientation, skip detection.
    if (widget.orientation != null) {
      setState(() => _detectedOrientation = widget.orientation!);
      return;
    }

    setState(() => _isResolvingOrientation = true);

    try {
      final bytes = await widget.image!.readAsBytes();
      final codec = await instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final w = frame.image.width.toDouble();
      final h = frame.image.height.toDouble();
      frame.image.dispose();

      FileOrientation orientation;
      if ((w / h - 1.0).abs() < 0.05) {
        orientation = FileOrientation.square;
      } else if (w > h) {
        orientation = FileOrientation.landscape;
      } else {
        orientation = FileOrientation.portrait;
      }

      if (mounted) {
        setState(() {
          _detectedOrientation = orientation;
          _detectedAspectRatio = w / h;
          _isResolvingOrientation = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isResolvingOrientation = false);
    }
  }

  double get _effectiveAspectRatio {
    if (widget.aspectRatio != null) return widget.aspectRatio!;
    if (_detectedAspectRatio != null) return _detectedAspectRatio!;
    // Fallback defaults per orientation
    switch (_detectedOrientation) {
      case FileOrientation.portrait:
        return 3 / 4; // ID / document
      case FileOrientation.landscape:
        return 16 / 9; // wide photo / banner
      case FileOrientation.square:
        return 1.0;
    }
  }

  void _showImageSourceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(D.radiusXL)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 40.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              24.gapH,
              Text(
                'Upload Photo',
                style: TextStyle(
                  fontSize: D.textLG,
                  fontWeight: D.bold,
                  color: AppColors.black,
                  fontFamily: 'Segoe UI',
                ),
              ),
              8.gapH,
              Text(
                'Choose how you want to upload your photo',
                style: TextStyle(
                  fontSize: D.textSM,
                  color: AppColors.grey,
                  fontFamily: 'Segoe UI',
                ),
                textAlign: TextAlign.center,
              ),
              24.gapH,
              SecondaryButton(
                text: AppString.takePhoto,
                isFilled: true,
                icon: Icons.camera_alt_outlined,
                onPressed: () {
                  Navigator.pop(context);
                  widget.onPickImage?.call(ImageSource.camera);
                },
              ),
              12.gapH,
              SecondaryButton(
                text: AppString.upload,
                icon: Icons.file_upload_outlined,
                onPressed: () {
                  Navigator.pop(context);
                  widget.onPickImage?.call(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.image != null;
    final containerWidth = widget.width ?? double.infinity;

    // Wrap in AspectRatio only when we have an image or an explicit ratio.
    Widget content = GestureDetector(
      onTap: () {
        if (hasImage) {
          widget.onTap?.call();
        } else {
          _showImageSourceBottomSheet(context);
        }
      },
      child: CustomPaint(
        painter: DashedRectPainter(color: AppColors.grey.withOpacity(0.3)),
        child: Container(
          width: containerWidth,
          // When no image, use provided height or a sensible default.
          height: hasImage ? null : (widget.height ?? 200.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(D.radiusLG),
          ),
          child: _isResolvingOrientation
              ? const Center(child: CircularProgressIndicator())
              : hasImage
                  ? _buildImagePreview()
                  : _buildUploadPlaceholder(),
        ),
      ),
    );

    // Wrap with AspectRatio to auto-size height when image is present.
    if (hasImage && !_isResolvingOrientation) {
      content = AspectRatio(
        aspectRatio: _effectiveAspectRatio,
        child: content,
      );
    }

    return content;
  }

  Widget _buildImagePreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(D.radiusLG),
          child: Image.file(
            widget.image!,
            fit: BoxFit.cover,
          ),
        ),
        if (widget.onRemove != null)
          Positioned(
            top: 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: widget.onRemove,
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
            color: widget.iconBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SvgPicture.asset(
            Assets.imageUploadIcon,
            width: 32.w,
            height: 32.w,
            colorFilter: ColorFilter.mode(widget.iconColor, BlendMode.srcIn),
          ),
        ),
        12.gapH,
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: TextStyle(
              fontSize: D.textBase,
              fontWeight: D.semiBold,
              color: AppColors.black,
              fontFamily: 'Segoe UI',
            ),
          ),
          4.gapH,
        ],
        Text(
          widget.subtitle,
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