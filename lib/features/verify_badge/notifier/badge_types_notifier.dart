import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/badge_type_model.dart';
import '../services/verify_badge_service.dart';

final badgeTypesNotifierProvider =
    NotifierProvider.autoDispose<BadgeTypesNotifier, DataState<List<BadgeType>>>(
  BadgeTypesNotifier.new,
);

class BadgeTypesNotifier extends Notifier<DataState<List<BadgeType>>> {
  @override
  DataState<List<BadgeType>> build() {
    fetchBadgeTypes();
    return const DataState.started();
  }

  Future<void> fetchBadgeTypes() async {
    state = const DataState.loading();
    
    try {
      print('🔍 Fetching badge types...');
      final service = ref.read(verifyBadgeServiceProvider);
      final response = await service.getBadgeTypes();
      
      print('📡 Response status: ${response.response.statusCode}');
      print('📦 Response data: ${response.data}');
      
      if (response.response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as List;
        final badgeTypes = data.map((json) => BadgeType.fromJson(json)).toList();
        print('✅ Loaded ${badgeTypes.length} badge types');
        state = DataState.success(data: badgeTypes);
      } else {
        print('❌ Failed with status: ${response.response.statusCode}');
        state = const DataState.error(error: 'Failed to load badge types');
      }
    } catch (e, stack) {
      print('❌ Error fetching badge types: $e');
      print('❌ Stack trace: $stack');
      state = DataState.error(error: 'Error loading badge types: $e');
    }
  }

  void reset() {
    state = const DataState.started();
  }
}