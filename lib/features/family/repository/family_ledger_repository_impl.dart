import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/models/responses/error_response.dart';
import '../models/household_access_model.dart';
import '../models/household_ledger_model.dart';
import '../models/household_member_model.dart';
import '../services/family_ledger_service.dart';
import 'family_ledger_repository.dart';

final familyLedgerRepositoryProvider = Provider.autoDispose<FamilyLedgerRepositoryImpl>((ref) {
  final service = ref.watch(familyLedgerServiceProvider);
  return FamilyLedgerRepositoryImpl(service: service);
});

class FamilyLedgerRepositoryImpl implements FamilyLedgerRepository {
  final FamilyLedgerService _service;

  FamilyLedgerRepositoryImpl({required FamilyLedgerService service}) 
      : _service = service;

  @override
  Future<DataState<HouseholdAccessModel>> getMyHousehold() async {
    try {
      debugPrint("📤 Fetching user's household ledger");
      
      // Note: This currently returns "no household" until we implement one of these solutions:
      // 1. Backend adds a /my-ledger endpoint that finds household by linked_by_user_profile_id
      // 2. Backend provides household_id in user session/profile that we can fetch
      // 3. We get all households and filter by current user (not scalable)
      
      debugPrint("ℹ️ Cannot fetch household - need household_id or backend /my-ledger endpoint");
      
      return DataState.success(
        data: HouseholdAccessModel(
          hasHousehold: false,
          isHead: false,
          household: null,
        ),
      );
      
    } on DioException catch (e) {
      debugPrint("❌ Dio Error: ${e.response?.statusCode} - ${e.message}");
      
      if (e.response?.statusCode == 404) {
        debugPrint("ℹ️ No household found for user (404)");
        return DataState.success(
          data: HouseholdAccessModel(
            hasHousehold: false,
            isHead: false,
            household: null,
          ),
        );
      }

      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        try {
          final errorResponse = ErrorResponse.fromMap(
            e.response!.data as Map<String, dynamic>,
          );
          return DataState.error(
            error: errorResponse.message ?? "Failed to fetch household",
          );
        } catch (_) {
          // If parsing fails, fall through to generic error
        }
      }

      return DataState.error(
        error: e.message ?? "Network error occurred",
      );
    } catch (e) {
      debugPrint("❌ Unexpected Error: $e");
      return DataState.error(error: "Unexpected error: $e");
    }
  }

  @override
  Future<DataState<HouseholdLedgerModel>> getHouseholdById(String id) async {
    try {
      debugPrint("📤 Fetching household by ID: $id");
      
      final response = await _service.getHouseholdById(id);
      final raw = response.data;

      if (raw is String) {
        return const DataState.error(
          error: "API endpoint not found.",
        );
      }

      if (raw is! Map<String, dynamic>) {
        return const DataState.error(
          error: "Unexpected response format from server",
        );
      }

      if (raw['success'] != true) {
        return DataState.error(
          error: raw['message'] ?? "Failed to fetch household",
        );
      }

      final household = HouseholdLedgerModel.fromJson(raw['data']);
      debugPrint("✅ Household loaded successfully");
      
      return DataState.success(data: household);
    } on DioException catch (e) {
      debugPrint("❌ Dio Error: ${e.response?.statusCode} - ${e.message}");
      
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        try {
          final errorResponse = ErrorResponse.fromMap(
            e.response!.data as Map<String, dynamic>,
          );
          return DataState.error(
            error: errorResponse.message ?? "Failed to fetch household",
          );
        } catch (_) {}
      }

      return DataState.error(
        error: e.message ?? "Network error occurred",
      );
    } catch (e) {
      debugPrint("❌ Unexpected Error: $e");
      return DataState.error(error: "Unexpected error: $e");
    }
  }

  @override
  Future<DataState<HouseholdLedgerModel>> createHousehold({
    required String barangayId,
    required String householdCode,
    String? headResidentId,
  }) async {
    try {
      debugPrint("📤 Creating new household");
      
      final data = {
        'barangay_id': barangayId,
        'household_code': householdCode,
        if (headResidentId != null)
          'head_of_family': {'resident_id': headResidentId},
      };

      final response = await _service.createHousehold(data);
      final raw = response.data;

      if (raw is! Map<String, dynamic>) {
        return const DataState.error(
          error: "Unexpected response format from server",
        );
      }

      if (raw['success'] != true) {
        return DataState.error(
          error: raw['message'] ?? "Failed to create household",
        );
      }

      final household = HouseholdLedgerModel.fromJson(raw['data']);
      debugPrint("✅ Household created successfully");
      
      return DataState.success(data: household);
    } on DioException catch (e) {
      debugPrint("❌ Dio Error: ${e.response?.statusCode} - ${e.message}");
      
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        try {
          final errorResponse = ErrorResponse.fromMap(
            e.response!.data as Map<String, dynamic>,
          );
          return DataState.error(
            error: errorResponse.message ?? "Failed to create household",
          );
        } catch (_) {}
      }

      return DataState.error(
        error: e.message ?? "Network error occurred",
      );
    } catch (e) {
      debugPrint("❌ Unexpected Error: $e");
      return DataState.error(error: "Unexpected error: $e");
    }
  }

  @override
  Future<DataState<HouseholdLedgerModel>> updateHousehold({
    required String householdId,
    Map<String, dynamic>? data,
  }) async {
    try {
      debugPrint("📤 Updating household: $householdId");
      
      final response = await _service.updateHousehold(householdId, data ?? {});
      final raw = response.data;

      if (raw is! Map<String, dynamic>) {
        return const DataState.error(
          error: "Unexpected response format from server",
        );
      }

      if (raw['success'] != true) {
        return DataState.error(
          error: raw['message'] ?? "Failed to update household",
        );
      }

      final household = HouseholdLedgerModel.fromJson(raw['data']);
      debugPrint("✅ Household updated successfully");
      
      return DataState.success(data: household);
    } on DioException catch (e) {
      debugPrint("❌ Dio Error: ${e.response?.statusCode} - ${e.message}");
      
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        try {
          final errorResponse = ErrorResponse.fromMap(
            e.response!.data as Map<String, dynamic>,
          );
          return DataState.error(
            error: errorResponse.message ?? "Failed to update household",
          );
        } catch (_) {}
      }

      return DataState.error(
        error: e.message ?? "Network error occurred",
      );
    } catch (e) {
      debugPrint("❌ Unexpected Error: $e");
      return DataState.error(error: "Unexpected error: $e");
    }
  }

  @override
  Future<DataState<void>> deleteHousehold(String householdId) async {
    try {
      debugPrint("📤 Deleting household: $householdId");
      
      final response = await _service.deleteHousehold(householdId);
      final raw = response.data;

      if (raw is Map<String, dynamic> && raw['success'] != true) {
        return DataState.error(
          error: raw['message'] ?? "Failed to delete household",
        );
      }

      debugPrint("✅ Household deleted successfully");
      return const DataState.success(data: null);
    } on DioException catch (e) {
      debugPrint("❌ Dio Error: ${e.response?.statusCode} - ${e.message}");
      
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        try {
          final errorResponse = ErrorResponse.fromMap(
            e.response!.data as Map<String, dynamic>,
          );
          return DataState.error(
            error: errorResponse.message ?? "Failed to delete household",
          );
        } catch (_) {}
      }

      return DataState.error(
        error: e.message ?? "Network error occurred",
      );
    } catch (e) {
      debugPrint("❌ Unexpected Error: $e");
      return DataState.error(error: "Unexpected error: $e");
    }
  }

  @override
  Future<DataState<HouseholdMemberModel>> addHouseholdMember({
    required String householdId,
    required String residentId,
    required String relationshipToHead,
  }) async {
    try {
      debugPrint("📤 Adding household member");
      
      final data = {
        'resident_id': residentId,
        'relationship_to_head': relationshipToHead,
      };

      final response = await _service.addHouseholdMember(householdId, data);
      final raw = response.data;

      if (raw is! Map<String, dynamic>) {
        return const DataState.error(
          error: "Unexpected response format from server",
        );
      }

      if (raw['success'] != true) {
        return DataState.error(
          error: raw['message'] ?? "Failed to add member",
        );
      }

      final member = HouseholdMemberModel.fromJson(raw['data']);
      debugPrint("✅ Member added successfully");
      
      return DataState.success(data: member);
    } on DioException catch (e) {
      debugPrint("❌ Dio Error: ${e.response?.statusCode} - ${e.message}");
      
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        try {
          final errorResponse = ErrorResponse.fromMap(
            e.response!.data as Map<String, dynamic>,
          );
          return DataState.error(
            error: errorResponse.message ?? "Failed to add member",
          );
        } catch (_) {}
      }

      return DataState.error(
        error: e.message ?? "Network error occurred",
      );
    } catch (e) {
      debugPrint("❌ Unexpected Error: $e");
      return DataState.error(error: "Unexpected error: $e");
    }
  }

  @override
  Future<DataState<HouseholdMemberModel>> updateHouseholdMember({
    required String memberId,
    String? relationshipToHead,
    String? status,
  }) async {
    try {
      debugPrint("📤 Updating household member: $memberId");
      
      final data = <String, dynamic>{};
      if (relationshipToHead != null) {
        data['relationship_to_head'] = relationshipToHead;
      }
      if (status != null) {
        data['status'] = status;
      }

      final response = await _service.updateHouseholdMember(memberId, data);
      final raw = response.data;

      if (raw is! Map<String, dynamic>) {
        return const DataState.error(
          error: "Unexpected response format from server",
        );
      }

      if (raw['success'] != true) {
        return DataState.error(
          error: raw['message'] ?? "Failed to update member",
        );
      }

      final member = HouseholdMemberModel.fromJson(raw['data']);
      debugPrint("✅ Member updated successfully");
      
      return DataState.success(data: member);
    } on DioException catch (e) {
      debugPrint("❌ Dio Error: ${e.response?.statusCode} - ${e.message}");
      
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        try {
          final errorResponse = ErrorResponse.fromMap(
            e.response!.data as Map<String, dynamic>,
          );
          return DataState.error(
            error: errorResponse.message ?? "Failed to update member",
          );
        } catch (_) {}
      }

      return DataState.error(
        error: e.message ?? "Network error occurred",
      );
    } catch (e) {
      debugPrint("❌ Unexpected Error: $e");
      return DataState.error(error: "Unexpected error: $e");
    }
  }

  @override
  Future<DataState<void>> removeHouseholdMember(String memberId) async {
    try {
      debugPrint("📤 Removing household member: $memberId");
      
      final response = await _service.removeHouseholdMember(memberId);
      final raw = response.data;

      if (raw is Map<String, dynamic> && raw['success'] != true) {
        return DataState.error(
          error: raw['message'] ?? "Failed to remove member",
        );
      }

      debugPrint("✅ Member removed successfully");
      return const DataState.success(data: null);
    } on DioException catch (e) {
      debugPrint("❌ Dio Error: ${e.response?.statusCode} - ${e.message}");
      
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        try {
          final errorResponse = ErrorResponse.fromMap(
            e.response!.data as Map<String, dynamic>,
          );
          return DataState.error(
            error: errorResponse.message ?? "Failed to remove member",
          );
        } catch (_) {}
      }

      return DataState.error(
        error: e.message ?? "Network error occurred",
      );
    } catch (e) {
      debugPrint("❌ Unexpected Error: $e");
      return DataState.error(error: "Unexpected error: $e");
    }
  }

  @override
  Future<DataState<void>> decampMember(String memberId, String? reason) async {
    try {
      debugPrint("📤 Decamping household member: $memberId");
      
      final data = {'reason': reason};
      final response = await _service.decampMember(memberId, data);
      final raw = response.data;

      if (raw is Map<String, dynamic> && raw['success'] != true) {
        return DataState.error(
          error: raw['message'] ?? "Failed to decamp member",
        );
      }

      debugPrint("✅ Member decamped successfully");
      return const DataState.success(data: null);
    } on DioException catch (e) {
      debugPrint("❌ Dio Error: ${e.response?.statusCode} - ${e.message}");
      
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        try {
          final errorResponse = ErrorResponse.fromMap(
            e.response!.data as Map<String, dynamic>,
          );
          return DataState.error(
            error: errorResponse.message ?? "Failed to decamp member",
          );
        } catch (_) {}
      }

      return DataState.error(
        error: e.message ?? "Network error occurred",
      );
    } catch (e) {
      debugPrint("❌ Unexpected Error: $e");
      return DataState.error(error: "Unexpected error: $e");
    }
  }

  @override
  Future<DataState<List<dynamic>>> getBarangays() async {
    try {
      debugPrint("📤 Fetching barangays list");
      
      final response = await _service.getBarangays();
      final raw = response.data;

      if (raw is String) {
        return const DataState.error(
          error: "API endpoint not found.",
        );
      }

      if (raw is! Map<String, dynamic>) {
        return const DataState.error(
          error: "Unexpected response format from server",
        );
      }

      if (raw['success'] != true) {
        return DataState.error(
          error: raw['message'] ?? "Failed to fetch barangays",
        );
      }

      final barangays = raw['data'] as List<dynamic>;
      debugPrint("✅ Loaded ${barangays.length} barangays");
      
      return DataState.success(data: barangays);
    } on DioException catch (e) {
      debugPrint("❌ Dio Error: ${e.response?.statusCode} - ${e.message}");
      
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        try {
          final errorResponse = ErrorResponse.fromMap(
            e.response!.data as Map<String, dynamic>,
          );
          return DataState.error(
            error: errorResponse.message ?? "Failed to fetch barangays",
          );
        } catch (_) {}
      }

      return DataState.error(
        error: e.message ?? "Network error occurred",
      );
    } catch (e) {
      debugPrint("❌ Unexpected Error: $e");
      return DataState.error(error: "Unexpected error: $e");
    }
  }
}