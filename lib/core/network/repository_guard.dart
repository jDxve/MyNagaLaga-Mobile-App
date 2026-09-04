import 'package:dio/dio.dart';

import 'package:mynagalaga_mobile_app/core/network/app_exception.dart';
import 'package:mynagalaga_mobile_app/core/network/data_state.dart';

const _kDefaultErrorMessage = 'Something went wrong. Please try again.';

/// Collapses the repetitive try/catch every repository method needs around
/// its Dio call. Two variants because repositories in this codebase are not
/// homogeneous:
///
/// - `guard` for repositories whose methods return `DataState<T>`.
/// - `guardThrow` for repositories whose methods throw on failure (the
///   caller already has its own try/catch).
///
/// Both accept an optional `mapError` so a repository can preserve
/// call-site-specific copy for particular status codes (e.g. a 409 meaning
/// "email already registered") instead of the generic mapping.
///
/// Some repositories validate the response body after a 200 (e.g. a
/// `{success: false, message: ...}` envelope) and need to surface that
/// specific message rather than a generic fallback. Throw an `AppException`
/// (not a raw `Exception`/`StateError`) from inside the `action` closure for
/// that — `guard`'s catch-all preserves an `AppException`'s message and only
/// falls back to `fallbackMessage` for genuinely unexpected exceptions
/// (a null-check failure, a bad cast), so internal Dart exception text never
/// leaks into the UI.
mixin RepositoryGuard {
  Future<DataState<T>> guard<T>(
    Future<T> Function() action, {
    AppException Function(DioException e)? mapError,
    String fallbackMessage = _kDefaultErrorMessage,
  }) async {
    try {
      return DataState.success(data: await action());
    } on DioException catch (e) {
      final exception =
          mapError?.call(e) ?? AppException.fromDioException(e, fallbackMessage: fallbackMessage);
      return DataState.error(error: exception.toMessage(fallback: fallbackMessage));
    } on AppException catch (e) {
      return DataState.error(error: e.toMessage(fallback: fallbackMessage));
    } catch (_) {
      return DataState.error(error: fallbackMessage);
    }
  }

  Future<T> guardThrow<T>(
    Future<T> Function() action, {
    AppException Function(DioException e)? mapError,
    String fallbackMessage = _kDefaultErrorMessage,
  }) async {
    try {
      return await action();
    } on DioException catch (e) {
      throw mapError?.call(e) ?? AppException.fromDioException(e, fallbackMessage: fallbackMessage);
    }
  }
}
