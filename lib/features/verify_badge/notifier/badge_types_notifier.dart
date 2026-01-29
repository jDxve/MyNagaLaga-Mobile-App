import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/badge_type_model.dart';
import '../services/verify_badge_service.dart';

final badgeTypesNotifierProvider =
    NotifierProvider<BadgeTypesNotifier, DataState<List<BadgeType>>>(
  BadgeTypesNotifier.new,
);

class BadgeTypesNotifier extends Notifier<DataState<List<BadgeType>>> {
  bool _hasFetched = false;

  @override
  DataState<List<BadgeType>> build() {
    if (!_hasFetched) {
      fetchBadgeTypes();
    }
    return const DataState.started();
  }

  Future<void> fetchBadgeTypes() async {
    if (_hasFetched) {
      return;
    }

    state = const DataState.loading();

    try {
      final service = ref.read(verifyBadgeServiceProvider);
      final response = await service.getBadgeTypes();

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as List;
      final badgeTypes = data.map((json) => BadgeType.fromJson(json)).toList();
      
      state = DataState.success(data: badgeTypes);
      _hasFetched = true;
    } catch (e) {
      state = DataState.error(error: 'Error loading badge types: $e');
    }
  }

  void reset() {
    _hasFetched = false;
    state = const DataState.started();
  }

  void refresh() {
    _hasFetched = false;
    state = const DataState.started();
    fetchBadgeTypes();
  }
}