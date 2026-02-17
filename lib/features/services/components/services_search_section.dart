import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/widgets/search_input.dart';
import 'posting_list.dart';

class ServicesSearchSection extends StatefulWidget {
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterTap;

  const ServicesSearchSection({
    super.key,
    this.searchController,
    this.onSearchChanged,
    this.onFilterTap,
  });

  @override
  State<ServicesSearchSection> createState() => _ServicesSearchSectionState();
}

class _ServicesSearchSectionState extends State<ServicesSearchSection> {
  late final TextEditingController _controller;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.searchController ?? TextEditingController();
    _searchQuery = _controller.text;
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    setState(() => _searchQuery = _controller.text);
    widget.onSearchChanged?.call(_controller.text);
  }

  @override
  void dispose() {
    if (widget.searchController == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onChanged);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: searchInput(
                hintText: 'Search postings...',
                controller: _controller,
                onChanged: (v) {
                  setState(() => _searchQuery = v);
                  widget.onSearchChanged?.call(v);
                },
              ),
            ),
            SizedBox(width: 12.w),
            _FilterButton(onTap: widget.onFilterTap),
          ],
        ),
        20.gapH,
        Text(
          'Available Assistance Postings',
          style: TextStyle(
            fontSize: 16.f,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        14.gapH,
        PostingHorizontalList(searchQuery: _searchQuery),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _FilterButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(D.radiusXXL),
      child: Container(
        width: 48.w,
        height: 48.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(D.radiusXXL),
          border: Border.all(
            color: AppColors.grey.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(Icons.tune, color: AppColors.grey, size: D.iconMD),
      ),
    );
  }
}