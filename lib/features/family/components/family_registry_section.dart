import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import '../models/household_model.dart';
import 'tree_member_node.dart';

class FamilyRegistrySection extends StatelessWidget {
  final List<HouseholdMember> members;
  final String? currentUserMemberId;

  const FamilyRegistrySection({
    super.key,
    required this.members,
    this.currentUserMemberId,
  });

  @override
  Widget build(BuildContext context) {
    final parents = members
        .where((m) =>
            m.relationshipToHead == 'Head' || m.relationshipToHead == 'Spouse')
        .toList();

    final children = members
        .where((m) =>
            m.relationshipToHead == 'Child' ||
            m.relationshipToHead == 'Sibling')
        .toList();

    final grandchildren =
        members.where((m) => m.relationshipToHead == 'Grandchild').toList();

    final others = members
        .where((m) =>
            m.relationshipToHead != 'Head' &&
            m.relationshipToHead != 'Spouse' &&
            m.relationshipToHead != 'Child' &&
            m.relationshipToHead != 'Sibling' &&
            m.relationshipToHead != 'Grandchild')
        .toList();

    return Container(
      color: AppColors.white,
      width: double.infinity,
      padding: EdgeInsets.only(top: 24.h, bottom: 40.h),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                Text(
                  'Family Registry',
                  style: TextStyle(
                    fontSize: 20.f,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Segoe UI',
                    color: AppColors.textlogo,
                  ),
                ),
                8.gapH,
                Text(
                  'Your household members',
                  style: TextStyle(
                    fontSize: 14.f,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Segoe UI',
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          32.gapH,
          if (parents.isNotEmpty) _buildWrappedRow(parents),
          if (parents.isNotEmpty && children.isNotEmpty)
            _buildVerticalConnector(),
          if (children.isNotEmpty) _buildWrappedRow(children),
          if (children.isNotEmpty && grandchildren.isNotEmpty)
            _buildVerticalConnector(),
          if (grandchildren.isNotEmpty) _buildWrappedRow(grandchildren),
          if (others.isNotEmpty) ...[
            _buildVerticalConnector(),
            _buildWrappedRow(others),
          ],
        ],
      ),
    );
  }

  Widget _buildWrappedRow(List<HouseholdMember> groupMembers) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 20.w,
      runSpacing: 20.h,
      children: groupMembers.map((member) {
        final isCurrentUser =
            currentUserMemberId != null && member.id == currentUserMemberId;

        return TreeMemberNode(
          name: member.fullName,
          role: member.relationshipToHead,
          isHead: member.isHead,
          status: member.status,
          isCurrentUser: isCurrentUser,
        );
      }).toList(),
    );
  }

  Widget _buildVerticalConnector() {
    return Container(
      width: 2,
      height: 30.h,
      margin: EdgeInsets.symmetric(vertical: 10.h),
      color: AppColors.grey.withOpacity(0.3),
    );
  }
}