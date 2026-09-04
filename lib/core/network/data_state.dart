import 'package:freezed_annotation/freezed_annotation.dart';

part 'data_state.freezed.dart';

@freezed
class DataState<T> with _$DataState<T> {
  const factory DataState.started() = Started<T>;
  const factory DataState.loading() = Loading<T>;
  const factory DataState.success({required T data}) = Success<T>;
  const factory DataState.error({String? error}) = Error<T>;
}