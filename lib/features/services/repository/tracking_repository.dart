import '../../../common/models/dio/data_state.dart';
import '../models/tracking_model.dart';

abstract class TrackingRepository {
  Future<DataState<List<TrackingItemModel>>> getAllTracking({
    required String mobileUserId,
    String? module,
    String? status,
    String? search,
  });

  Future<DataState<List<ProgramTrackingModel>>> getPrograms({
    required String mobileUserId,
    String? status,
    String? search,
  });

  Future<DataState<List<ServiceTrackingModel>>> getServices({
    required String mobileUserId,
    String? status,
    String? search,
  });

  Future<DataState<List<ComplaintModel>>> getComplaints({
    required String mobileUserId,
    String? status,
    String? search,
  });

  Future<DataState<List<BadgeRequestModel>>> getBadgeRequests({
    required String mobileUserId,
    String? status,
    String? search,
  });

  Future<DataState<bool>> createFeedback({
    required String feedbackableType,
    required int feedbackableId,
    required int rating,
    String? comment,
    bool isAnonymous = false,
  });

  Future<DataState<bool>> updateFeedback({
    required String feedbackId,
    int? rating,
    String? comment,
  });

  Future<DataState<List<PendingFeedbackRequest>>> getPendingFeedbackRequests();
}