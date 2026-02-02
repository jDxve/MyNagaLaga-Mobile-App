import 'household_member_model.dart';

class HouseholdLedgerModel {
  final String id;
  final String householdCode;
  final String barangayId;
  final String barangayName;
  final HouseholdMemberModel? head;
  final List<HouseholdMemberModel> members;

  HouseholdLedgerModel({
    required this.id,
    required this.householdCode,
    required this.barangayId,
    required this.barangayName,
    this.head,
    required this.members,
  });

  factory HouseholdLedgerModel.fromJson(Map<String, dynamic> json) {
    final membersList = json['household_members'] as List? ?? [];
    
    return HouseholdLedgerModel(
      id: json['id'].toString(),
      householdCode: json['household_code'] ?? '',
      barangayId: json['barangay_id'].toString(),
      barangayName: json['barangays']?['name'] ?? '',
      head: membersList.isNotEmpty
          ? HouseholdMemberModel.fromJson(
              membersList.firstWhere(
                (m) => m['is_head'] == true,
                orElse: () => membersList.first,
              ),
            )
          : null,
      members: membersList
          .map((m) => HouseholdMemberModel.fromJson(m))
          .toList(),
    );
  }

  int get totalMembers => members.length;
  
  List<HouseholdMemberModel> get activeMembers =>
      members.where((m) => m.status == 'Active').toList();
}