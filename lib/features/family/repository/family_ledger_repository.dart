import '../models/household_model.dart';

abstract class FamilyLedgerRepository {
  Future<Household?> fetchMyHousehold();
  void clearCache();
}
