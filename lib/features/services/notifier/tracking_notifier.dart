import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/dio/api_client.dart';
import '../../../common/models/dio/data_state.dart';
import '../../../common/models/dio/polling_service.dart';
import '../models/tracking_model.dart';
import '../repository/tracking_repository.dart';
import '../repository/tracking_repository_impl.dart';
import '../services/tracking_service.dart';

final allTrackingNotifierProvider =
    NotifierProvider<AllTrackingNotifier, DataState<TrackingResponseModel>>(
  AllTrackingNotifier.new,
);

class AllTrackingNotifier extends Notifier<DataState<TrackingResponseModel>> {
  late final TrackingRepository _repository;
  final PollingService _pollingService = PollingService();
  String? _currentMobileUserId;
  int _currentPage = 1;
  int _currentLimit = 20;
  String? _currentModule;
  String? _currentStatus;
  String? _currentSearch;

  @override
  DataState<TrackingResponseModel> build() {
    final dio = ApiClient.fromEnv().create();
    final service = TrackingService(dio);
    _repository = TrackingRepositoryImpl(service: service);

    ref.onDispose(() {
      _pollingService.dispose();
    });

    return const DataState.started();
  }

  Future<void> fetchAllTracking({
    required String mobileUserId,
    int page = 1,
    int limit = 20,
    String? module,
    String? status,
    String? search,
    bool silent = false,
  }) async {
    _currentMobileUserId = mobileUserId;
    _currentPage = page;
    _currentLimit = limit;
    _currentModule = module;
    _currentStatus = status;
    _currentSearch = search;

    if (!silent) {
      state = const DataState.loading();
    }

    final result = await _repository.getAllTracking(
      mobileUserId: mobileUserId,
      page: page,
      limit: limit,
      module: module,
      status: status,
      search: search,
    );

    if (ref.mounted) {
      state = result;
    }
  }

  void startAutoRefresh({Duration interval = const Duration(seconds: 30)}) {
    if (_currentMobileUserId == null) return;

    _pollingService.startPolling(
      interval: interval,
      onPoll: () async {
        await fetchAllTracking(
          mobileUserId: _currentMobileUserId!,
          page: _currentPage,
          limit: _currentLimit,
          module: _currentModule,
          status: _currentStatus,
          search: _currentSearch,
          silent: true,
        );
      },
    );
  }

  void stopAutoRefresh() {
    _pollingService.stopPolling();
  }

  void reset() {
    stopAutoRefresh();
    state = const DataState.started();
    _currentMobileUserId = null;
  }
}

final badgeTrackingNotifierProvider =
    NotifierProvider<BadgeTrackingNotifier, DataState<BadgeRequestsResponseModel>>(
  BadgeTrackingNotifier.new,
);

class BadgeTrackingNotifier
    extends Notifier<DataState<BadgeRequestsResponseModel>> {
  late final TrackingRepository _repository;
  final PollingService _pollingService = PollingService();
  String? _currentMobileUserId;
  int _currentPage = 1;
  int _currentLimit = 20;
  String? _currentStatus;
  String? _currentSearch;

  @override
  DataState<BadgeRequestsResponseModel> build() {
    final dio = ApiClient.fromEnv().create();
    final service = TrackingService(dio);
    _repository = TrackingRepositoryImpl(service: service);

    ref.onDispose(() {
      _pollingService.dispose();
    });

    return const DataState.started();
  }

  Future<void> fetchBadgeRequests({
    required String mobileUserId,
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
    bool silent = false,
  }) async {
    _currentMobileUserId = mobileUserId;
    _currentPage = page;
    _currentLimit = limit;
    _currentStatus = status;
    _currentSearch = search;

    if (!silent) {
      state = const DataState.loading();
    }

    final result = await _repository.getBadgeRequests(
      mobileUserId: mobileUserId,
      page: page,
      limit: limit,
      status: status,
      search: search,
    );

    if (ref.mounted) {
      state = result;
    }
  }

  void startAutoRefresh({Duration interval = const Duration(seconds: 30)}) {
    if (_currentMobileUserId == null) return;

    _pollingService.startPolling(
      interval: interval,
      onPoll: () async {
        await fetchBadgeRequests(
          mobileUserId: _currentMobileUserId!,
          page: _currentPage,
          limit: _currentLimit,
          status: _currentStatus,
          search: _currentSearch,
          silent: true,
        );
      },
    );
  }

  void stopAutoRefresh() {
    _pollingService.stopPolling();
  }

  void reset() {
    stopAutoRefresh();
    state = const DataState.started();
    _currentMobileUserId = null;
  }
}

final applicationsTrackingNotifierProvider =
    NotifierProvider<ApplicationsTrackingNotifier, DataState<ApplicationsResponseModel>>(
  ApplicationsTrackingNotifier.new,
);

class ApplicationsTrackingNotifier
    extends Notifier<DataState<ApplicationsResponseModel>> {
  late final TrackingRepository _repository;
  final PollingService _pollingService = PollingService();
  String? _currentMobileUserId;
  int _currentPage = 1;
  int _currentLimit = 20;
  String? _currentStatus;
  String? _currentSearch;

  @override
  DataState<ApplicationsResponseModel> build() {
    final dio = ApiClient.fromEnv().create();
    final service = TrackingService(dio);
    _repository = TrackingRepositoryImpl(service: service);

    ref.onDispose(() {
      _pollingService.dispose();
    });

    return const DataState.started();
  }

  Future<void> fetchApplications({
    required String mobileUserId,
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
    bool silent = false,
  }) async {
    _currentMobileUserId = mobileUserId;
    _currentPage = page;
    _currentLimit = limit;
    _currentStatus = status;
    _currentSearch = search;

    if (!silent) {
      state = const DataState.loading();
    }

    final result = await _repository.getApplications(
      mobileUserId: mobileUserId,
      page: page,
      limit: limit,
      status: status,
      search: search,
    );

    if (ref.mounted) {
      state = result;
    }
  }

  void startAutoRefresh({Duration interval = const Duration(seconds: 30)}) {
    if (_currentMobileUserId == null) return;

    _pollingService.startPolling(
      interval: interval,
      onPoll: () async {
        await fetchApplications(
          mobileUserId: _currentMobileUserId!,
          page: _currentPage,
          limit: _currentLimit,
          status: _currentStatus,
          search: _currentSearch,
          silent: true,
        );
      },
    );
  }

  void stopAutoRefresh() {
    _pollingService.stopPolling();
  }

  void reset() {
    stopAutoRefresh();
    state = const DataState.started();
    _currentMobileUserId = null;
  }
}

final programsTrackingNotifierProvider =
    NotifierProvider<ProgramsTrackingNotifier, DataState<ProgramsTrackingResponseModel>>(
  ProgramsTrackingNotifier.new,
);

class ProgramsTrackingNotifier
    extends Notifier<DataState<ProgramsTrackingResponseModel>> {
  late final TrackingRepository _repository;
  final PollingService _pollingService = PollingService();
  String? _currentMobileUserId;
  int _currentPage = 1;
  int _currentLimit = 20;
  String? _currentStatus;
  String? _currentSearch;

  @override
  DataState<ProgramsTrackingResponseModel> build() {
    final dio = ApiClient.fromEnv().create();
    final service = TrackingService(dio);
    _repository = TrackingRepositoryImpl(service: service);

    ref.onDispose(() {
      _pollingService.dispose();
    });

    return const DataState.started();
  }

  Future<void> fetchPrograms({
    required String mobileUserId,
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
    bool silent = false,
  }) async {
    _currentMobileUserId = mobileUserId;
    _currentPage = page;
    _currentLimit = limit;
    _currentStatus = status;
    _currentSearch = search;

    if (!silent) {
      state = const DataState.loading();
    }

    final result = await _repository.getPrograms(
      mobileUserId: mobileUserId,
      page: page,
      limit: limit,
      status: status,
      search: search,
    );

    if (ref.mounted) {
      state = result;
    }
  }

  void startAutoRefresh({Duration interval = const Duration(seconds: 30)}) {
    if (_currentMobileUserId == null) return;

    _pollingService.startPolling(
      interval: interval,
      onPoll: () async {
        await fetchPrograms(
          mobileUserId: _currentMobileUserId!,
          page: _currentPage,
          limit: _currentLimit,
          status: _currentStatus,
          search: _currentSearch,
          silent: true,
        );
      },
    );
  }

  void stopAutoRefresh() {
    _pollingService.stopPolling();
  }

  void reset() {
    stopAutoRefresh();
    state = const DataState.started();
    _currentMobileUserId = null;
  }
}

final servicesTrackingNotifierProvider =
    NotifierProvider<ServicesTrackingNotifier, DataState<ServicesTrackingResponseModel>>(
  ServicesTrackingNotifier.new,
);

class ServicesTrackingNotifier
    extends Notifier<DataState<ServicesTrackingResponseModel>> {
  late final TrackingRepository _repository;
  final PollingService _pollingService = PollingService();
  String? _currentMobileUserId;
  int _currentPage = 1;
  int _currentLimit = 20;
  String? _currentStatus;
  String? _currentSearch;

  @override
  DataState<ServicesTrackingResponseModel> build() {
    final dio = ApiClient.fromEnv().create();
    final service = TrackingService(dio);
    _repository = TrackingRepositoryImpl(service: service);

    ref.onDispose(() {
      _pollingService.dispose();
    });

    return const DataState.started();
  }

  Future<void> fetchServices({
    required String mobileUserId,
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
    bool silent = false,
  }) async {
    _currentMobileUserId = mobileUserId;
    _currentPage = page;
    _currentLimit = limit;
    _currentStatus = status;
    _currentSearch = search;

    if (!silent) {
      state = const DataState.loading();
    }

    final result = await _repository.getServices(
      mobileUserId: mobileUserId,
      page: page,
      limit: limit,
      status: status,
      search: search,
    );

    if (ref.mounted) {
      state = result;
    }
  }

  void startAutoRefresh({Duration interval = const Duration(seconds: 30)}) {
    if (_currentMobileUserId == null) return;

    _pollingService.startPolling(
      interval: interval,
      onPoll: () async {
        await fetchServices(
          mobileUserId: _currentMobileUserId!,
          page: _currentPage,
          limit: _currentLimit,
          status: _currentStatus,
          search: _currentSearch,
          silent: true,
        );
      },
    );
  }

  void stopAutoRefresh() {
    _pollingService.stopPolling();
  }

  void reset() {
    stopAutoRefresh();
    state = const DataState.started();
    _currentMobileUserId = null;
  }
}

final complaintsTrackingNotifierProvider =
    NotifierProvider<ComplaintsTrackingNotifier, DataState<ComplaintsResponseModel>>(
  ComplaintsTrackingNotifier.new,
);

class ComplaintsTrackingNotifier
    extends Notifier<DataState<ComplaintsResponseModel>> {
  late final TrackingRepository _repository;
  final PollingService _pollingService = PollingService();
  String? _currentMobileUserId;
  int _currentPage = 1;
  int _currentLimit = 20;
  String? _currentStatus;
  String? _currentSearch;

  @override
  DataState<ComplaintsResponseModel> build() {
    final dio = ApiClient.fromEnv().create();
    final service = TrackingService(dio);
    _repository = TrackingRepositoryImpl(service: service);

    ref.onDispose(() {
      _pollingService.dispose();
    });

    return const DataState.started();
  }

  Future<void> fetchComplaints({
    required String mobileUserId,
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
    bool silent = false,
  }) async {
    _currentMobileUserId = mobileUserId;
    _currentPage = page;
    _currentLimit = limit;
    _currentStatus = status;
    _currentSearch = search;

    if (!silent) {
      state = const DataState.loading();
    }

    final result = await _repository.getComplaints(
      mobileUserId: mobileUserId,
      page: page,
      limit: limit,
      status: status,
      search: search,
    );

    if (ref.mounted) {
      state = result;
    }
  }

  void startAutoRefresh({Duration interval = const Duration(seconds: 30)}) {
    if (_currentMobileUserId == null) return;

    _pollingService.startPolling(
      interval: interval,
      onPoll: () async {
        await fetchComplaints(
          mobileUserId: _currentMobileUserId!,
          page: _currentPage,
          limit: _currentLimit,
          status: _currentStatus,
          search: _currentSearch,
          silent: true,
        );
      },
    );
  }

  void stopAutoRefresh() {
    _pollingService.stopPolling();
  }

  void reset() {
    stopAutoRefresh();
    state = const DataState.started();
    _currentMobileUserId = null;
  }
}