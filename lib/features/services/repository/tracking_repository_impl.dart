import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart'; // ADD THIS
import '../../../common/models/dio/data_state.dart';
import '../models/tracking_model.dart';
import '../services/tracking_service.dart';
import 'tracking_repository.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  static const int _pageSize = 50;

  final TrackingService _service;

  TrackingRepositoryImpl({required TrackingService service})
      : _service = service;

  String _extractError(DioException e) =>
      (e.response?.data as Map<String, dynamic>?)?['message'] as String? ??
      e.message ??
      'Network error';

  Future<DataState<List<T>>> _fetchAll<T>({
    required Future<HttpResponse<dynamic>> Function(int page) fetcher,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final all = <T>[];
      int page = 1;
      int totalPages = 1;

      do {
        final res = await fetcher(page);
        final raw = res.data as Map<String, dynamic>;

        if (raw['success'] != true) {
          return DataState.error(
            error: (raw['message'] as String?) ?? 'Request failed',
          );
        }

        final list = raw['data'] as List<dynamic>;
        all.addAll(list.map((e) => fromJson(e as Map<String, dynamic>)));

        final meta =
            PaginationMeta.fromJson(raw['meta'] as Map<String, dynamic>);
        totalPages = meta.totalPages;
        page++;
      } while (page <= totalPages);

      return DataState.success(data: all);
    } on DioException catch (e) {
      return DataState.error(error: _extractError(e));
    } catch (e) {
      return DataState.error(error: 'Unexpected error: $e');
    }
  }

  @override
  Future<DataState<List<TrackingItemModel>>> getAllTracking({
    required String mobileUserId,
    String? module,
    String? status,
    String? search,
  }) =>
      _fetchAll(
        fetcher: (page) => _service.getAllTracking(
          mobileUserId,
          page: page,
          limit: _pageSize,
          module: module,
          status: status,
          search: search,
        ),
        fromJson: TrackingItemModel.fromJson,
      );

  @override
  Future<DataState<List<ProgramTrackingModel>>> getPrograms({
    required String mobileUserId,
    String? status,
    String? search,
  }) =>
      _fetchAll(
        fetcher: (page) => _service.getPrograms(
          mobileUserId,
          page: page,
          limit: _pageSize,
          status: status,
          search: search,
        ),
        fromJson: ProgramTrackingModel.fromJson,
      );

  @override
  Future<DataState<List<ServiceTrackingModel>>> getServices({
    required String mobileUserId,
    String? status,
    String? search,
  }) =>
      _fetchAll(
        fetcher: (page) => _service.getServices(
          mobileUserId,
          page: page,
          limit: _pageSize,
          status: status,
          search: search,
        ),
        fromJson: ServiceTrackingModel.fromJson,
      );

  @override
  Future<DataState<List<ComplaintModel>>> getComplaints({
    required String mobileUserId,
    String? status,
    String? search,
  }) =>
      _fetchAll(
        fetcher: (page) => _service.getComplaints(
          mobileUserId,
          page: page,
          limit: _pageSize,
          status: status,
          search: search,
        ),
        fromJson: ComplaintModel.fromJson,
      );

  @override
  Future<DataState<List<BadgeRequestModel>>> getBadgeRequests({
    required String mobileUserId,
    String? status,
    String? search,
  }) =>
      _fetchAll(
        fetcher: (page) => _service.getBadgeRequests(
          mobileUserId,
          page: page,
          limit: _pageSize,
          status: status,
          search: search,
        ),
        fromJson: BadgeRequestModel.fromJson,
      );

  @override
  Future<DataState<bool>> createFeedback({
    required String feedbackableType,
    required int feedbackableId,
    required int rating,
    String? comment,
    bool isAnonymous = false,
  }) async {
    try {
      final res = await _service.createFeedback({
        'feedbackable_type': feedbackableType,
        'feedbackable_id': feedbackableId,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
        'is_anonymous': isAnonymous,
      });
      final raw = res.data as Map<String, dynamic>;
      if (raw['success'] != true) {
        return DataState.error(
          error: (raw['message'] as String?) ?? 'Failed to submit feedback',
        );
      }
      return const DataState.success(data: true);
    } on DioException catch (e) {
      return DataState.error(error: _extractError(e));
    } catch (e) {
      return DataState.error(error: 'Unexpected error: $e');
    }
  }

  @override
  Future<DataState<bool>> updateFeedback({
    required String feedbackId,
    int? rating,
    String? comment,
  }) async {
    try {
      final res = await _service.updateFeedback(feedbackId, {
        if (rating != null) 'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      });
      final raw = res.data as Map<String, dynamic>;
      if (raw['success'] != true) {
        return DataState.error(
          error: (raw['message'] as String?) ?? 'Failed to update feedback',
        );
      }
      return const DataState.success(data: true);
    } on DioException catch (e) {
      return DataState.error(error: _extractError(e));
    } catch (e) {
      return DataState.error(error: 'Unexpected error: $e');
    }
  }

  @override
  Future<DataState<List<PendingFeedbackRequest>>>
      getPendingFeedbackRequests() async {
    try {
      final res = await _service.getPendingFeedbackRequests();
      final raw = res.data as Map<String, dynamic>;
      if (raw['success'] != true) {
        return DataState.error(
          error: (raw['message'] as String?) ?? 'Failed to fetch pending requests',
        );
      }
      final list = (raw['data'] as List<dynamic>)
          .map((e) =>
              PendingFeedbackRequest.fromJson(e as Map<String, dynamic>))
          .toList();
      return DataState.success(data: list);
    } on DioException catch (e) {
      return DataState.error(error: _extractError(e));
    } catch (e) {
      return DataState.error(error: 'Unexpected error: $e');
    }
  }
}