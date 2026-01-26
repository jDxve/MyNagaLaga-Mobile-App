import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../../../common/resources/assets.dart';
import '../../../common/widgets/search_input.dart';

class ServicesSearchSection extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onCashAssistanceTap;

  const ServicesSearchSection({
    super.key,
    required this.searchController,
    this.onSearchChanged,
    this.onFilterTap,
    this.onCashAssistanceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar and Filter Button
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

        // Cash Assistance Banner
        _buildCashAssistanceBanner(),
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

  Widget _buildCashAssistanceBanner() {
    return GestureDetector(
      onTap: onCashAssistanceTap,
      child: Container(
        width: double.infinity,
        height: 140.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(D.radiusLG),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(D.radiusLG),
          child: Image.asset(Assets.cashAssistance, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
