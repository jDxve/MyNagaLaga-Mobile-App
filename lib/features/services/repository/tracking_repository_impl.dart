import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../common/models/dio/data_state.dart';
import '../models/tracking_model.dart';
import '../services/tracking_service.dart';
import 'tracking_repository.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingService _service;

  TrackingRepositoryImpl({required TrackingService service})
      : _service = service;

  @override
  Future<DataState<TrackingResponseModel>> getAllTracking({
    required String mobileUserId,
    int page = 1,
    int limit = 20,
    String? module,
    String? status,
    String? search,
  }) async {
    try {
      debugPrint('📤 Fetching all tracking for user: $mobileUserId');
      debugPrint('   Page: $page, Limit: $limit');
      debugPrint('   Module: $module, Status: $status, Search: $search');

      final response = await _service.getAllTracking(
        mobileUserId,
        page: page,
        limit: limit,
        module: module,
        status: status,
        search: search,
      );

      final raw = response.data;
      debugPrint('📥 Response success: ${raw['success']}');

      if (raw['success'] != true) {
        return DataState.error(
          error: raw['message'] ?? 'Failed to fetch tracking data',
        );
      }

      final trackingResponse = TrackingResponseModel.fromJson(raw);
      debugPrint('✅ Loaded ${trackingResponse.data.length} tracking items');

      return DataState.success(data: trackingResponse);
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.response?.statusCode} - ${e.message}');
      debugPrint('❌ Response data: ${e.response?.data}');
      return DataState.error(
        error: e.response?.data?['message'] ?? 
            e.message ?? 
            'Network error occurred',
      );
    } catch (e) {
      debugPrint('❌ Unexpected Error: $e');
      return DataState.error(error: 'Unexpected error: $e');
    }
  }

  @override
  Future<DataState<ApplicationsResponseModel>> getApplications({
    required String mobileUserId,
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    try {
      debugPrint('📤 Fetching applications for user: $mobileUserId');

      final response = await _service.getApplications(
        mobileUserId,
        page: page,
        limit: limit,
        status: status,
        search: search,
      );

      final raw = response.data;

      if (raw['success'] != true) {
        return DataState.error(
          error: raw['message'] ?? 'Failed to fetch applications',
        );
      }

      final applicationsResponse = ApplicationsResponseModel.fromJson(raw);
      debugPrint('✅ Loaded ${applicationsResponse.data.length} applications');

      return DataState.success(data: applicationsResponse);
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.response?.statusCode} - ${e.message}');
      return DataState.error(
        error: e.response?.data?['message'] ?? 
            e.message ?? 
            'Network error occurred',
      );
    } catch (e) {
      debugPrint('❌ Unexpected Error: $e');
      return DataState.error(error: 'Unexpected error: $e');
    }
  }

  @override
  Future<DataState<ProgramsTrackingResponseModel>> getPrograms({
    required String mobileUserId,
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    try {
      debugPrint('📤 Fetching programs for user: $mobileUserId');

      final response = await _service.getPrograms(
        mobileUserId,
        page: page,
        limit: limit,
        status: status,
        search: search,
      );

      final raw = response.data;

      if (raw['success'] != true) {
        return DataState.error(
          error: raw['message'] ?? 'Failed to fetch programs',
        );
      }

      final programsResponse = ProgramsTrackingResponseModel.fromJson(raw);
      debugPrint('✅ Loaded ${programsResponse.data.length} programs');

      return DataState.success(data: programsResponse);
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.response?.statusCode} - ${e.message}');
      return DataState.error(
        error: e.response?.data?['message'] ?? 
            e.message ?? 
            'Network error occurred',
      );
    } catch (e) {
      debugPrint('❌ Unexpected Error: $e');
      return DataState.error(error: 'Unexpected error: $e');
    }
  }

  @override
  Future<DataState<ServicesTrackingResponseModel>> getServices({
    required String mobileUserId,
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    try {
      debugPrint('📤 Fetching services for user: $mobileUserId');

      final response = await _service.getServices(
        mobileUserId,
        page: page,
        limit: limit,
        status: status,
        search: search,
      );

      final raw = response.data;

      if (raw['success'] != true) {
        return DataState.error(
          error: raw['message'] ?? 'Failed to fetch services',
        );
      }

      final servicesResponse = ServicesTrackingResponseModel.fromJson(raw);
      debugPrint('✅ Loaded ${servicesResponse.data.length} services');

      return DataState.success(data: servicesResponse);
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.response?.statusCode} - ${e.message}');
      return DataState.error(
        error: e.response?.data?['message'] ?? 
            e.message ?? 
            'Network error occurred',
      );
    } catch (e) {
      debugPrint('❌ Unexpected Error: $e');
      return DataState.error(error: 'Unexpected error: $e');
    }
  }

  @override
  Future<DataState<TrackingResponseModel>> getCases({
    required String mobileUserId,
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    try {
      debugPrint('📤 Fetching cases for user: $mobileUserId');

      final response = await _service.getCases(
        mobileUserId,
        page: page,
        limit: limit,
        status: status,
        search: search,
      );

      final raw = response.data;

      if (raw['success'] != true) {
        return DataState.error(
          error: raw['message'] ?? 'Failed to fetch cases',
        );
      }

      final casesResponse = TrackingResponseModel.fromJson(raw);
      debugPrint('✅ Loaded ${casesResponse.data.length} cases');

      return DataState.success(data: casesResponse);
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.response?.statusCode} - ${e.message}');
      return DataState.error(
        error: e.response?.data?['message'] ?? 
            e.message ?? 
            'Network error occurred',
      );
    } catch (e) {
      debugPrint('❌ Unexpected Error: $e');
      return DataState.error(error: 'Unexpected error: $e');
    }
  }

  @override
  Future<DataState<ComplaintsResponseModel>> getComplaints({
    required String mobileUserId,
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    try {
      debugPrint('📤 Fetching complaints for user: $mobileUserId');

      final response = await _service.getComplaints(
        mobileUserId,
        page: page,
        limit: limit,
        status: status,
        search: search,
      );

      final raw = response.data;

      if (raw['success'] != true) {
        return DataState.error(
          error: raw['message'] ?? 'Failed to fetch complaints',
        );
      }

      final complaintsResponse = ComplaintsResponseModel.fromJson(raw);
      debugPrint('✅ Loaded ${complaintsResponse.data.length} complaints');

      return DataState.success(data: complaintsResponse);
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.response?.statusCode} - ${e.message}');
      return DataState.error(
        error: e.response?.data?['message'] ?? 
            e.message ?? 
            'Network error occurred',
      );
    } catch (e) {
      debugPrint('❌ Unexpected Error: $e');
      return DataState.error(error: 'Unexpected error: $e');
    }
  }

  @override
  Future<DataState<BadgeRequestsResponseModel>> getBadgeRequests({
    required String mobileUserId,
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    try {
      debugPrint('📤 Fetching badge requests for user: $mobileUserId');

      final response = await _service.getBadgeRequests(
        mobileUserId,
        page: page,
        limit: limit,
        status: status,
        search: search,
      );

      final raw = response.data;

      if (raw['success'] != true) {
        return DataState.error(
          error: raw['message'] ?? 'Failed to fetch badge requests',
        );
      }

      final badgeResponse = BadgeRequestsResponseModel.fromJson(raw);
      debugPrint('✅ Loaded ${badgeResponse.data.length} badge requests');

      return DataState.success(data: badgeResponse);
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.response?.statusCode} - ${e.message}');
      return DataState.error(
        error: e.response?.data?['message'] ?? 
            e.message ?? 
            'Network error occurred',
      );
    } catch (e) {
      debugPrint('❌ Unexpected Error: $e');
      return DataState.error(error: 'Unexpected error: $e');
    }
  }
}