import 'package:flutter/material.dart';

import '../../../common/resources/dimensions.dart';
import '../models/family_ledger_model.dart';
import 'connection_line_painter.dart';
import 'member_avatar.dart';


class FamilyTreeView extends StatelessWidget {
  final List<FamilyMember> generation1;
  final List<FamilyMember> generation2;
  final List<FamilyMember> generation3;
  final Function(FamilyMember, int) onMemberLongPress;

  const FamilyTreeView({
    super.key,
    required this.generation1,
    required this.generation2,
    required this.generation3,
    required this.onMemberLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Generation 1
        _buildGenerationRow(generation1, 1),
        _buildConnectionLines(),

        // Generation 2
        _buildGenerationRow(generation2, 2),
        _buildConnectionLines(),

        // Generation 3
        _buildGenerationRow(generation3, 3),
      ],
    );
  }

  Widget _buildGenerationRow(List<FamilyMember> members, int generation) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 20.w,
        runSpacing: 16.h,
        children: members
            .map(
              (member) => MemberAvatar(
                member: member,
                generation: generation,
                onLongPress: () => onMemberLongPress(member, generation),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildConnectionLines() {
    return CustomPaint(
      size: Size(double.infinity, 32.h),
      painter: ConnectionLinePainter(),
    );
  }
}