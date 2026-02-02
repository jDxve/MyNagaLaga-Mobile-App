import '../../../common/models/dio/data_state.dart';
import '../models/household_access_model.dart';
import '../models/household_ledger_model.dart';
import '../models/household_member_model.dart';

abstract class FamilyLedgerRepository {
  Future<DataState<HouseholdAccessModel>> getMyHousehold();
  
  Future<DataState<HouseholdLedgerModel>> getHouseholdById(String id);
  
  Future<DataState<HouseholdLedgerModel>> createHousehold({
    required String barangayId,
    required String householdCode,
    String? headResidentId,
  });
  
  Future<DataState<HouseholdLedgerModel>> updateHousehold({
    required String householdId,
    Map<String, dynamic>? data,
  });
  
  Future<DataState<void>> deleteHousehold(String householdId);
  
  Future<DataState<HouseholdMemberModel>> addHouseholdMember({
    required String householdId,
    required String residentId,
    required String relationshipToHead,
  });
  
  Future<DataState<HouseholdMemberModel>> updateHouseholdMember({
    required String memberId,
    String? relationshipToHead,
    String? status,
  });
  
  Future<DataState<void>> removeHouseholdMember(String memberId);
  
  Future<DataState<void>> decampMember(String memberId, String? reason);
  
  Future<DataState<List<dynamic>>> getBarangays();
}