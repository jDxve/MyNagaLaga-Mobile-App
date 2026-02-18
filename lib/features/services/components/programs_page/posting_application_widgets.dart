import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../common/resources/colors.dart';
import '../../../../common/resources/dimensions.dart';
import '../../../../common/widgets/secondary_button.dart';
import '../../../../common/widgets/text_input.dart';
import '../../../../common/widgets/upload_image_card.dart';
import '../../models/welfare_program_model.dart';
import '../../models/welfare_request_model.dart';

class PostingHeaderCard extends StatelessWidget {
  final WelfarePostingModel posting;
  const PostingHeaderCard({super.key, required this.posting});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          posting.title,
          style: TextStyle(
            fontSize: D.textXL,
            fontWeight: D.bold,
            fontFamily: 'Segoe UI',
            color: AppColors.black,
            height: 1.3,
          ),
        ),
        if (posting.serviceName != null) ...[
          4.gapH,
          Text(
            posting.serviceName!,
            style: TextStyle(
              fontSize: D.textSM,
              color: AppColors.grey,
              fontFamily: 'Segoe UI',
            ),
          ),
        ],
      ],
    );
  }
}

class PostingBottomBar extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onSubmit;
  const PostingBottomBar({
    super.key,
    required this.label,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 50.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        height: D.primaryButton,
        child: SecondaryButton(
          text: label,
          onPressed: onSubmit,
          isLoading: isLoading,
          isFilled: true,
        ),
      ),
    );
  }
}

class PostingSectionHeader extends StatelessWidget {
  final String title;
  const PostingSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: D.textLG,
        fontWeight: D.bold,
        fontFamily: 'Segoe UI',
        color: AppColors.black,
      ),
    );
  }
}

class PostingSubtitleText extends StatelessWidget {
  final String text;
  const PostingSubtitleText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: D.textSM,
        color: AppColors.grey,
        fontFamily: 'Segoe UI',
        height: 1.5,
      ),
    );
  }
}

class PostingCharCounter extends StatelessWidget {
  final int current;
  final int minimum;
  const PostingCharCounter({
    super.key,
    required this.current,
    required this.minimum,
  });

  @override
  Widget build(BuildContext context) {
    final met = current >= minimum;
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.info_outline_rounded,
          size: 13.r,
          color: met ? AppColors.primary : AppColors.grey,
        ),
        4.gapW,
        Text(
          met
              ? '$current characters'
              : '$current / $minimum characters minimum',
          style: TextStyle(
            fontSize: D.textXS,
            color: met ? AppColors.primary : AppColors.grey,
            fontFamily: 'Segoe UI',
          ),
        ),
      ],
    );
  }
}

class PostingFieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const PostingFieldLabel({
    super.key,
    required this.label,
    required this.required,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: D.textSM,
          fontWeight: D.medium,
          color: AppColors.black,
          fontFamily: 'Segoe UI',
        ),
        children: required
            ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.red, fontSize: D.textSM),
                ),
              ]
            : [],
      ),
    );
  }
}

class PostingMatchScorePill extends StatelessWidget {
  final double score;
  final Color? color;
  const PostingMatchScorePill({super.key, required this.score, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: c.withOpacity(.08),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        '${(score * 100).toStringAsFixed(0)}% match',
        style: TextStyle(
          fontSize: D.textXS,
          fontWeight: D.semiBold,
          color: c,
          fontFamily: 'Segoe UI',
        ),
      ),
    );
  }
}

class PostingVerifiedChip extends StatelessWidget {
  const PostingVerifiedChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.08),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 10.r, color: AppColors.primary),
          3.gapW,
          Text(
            'Verified',
            style: TextStyle(
              fontSize: D.textXS,
              fontWeight: D.semiBold,
              color: AppColors.primary,
              fontFamily: 'Segoe UI',
            ),
          ),
        ],
      ),
    );
  }
}

class PostingAttachedChip extends StatelessWidget {
  const PostingAttachedChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(.08),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.attach_file_rounded, size: 10.r, color: Colors.teal),
          3.gapW,
          Text(
            'Attached',
            style: TextStyle(
              fontSize: D.textXS,
              fontWeight: D.semiBold,
              color: Colors.teal,
              fontFamily: 'Segoe UI',
            ),
          ),
        ],
      ),
    );
  }
}

class PostingReviewSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const PostingReviewSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(D.radiusLG),
        border: Border.all(color: AppColors.grey.withOpacity(.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(D.radiusLG),
                topRight: Radius.circular(D.radiusLG),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16.r, color: AppColors.primary),
                8.gapW,
                Text(
                  title,
                  style: TextStyle(
                    fontSize: D.textSM,
                    fontWeight: D.semiBold,
                    color: AppColors.primary,
                    fontFamily: 'Segoe UI',
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.all(16.w), child: child),
        ],
      ),
    );
  }
}

class PostingReviewFieldRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  const PostingReviewFieldRow({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Icon(
                icon,
                size: 15.r,
                color: iconColor.withOpacity(.8),
              ),
            ),
            6.gapW,
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: D.textSM,
                  color: AppColors.grey,
                  fontFamily: 'Segoe UI',
                  fontWeight: D.medium,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        8.gapH,
        child,
      ],
    );
  }
}

class PostingReviewGroupCard extends StatelessWidget {
  final String category;
  final List<WelfareRequirementItem> textItems;
  final List<WelfareRequirementItem> fileItems;
  final Map<String, String> textFields;
  final Map<String, File?> fileUploads;
  const PostingReviewGroupCard({
    super.key,
    required this.category,
    required this.textItems,
    required this.fileItems,
    required this.textFields,
    required this.fileUploads,
  });

  @override
  Widget build(BuildContext context) {
    final allItems = [...textItems, ...fileItems];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(D.radiusLG),
        border: Border.all(color: AppColors.grey.withOpacity(.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(D.radiusLG),
                topRight: Radius.circular(D.radiusLG),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 16.r,
                  color: AppColors.primary,
                ),
                8.gapW,
                Text(
                  category,
                  style: TextStyle(
                    fontSize: D.textSM,
                    fontWeight: D.semiBold,
                    color: AppColors.primary,
                    fontFamily: 'Segoe UI',
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${allItems.length} item${allItems.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: D.textXS,
                      color: AppColors.primary,
                      fontFamily: 'Segoe UI',
                      fontWeight: D.semiBold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...textItems.asMap().entries.map((entry) {
                  final item = entry.value;
                  final value = textFields[item.key] ?? '';
                  final isLastInSection =
                      entry.key == textItems.length - 1 && fileItems.isEmpty;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PostingReviewFieldRow(
                        label: item.label,
                        icon: Icons.text_fields_rounded,
                        iconColor: AppColors.primary,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: D.textBase,
                            fontFamily: 'Segoe UI',
                            color: AppColors.black,
                            fontWeight: D.medium,
                          ),
                        ),
                      ),
                      if (!isLastInSection) ...[
                        10.gapH,
                        Divider(
                          height: 1,
                          color: AppColors.grey.withOpacity(.1),
                        ),
                        10.gapH,
                      ],
                    ],
                  );
                }),
                if (textItems.isNotEmpty && fileItems.isNotEmpty) ...[
                  10.gapH,
                  Divider(height: 1, color: AppColors.grey.withOpacity(.1)),
                  10.gapH,
                ],
                ...fileItems.asMap().entries.map((entry) {
                  final item = entry.value;
                  final file = fileUploads[item.key]!;
                  final isLast = entry.key == fileItems.length - 1;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PostingReviewFieldRow(
                        label: item.label,
                        icon: Icons.insert_drive_file_rounded,
                        iconColor: Colors.teal,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(D.radiusMD),
                          child: Image.file(
                            file,
                            width: double.infinity,
                            height: 160.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (!isLast) ...[
                        10.gapH,
                        Divider(
                          height: 1,
                          color: AppColors.grey.withOpacity(.1),
                        ),
                        10.gapH,
                      ],
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PostingAutoFilledCategoryCard extends StatefulWidget {
  final WelfareAutoFilledCategory category;
  const PostingAutoFilledCategoryCard({
    super.key,
    required this.category,
  });

  @override
  State<PostingAutoFilledCategoryCard> createState() =>
      _PostingAutoFilledCategoryCardState();
}

class _PostingAutoFilledCategoryCardState
    extends State<PostingAutoFilledCategoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(D.radiusLG),
        border: Border.all(
          color: _expanded
              ? AppColors.primary.withOpacity(.4)
              : AppColors.primary.withOpacity(.2),
        ),
        boxShadow: _expanded
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(D.radiusLG),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(.1),
                      borderRadius: BorderRadius.circular(D.radiusMD),
                    ),
                    child: Icon(
                      Icons.auto_fix_high_rounded,
                      color: AppColors.primary,
                      size: 20.r,
                    ),
                  ),
                  12.gapW,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category.category,
                          style: TextStyle(
                            fontSize: D.textBase,
                            fontWeight: D.semiBold,
                            fontFamily: 'Segoe UI',
                            color: AppColors.black,
                          ),
                        ),
                        3.gapH,
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 12.r,
                              color: AppColors.primary,
                            ),
                            4.gapW,
                            Text(
                              '${widget.category.items.length} field${widget.category.items.length == 1 ? '' : 's'} auto-filled',
                              style: TextStyle(
                                fontSize: D.textXS,
                                color: AppColors.primary,
                                fontFamily: 'Segoe UI',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const PostingVerifiedChip(),
                  8.gapW,
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.grey,
                      size: 20.r,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(
                  height: 1,
                  color: AppColors.primary.withOpacity(.12),
                ),
                Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Column(
                    children: widget.category.items.map((item) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 14.r,
                              color: AppColors.primary,
                            ),
                            6.gapW,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.label,
                                    style: TextStyle(
                                      fontSize: D.textSM,
                                      color: AppColors.grey,
                                      fontFamily: 'Segoe UI',
                                    ),
                                  ),
                                  2.gapH,
                                  Text(
                                    'from ${item.badgeTypeName}',
                                    style: TextStyle(
                                      fontSize: D.textXS,
                                      color:
                                          AppColors.primary.withOpacity(.6),
                                      fontFamily: 'Segoe UI',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            8.gapW,
                            PostingMatchScorePill(score: item.matchScore),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class PostingAutoAttachedCategoryCard extends StatefulWidget {
  final WelfareAutoAttachedCategory category;
  const PostingAutoAttachedCategoryCard({
    super.key,
    required this.category,
  });

  @override
  State<PostingAutoAttachedCategoryCard> createState() =>
      _PostingAutoAttachedCategoryCardState();
}

class _PostingAutoAttachedCategoryCardState
    extends State<PostingAutoAttachedCategoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(D.radiusLG),
        border: Border.all(
          color: _expanded
              ? Colors.teal.withOpacity(.4)
              : Colors.teal.withOpacity(.2),
        ),
        boxShadow: _expanded
            ? [
                BoxShadow(
                  color: Colors.teal.withOpacity(.07),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(D.radiusLG),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(.1),
                      borderRadius: BorderRadius.circular(D.radiusMD),
                    ),
                    child: Icon(
                      Icons.attach_file_rounded,
                      color: Colors.teal,
                      size: 20.r,
                    ),
                  ),
                  12.gapW,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category.category,
                          style: TextStyle(
                            fontSize: D.textBase,
                            fontWeight: D.semiBold,
                            fontFamily: 'Segoe UI',
                            color: AppColors.black,
                          ),
                        ),
                        3.gapH,
                        Row(
                          children: [
                            Icon(
                              Icons.file_present_rounded,
                              size: 12.r,
                              color: Colors.teal,
                            ),
                            4.gapW,
                            Text(
                              '${widget.category.items.length} document${widget.category.items.length == 1 ? '' : 's'} attached',
                              style: TextStyle(
                                fontSize: D.textXS,
                                color: Colors.teal,
                                fontFamily: 'Segoe UI',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const PostingAttachedChip(),
                  8.gapW,
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.grey,
                      size: 20.r,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(height: 1, color: Colors.teal.withOpacity(.12)),
                Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Column(
                    children: widget.category.items.map((item) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Row(
                          children: [
                            Icon(
                              Icons.insert_drive_file_outlined,
                              size: 14.r,
                              color: Colors.teal,
                            ),
                            6.gapW,
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: D.textSM,
                                  color: AppColors.black,
                                  fontFamily: 'Segoe UI',
                                  fontWeight: D.medium,
                                ),
                              ),
                            ),
                            PostingMatchScorePill(
                              score: item.matchScore,
                              color: Colors.teal,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class PostingRequirementGroup extends StatelessWidget {
  final WelfareRequirementGroup group;
  final Map<String, TextEditingController> textControllers;
  final Map<String, File?> fileUploads;
  final void Function(String key, File file) onPickFile;
  final void Function(String key) onRemoveFile;
  final void Function(String key, TextEditingController controller)
      onControllerCreated;
  const PostingRequirementGroup({
    super.key,
    required this.group,
    required this.textControllers,
    required this.fileUploads,
    required this.onPickFile,
    required this.onRemoveFile,
    required this.onControllerCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(D.radiusLG),
        border: Border.all(color: AppColors.grey.withOpacity(.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(D.radiusLG),
                topRight: Radius.circular(D.radiusLG),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 16.r,
                  color: AppColors.primary,
                ),
                8.gapW,
                Text(
                  group.category,
                  style: TextStyle(
                    fontSize: D.textSM,
                    fontWeight: D.semiBold,
                    color: AppColors.primary,
                    fontFamily: 'Segoe UI',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (group.description != null) ...[
                  Text(
                    group.description!,
                    style: TextStyle(
                      fontSize: D.textXS,
                      color: AppColors.grey,
                      fontFamily: 'Segoe UI',
                      height: 1.5,
                    ),
                  ),
                  12.gapH,
                ],
                ...group.items.asMap().entries.map((entry) {
                  final isLast = entry.key == group.items.length - 1;
                  return Column(
                    children: [
                      entry.value.type == 'text'
                          ? PostingTextRequirementField(
                              item: entry.value,
                              controllers: textControllers,
                              onControllerCreated: onControllerCreated,
                            )
                          : PostingFileRequirementField(
                              item: entry.value,
                              fileUploads: fileUploads,
                              onPick: onPickFile,
                              onRemove: onRemoveFile,
                            ),
                      if (!isLast) ...[
                        12.gapH,
                        Divider(
                          height: 1,
                          color: AppColors.grey.withOpacity(.1),
                        ),
                        12.gapH,
                      ],
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PostingTextRequirementField extends StatefulWidget {
  final WelfareRequirementItem item;
  final Map<String, TextEditingController> controllers;
  final void Function(String key, TextEditingController controller)
      onControllerCreated;
  const PostingTextRequirementField({
    super.key,
    required this.item,
    required this.controllers,
    required this.onControllerCreated,
  });

  @override
  State<PostingTextRequirementField> createState() =>
      _PostingTextRequirementFieldState();
}

class _PostingTextRequirementFieldState
    extends State<PostingTextRequirementField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    if (!widget.controllers.containsKey(widget.item.key)) {
      _controller = TextEditingController();
      widget.controllers[widget.item.key] = _controller;
      widget.onControllerCreated(widget.item.key, _controller);
    } else {
      _controller = widget.controllers[widget.item.key]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostingFieldLabel(
          label: widget.item.label,
          required: widget.item.required,
        ),
        8.gapH,
        TextInput(
          controller: _controller,
          hintText:
              widget.item.notes ?? 'Enter ${widget.item.label.toLowerCase()}',
        ),
      ],
    );
  }
}

class PostingFileRequirementField extends StatelessWidget {
  final WelfareRequirementItem item;
  final Map<String, File?> fileUploads;
  final void Function(String key, File file) onPick;
  final void Function(String key) onRemove;
  const PostingFileRequirementField({
    super.key,
    required this.item,
    required this.fileUploads,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final file = fileUploads[item.key];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostingFieldLabel(label: item.label, required: item.required),
        if (item.notes != null) ...[
          4.gapH,
          Text(
            item.notes!,
            style: TextStyle(
              fontSize: D.textXS,
              color: AppColors.grey,
              fontFamily: 'Segoe UI',
            ),
          ),
        ],
        10.gapH,
        UploadImage(
          image: file,
          subtitle: 'Take a photo or upload a file',
          height: 160.h,
          onPickImage: (source) async {
            final picked = await ImagePicker().pickImage(
              source: source,
              imageQuality: 85,
            );
            if (picked != null) onPick(item.key, File(picked.path));
          },
          onRemove: () => onRemove(item.key),
        ),
      ],
    );
  }
}