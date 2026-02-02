import 'household_ledger_model.dart';

class HouseholdAccessModel {
  final bool hasHousehold;
  final bool isHead;
  final HouseholdLedgerModel? household;

  HouseholdAccessModel({
    required this.hasHousehold,
    required this.isHead,
    this.household,
  });

  factory HouseholdAccessModel.fromJson(Map<String, dynamic> json) {
    final householdData = json['data'];

    if (householdData == null) {
      return HouseholdAccessModel(
        hasHousehold: false,
        isHead: false,
        household: null,
      );
    }

    final members = householdData['household_members'] as List? ?? [];
    final isHead = members.any((m) => m['is_head'] == true);

    return HouseholdAccessModel(
      hasHousehold: true,
      isHead: isHead,
      household: HouseholdLedgerModel.fromJson(householdData),
    );
  }
}