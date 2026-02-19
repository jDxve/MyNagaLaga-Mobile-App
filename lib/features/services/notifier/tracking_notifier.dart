import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/api_client.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/models/dio/polling_service.dart';
import '../models/tracking_model.dart';
import '../repository/tracking_repository.dart';
import '../repository/tracking_repository_impl.dart';
import '../services/tracking_service.dart';

TrackingRepository _buildRepository() {
  final service = TrackingService(ApiClient.fromEnv().create());
  return TrackingRepositoryImpl(service: service);
}

// ─── All Tracking ─────────────────────────────────────────────────────────────

final allTrackingNotifierProvider =
    NotifierProvider<AllTrackingNotifier, DataState<List<TrackingItemModel>>>(
  AllTrackingNotifier.new,
);

class AllTrackingNotifier extends Notifier<DataState<List<TrackingItemModel>>> {
  late final TrackingRepository _repo;
  final _polling = PollingService();

  String? _userId;
  String? _module;
  String? _status;
  String? _search;
  bool _loaded = false;

  @override
  DataState<List<TrackingItemModel>> build() {
    _repo = _buildRepository();
    ref.onDispose(_polling.dispose);
    return const DataState.started();
  }

  Future<void> fetch({
    required String mobileUserId,
    String? module,
    String? status,
    String? search,
    bool silent = false,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _loaded &&
        _userId == mobileUserId &&
        _module == module &&
        _status == status &&
        _search == search &&
        state is Success) return;

    _userId = mobileUserId;
    _module = module;
    _status = status;
    _search = search;

    if (!silent && state is! Success) state = const DataState.loading();

    final result = await _repo.getAllTracking(
      mobileUserId: mobileUserId,
      module: module,
      status: status,
      search: search,
    );

    if (ref.mounted) {
      state = result;
      if (result is Success) _loaded = true;
    }
  }

  void markAsRated({required String itemId, required String module}) {
    final current = state;
    if (current is! Success<List<TrackingItemModel>>) return;
    final updated = current.data.map((item) {
      if (item.id == itemId && item.module == module) {
        return item.copyWith(hasRated: true);
      }
      return item;
    }).toList();
    state = DataState.success(data: updated);
  }

  void startAutoRefresh({Duration interval = const Duration(seconds: 30)}) {
    if (_userId == null) return;
    _polling.startPolling(
      interval: interval,
      onPoll: () => fetch(
        mobileUserId: _userId!,
        module: _module,
        status: _status,
        search: _search,
        silent: true,
        forceRefresh: true,
      ),
    );
  }

  void stopAutoRefresh() => _polling.stopPolling();

  void reset() {
    stopAutoRefresh();
    _loaded = false;
    _userId = null;
    state = const DataState.started();
  }
}

// ─── Programs ─────────────────────────────────────────────────────────────────

final programsTrackingNotifierProvider = NotifierProvider<
    ProgramsTrackingNotifier, DataState<List<ProgramTrackingModel>>>(
  ProgramsTrackingNotifier.new,
);

class ProgramsTrackingNotifier
    extends Notifier<DataState<List<ProgramTrackingModel>>> {
  late final TrackingRepository _repo;
  final _polling = PollingService();

  String? _userId;
  String? _status;
  String? _search;
  bool _loaded = false;

  @override
  DataState<List<ProgramTrackingModel>> build() {
    _repo = _buildRepository();
    ref.onDispose(_polling.dispose);
    return const DataState.started();
  }

  Future<void> fetch({
    required String mobileUserId,
    String? status,
    String? search,
    bool silent = false,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _loaded &&
        _userId == mobileUserId &&
        _status == status &&
        _search == search &&
        state is Success) return;

    _userId = mobileUserId;
    _status = status;
    _search = search;

    if (!silent && state is! Success) state = const DataState.loading();

    final result = await _repo.getPrograms(
      mobileUserId: mobileUserId,
      status: status,
      search: search,
    );

    if (ref.mounted) {
      state = result;
      if (result is Success) _loaded = true;
    }
  }

  void markPostingAsRated({required String postingId}) {
    final current = state;
    if (current is! Success<List<ProgramTrackingModel>>) return;
    final updated = current.data.map((program) {
      final updatedPostings = program.postings.map((p) {
        if (p.postingId == postingId) return p.copyWith(hasRated: true);
        return p;
      }).toList();
      return ProgramTrackingModel(
        program: program.program,
        totalApplications: program.totalApplications,
        byStatus: program.byStatus,
        lastRequestedAt: program.lastRequestedAt,
        postings: updatedPostings,
      );
    }).toList();
    state = DataState.success(data: updated);
  }

  void startAutoRefresh({Duration interval = const Duration(seconds: 30)}) {
    if (_userId == null) return;
    _polling.startPolling(
      interval: interval,
      onPoll: () => fetch(
        mobileUserId: _userId!,
        status: _status,
        search: _search,
        silent: true,
        forceRefresh: true,
      ),
    );
  }

  void stopAutoRefresh() => _polling.stopPolling();

  void reset() {
    stopAutoRefresh();
    _loaded = false;
    _userId = null;
    state = const DataState.started();
  }
}

// ─── Services ─────────────────────────────────────────────────────────────────

final servicesTrackingNotifierProvider = NotifierProvider<
    ServicesTrackingNotifier, DataState<List<ServiceTrackingModel>>>(
  ServicesTrackingNotifier.new,
);

class ServicesTrackingNotifier
    extends Notifier<DataState<List<ServiceTrackingModel>>> {
  late final TrackingRepository _repo;
  final _polling = PollingService();

  String? _userId;
  String? _status;
  String? _search;
  bool _loaded = false;

  @override
  DataState<List<ServiceTrackingModel>> build() {
    _repo = _buildRepository();
    ref.onDispose(_polling.dispose);
    return const DataState.started();
  }

  Future<void> fetch({
    required String mobileUserId,
    String? status,
    String? search,
    bool silent = false,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _loaded &&
        _userId == mobileUserId &&
        _status == status &&
        _search == search &&
        state is Success) return;

    _userId = mobileUserId;
    _status = status;
    _search = search;

    if (!silent && state is! Success) state = const DataState.loading();

    final result = await _repo.getServices(
      mobileUserId: mobileUserId,
      status: status,
      search: search,
    );

    if (ref.mounted) {
      state = result;
      if (result is Success) _loaded = true;
    }
  }

  void markPostingAsRated({required String postingId}) {
    final current = state;
    if (current is! Success<List<ServiceTrackingModel>>) return;
    final updated = current.data.map((service) {
      final updatedPostings = service.postings.map((p) {
        if (p.postingId == postingId) return p.copyWith(hasRated: true);
        return p;
      }).toList();
      return ServiceTrackingModel(
        service: service.service,
        program: service.program,
        totalApplications: service.totalApplications,
        byStatus: service.byStatus,
        lastRequestedAt: service.lastRequestedAt,
        postings: updatedPostings,
      );
    }).toList();
    state = DataState.success(data: updated);
  }

  void startAutoRefresh({Duration interval = const Duration(seconds: 30)}) {
    if (_userId == null) return;
    _polling.startPolling(
      interval: interval,
      onPoll: () => fetch(
        mobileUserId: _userId!,
        status: _status,
        search: _search,
        silent: true,
        forceRefresh: true,
      ),
    );
  }

  void stopAutoRefresh() => _polling.stopPolling();

  void reset() {
    stopAutoRefresh();
    _loaded = false;
    _userId = null;
    state = const DataState.started();
  }
}

// ─── Complaints ───────────────────────────────────────────────────────────────

final complaintsTrackingNotifierProvider = NotifierProvider<
    ComplaintsTrackingNotifier, DataState<List<ComplaintModel>>>(
  ComplaintsTrackingNotifier.new,
);

class ComplaintsTrackingNotifier
    extends Notifier<DataState<List<ComplaintModel>>> {
  late final TrackingRepository _repo;
  final _polling = PollingService();

  String? _userId;
  String? _status;
  String? _search;
  bool _loaded = false;

  @override
  DataState<List<ComplaintModel>> build() {
    _repo = _buildRepository();
    ref.onDispose(_polling.dispose);
    return const DataState.started();
  }

  Future<void> fetch({
    required String mobileUserId,
    String? status,
    String? search,
    bool silent = false,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _loaded &&
        _userId == mobileUserId &&
        _status == status &&
        _search == search &&
        state is Success) return;

    _userId = mobileUserId;
    _status = status;
    _search = search;

    if (!silent && state is! Success) state = const DataState.loading();

    final result = await _repo.getComplaints(
      mobileUserId: mobileUserId,
      status: status,
      search: search,
    );

    if (ref.mounted) {
      state = result;
      if (result is Success) _loaded = true;
    }
  }

  void markAsRated({required String id}) {
    final current = state;
    if (current is! Success<List<ComplaintModel>>) return;
    final updated = current.data
        .map((c) => c.id == id ? c.copyWith(hasRated: true) : c)
        .toList();
    state = DataState.success(data: updated);
  }

  void startAutoRefresh({Duration interval = const Duration(seconds: 30)}) {
    if (_userId == null) return;
    _polling.startPolling(
      interval: interval,
      onPoll: () => fetch(
        mobileUserId: _userId!,
        status: _status,
        search: _search,
        silent: true,
        forceRefresh: true,
      ),
    );
  }

  void stopAutoRefresh() => _polling.stopPolling();

  void reset() {
    stopAutoRefresh();
    _loaded = false;
    _userId = null;
    state = const DataState.started();
  }
}

// ─── Badge Requests ───────────────────────────────────────────────────────────

final badgeTrackingNotifierProvider = NotifierProvider<
    BadgeTrackingNotifier, DataState<List<BadgeRequestModel>>>(
  BadgeTrackingNotifier.new,
);

class BadgeTrackingNotifier
    extends Notifier<DataState<List<BadgeRequestModel>>> {
  late final TrackingRepository _repo;
  final _polling = PollingService();

  String? _userId;
  String? _status;
  String? _search;
  bool _loaded = false;

  @override
  DataState<List<BadgeRequestModel>> build() {
    _repo = _buildRepository();
    ref.onDispose(_polling.dispose);
    return const DataState.started();
  }

  Future<void> fetch({
    required String mobileUserId,
    String? status,
    String? search,
    bool silent = false,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _loaded &&
        _userId == mobileUserId &&
        _status == status &&
        _search == search &&
        state is Success) return;

    _userId = mobileUserId;
    _status = status;
    _search = search;

    if (!silent && state is! Success) state = const DataState.loading();

    final result = await _repo.getBadgeRequests(
      mobileUserId: mobileUserId,
      status: status,
      search: search,
    );

    if (ref.mounted) {
      state = result;
      if (result is Success) _loaded = true;
    }
  }

  void markAsRated({required String id}) {
    final current = state;
    if (current is! Success<List<BadgeRequestModel>>) return;
    final updated = current.data
        .map((b) => b.id == id ? b.copyWith(hasRated: true) : b)
        .toList();
    state = DataState.success(data: updated);
  }

  void startAutoRefresh({Duration interval = const Duration(seconds: 30)}) {
    if (_userId == null) return;
    _polling.startPolling(
      interval: interval,
      onPoll: () => fetch(
        mobileUserId: _userId!,
        status: _status,
        search: _search,
        silent: true,
        forceRefresh: true,
      ),
    );
  }

  void stopAutoRefresh() => _polling.stopPolling();

  void reset() {
    stopAutoRefresh();
    _loaded = false;
    _userId = null;
    state = const DataState.started();
  }
}

// ─── Pending Feedback ─────────────────────────────────────────────────────────

final pendingFeedbackNotifierProvider = NotifierProvider<
    PendingFeedbackNotifier, DataState<List<PendingFeedbackRequest>>>(
  PendingFeedbackNotifier.new,
);

class PendingFeedbackNotifier
    extends Notifier<DataState<List<PendingFeedbackRequest>>> {
  late final TrackingRepository _repo;

  @override
  DataState<List<PendingFeedbackRequest>> build() {
    _repo = _buildRepository();
    return const DataState.started();
  }

  Future<void> fetch() async {
    if (state is! Started) return;
    state = const DataState.loading();
    final result = await _repo.getPendingFeedbackRequests();
    if (ref.mounted) state = result;
  }

  Future<void> invalidate() async {
    state = const DataState.started();
    await fetch();
  }
}

// ─── Feedback Submit ──────────────────────────────────────────────────────────

class FeedbackSubmitState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const FeedbackSubmitState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });
}

final feedbackSubmitNotifierProvider =
    NotifierProvider<FeedbackSubmitNotifier, FeedbackSubmitState>(
  FeedbackSubmitNotifier.new,
);

class FeedbackSubmitNotifier extends Notifier<FeedbackSubmitState> {
  late final TrackingRepository _repo;

  @override
  FeedbackSubmitState build() {
    _repo = _buildRepository();
    return const FeedbackSubmitState();
  }

  Future<void> submit({
    required String feedbackableType,
    required int feedbackableId,
    required int rating,
    String? comment,
    bool isAnonymous = false,
    String? postingId,
    String? complaintId,
    String? badgeId,
    String? allItemId,
    String? allItemModule,
  }) async {
    state = const FeedbackSubmitState(isLoading: true);

    final result = await _repo.createFeedback(
      feedbackableType: feedbackableType,
      feedbackableId: feedbackableId,
      rating: rating,
      comment: comment,
      isAnonymous: isAnonymous,
    );

    if (!ref.mounted) return;

    if (result is Success) {
      state = const FeedbackSubmitState(isSuccess: true);
      ref.read(pendingFeedbackNotifierProvider.notifier).invalidate();

      if (postingId != null) {
        ref
            .read(programsTrackingNotifierProvider.notifier)
            .markPostingAsRated(postingId: postingId);
        ref
            .read(servicesTrackingNotifierProvider.notifier)
            .markPostingAsRated(postingId: postingId);
      }
      if (complaintId != null) {
        ref
            .read(complaintsTrackingNotifierProvider.notifier)
            .markAsRated(id: complaintId);
      }
      if (badgeId != null) {
        ref
            .read(badgeTrackingNotifierProvider.notifier)
            .markAsRated(id: badgeId);
      }
      if (allItemId != null && allItemModule != null) {
        ref
            .read(allTrackingNotifierProvider.notifier)
            .markAsRated(itemId: allItemId, module: allItemModule);
      }
    } else if (result is Error) {
      state = FeedbackSubmitState(error: (result as Error).error);
    }
  }

  Future<void> update({
    required String feedbackId,
    int? rating,
    String? comment,
  }) async {
    state = const FeedbackSubmitState(isLoading: true);

    final result = await _repo.updateFeedback(
      feedbackId: feedbackId,
      rating: rating,
      comment: comment,
    );

    if (!ref.mounted) return;

    if (result is Success) {
      state = const FeedbackSubmitState(isSuccess: true);
    } else if (result is Error) {
      state = FeedbackSubmitState(error: (result as Error).error);
    }
  }

  void reset() => state = const FeedbackSubmitState();
}