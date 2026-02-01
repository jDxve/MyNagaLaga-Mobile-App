import 'dart:async';
import 'package:flutter/foundation.dart';

class PollingService {
  Timer? _timer;
  bool _isPolling = false;

  void startPolling({
    required Duration interval,
    required Future<void> Function() onPoll,
  }) {
    if (_isPolling) {
      debugPrint('⏱️ Polling already running');
      return;
    }

    debugPrint('▶️ Starting polling with interval: ${interval.inSeconds}s');
    _isPolling = true;

    _timer = Timer.periodic(interval, (timer) async {
      try {
        await onPoll();
      } catch (e) {
        debugPrint('❌ Polling error: $e');
      }
    });
  }

  void stopPolling() {
    if (_timer != null && _timer!.isActive) {
      debugPrint('⏹️ Stopping polling');
      _timer?.cancel();
      _timer = null;
      _isPolling = false;
    }
  }

  bool get isPolling => _isPolling;

  void dispose() {
    stopPolling();
  }
}