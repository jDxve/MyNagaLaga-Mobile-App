import '../../../common/models/dio/data_state.dart';
import '../models/tracking_model.dart';

abstract class TrackingRepository {
  Future<DataState<TrackingResponseModel>> getAllTracking({
    required String mobileUserId,
    int page = 1,
    int limit = 20,
    String? module,
    String? status,
    String? search,
  });

  Future<DataState<ApplicationsResponseModel>> getApplications({
    required String mobileUserId,
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  });

  Future<DataState<ProgramsTrackingResponseModel>> getPrograms({
    required String mobileUserId,
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  });

  Future<DataState<ServicesTrackingResponseModel>> getServices({
    required String mobileUserId,
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  });

  Future<DataState<TrackingResponseModel>> getCases({
    required String mobileUserId,
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  });

  Future<DataState<ComplaintsResponseModel>> getComplaints({
    required String mobileUserId,
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  });

  Future<DataState<BadgeRequestsResponseModel>> getBadgeRequests({
    required String mobileUserId,
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  });
}