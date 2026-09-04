import 'package:mynagalaga_mobile_app/features/family/models/household_model.dart';

abstract class FamilyLedgerRepository {
  Future<Household?> fetchMyHousehold();
  void clearCache();
}
