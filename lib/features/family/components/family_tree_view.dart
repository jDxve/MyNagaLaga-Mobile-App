import 'package:flutter/material.dart';
import '../../../common/resources/colors.dart';
import '../../../common/resources/dimensions.dart';
import 'tree_member_node.dart';

class FamilyTreeView extends StatelessWidget {
  final List<dynamic> members;

  const FamilyTreeView({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    final parents = members
        .where((m) =>
            m['relationship_to_head'] == 'Head' ||
            m['relationship_to_head'] == 'Spouse')
        .toList();

    final children = members
        .where((m) =>
            m['relationship_to_head'] == 'Child' ||
            m['relationship_to_head'] == 'Sibling')
        .toList();

    final grandchildren =
        members.where((m) => m['relationship_to_head'] == 'Grandchild').toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Column(
              children: [
                if (parents.isNotEmpty) _buildWrappedRow(parents),
                if (parents.isNotEmpty && children.isNotEmpty)
                  _buildVerticalConnector(),
                if (children.isNotEmpty) _buildWrappedRow(children),
                if (children.isNotEmpty && grandchildren.isNotEmpty)
                  _buildVerticalConnector(),
                if (grandchildren.isNotEmpty) _buildWrappedRow(grandchildren),
                if (grandchildren.isNotEmpty || children.isNotEmpty) ...[
                  _buildVerticalConnector(),
                  _buildAddMemberButton(context),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWrappedRow(List<dynamic> groupMembers) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 20.w,
      runSpacing: 20.h,
      children: groupMembers.map((member) {
        return TreeMemberNode(
          name: '${member['residents']['first_name']} ${member['residents']['last_name']}',
          role: member['relationship_to_head'],
          isHead: member['is_head'] ?? false,
          status: member['status'],
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

  Widget _buildAddMemberButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Add functionality later
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Add member feature coming soon'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: 64.w,
        height: 64.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
          color: AppColors.primary.withOpacity(0.1),
        ),
        child: Icon(Icons.add, color: AppColors.primary, size: 32.w),
      ),
    );
  }
}