import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/app_exception.dart';
import '../../auth/notifier/auth_session_notifier.dart';
import '../models/household_model.dart';
import '../services/family_ledger_service.dart';
import 'family_ledger_repository.dart';

final familyLedgerRepositoryProvider = Provider<FamilyLedgerRepository>((ref) {
  final service = ref.read(familyLedgerServiceProvider);
  return FamilyLedgerRepositoryImpl(service, ref);
});

class FamilyLedgerRepositoryImpl implements FamilyLedgerRepository {
  final FamilyLedgerService _service;
  final Ref _ref;
  Household? _cachedHousehold;

  FamilyLedgerRepositoryImpl(this._service, this._ref);

  // Not using RepositoryGuard here: a 404 means "no household yet" and must
  // return null rather than throw, which doesn't fit guard/guardThrow's
  // generic try/catch shape. AppException is still used directly so the
  // thrown errors display the same clean copy (via AppException.toString())
  // as every other repository.
  @override
  Future<Household?> fetchMyHousehold() async {
    if (_cachedHousehold != null) {
      return _cachedHousehold;
    }

    try {
      final authState = _ref.read(authSessionProvider);
      final userId = authState.userId;

      if (userId == null || userId.isEmpty) {
        throw const AppException(message: 'User not authenticated. Please log in again.');
      }

      final response = await _service.getMyHousehold(userId);

      if (response.response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          _cachedHousehold = Household.fromJson(data['data']);
          return _cachedHousehold;
        }
      }

      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AppException(
          statusCode: 401,
          message: 'Authentication required. Please log in again.',
        );
      } else if (e.response?.statusCode == 404) {
        return null;
      }
      throw AppException.fromDioException(e, fallbackMessage: 'Network error');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch household: $e');
    }
  }

  @override
  void clearCache() {
    _cachedHousehold = null;
  }
}
