import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/widgets/search_input.dart';

import 'posting_list.dart'; // ✅ Updated import

class ServicesSearchSection extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterTap;

  const ServicesSearchSection({
    super.key,
    required this.searchController,
    this.onSearchChanged,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar + Filter
        Row(
          children: [
            Expanded(
              child: searchInput(
                hintText: 'Search..',
                controller: searchController,
                onChanged: onSearchChanged,
              ),
            ),
            SizedBox(width: 12.w),
            _buildFilterButton(),
          ],
        ),

        20.gapH,

        // ✅ Available Postings Title
        Text(
          "Available Assistance Postings",
          style: TextStyle(
            fontSize: 16.f, // Slightly larger
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),

        14.gapH,

        // ✅ Horizontal Posting List
        PostingHorizontalList(
          onTap: (posting) {
            debugPrint("Tapped Posting: ${posting.title}");
            // TODO: Navigate to posting details
            // Navigator.pushNamed(
            //   context,
            //   PostingDetailScreen.routeName,
            //   arguments: posting,
            // );
          },
        ),
      ],
    );
  }

  Widget _buildFilterButton() {
    return InkWell(
      onTap: onFilterTap,
      borderRadius: BorderRadius.circular(D.radiusXXL),
      child: Container(
        width: 48.w,
        height: 48.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(D.radiusXXL),
          border: Border.all(color: AppColors.grey.withOpacity(0.2), width: 1),
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