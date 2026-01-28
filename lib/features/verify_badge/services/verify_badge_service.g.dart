// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_badge_service.dart';

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main

class _VerifyBadgeService implements VerifyBadgeService {
  _VerifyBadgeService(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<HttpResponse<dynamic>> getBadgeTypes() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<dynamic>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/badge-requests/badge-types',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<dynamic>> createBadgeApplication({
    required String mobileUserId,
    required String badgeTypeId,
    String? submittedByUserProfileId,
    required String fullName,
    required String birthdate,
    required String gender,
    required String homeAddress,
    required String contactNumber,
    String? existingSeniorCitizenId,
    required String typeOfId,
    String? typeOfDisability,
    int? numberOfDependents,
    String? estimatedMonthlyHouseholdIncome,
    String? schoolName,
    String? educationLevel,
    String? yearOrGradeLevel,
    String? schoolIdNumber,
    required MultipartFile frontId,
    required MultipartFile backId,
    MultipartFile? supportingFile,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.fields.add(MapEntry('mobileUserId', mobileUserId));
    _data.fields.add(MapEntry('badgeTypeId', badgeTypeId));
    if (submittedByUserProfileId != null) {
      _data.fields.add(
        MapEntry('submittedByUserProfileId', submittedByUserProfileId),
      );
    }
    _data.fields.add(MapEntry('fullName', fullName));
    _data.fields.add(MapEntry('birthdate', birthdate));
    _data.fields.add(MapEntry('gender', gender));
    _data.fields.add(MapEntry('homeAddress', homeAddress));
    _data.fields.add(MapEntry('contactNumber', contactNumber));
    if (existingSeniorCitizenId != null) {
      _data.fields.add(
        MapEntry('existingSeniorCitizenId', existingSeniorCitizenId),
      );
    }
    _data.fields.add(MapEntry('typeOfId', typeOfId));
    if (typeOfDisability != null) {
      _data.fields.add(MapEntry('typeOfDisability', typeOfDisability));
    }
    if (numberOfDependents != null) {
      _data.fields.add(
        MapEntry('numberOfDependents', numberOfDependents.toString()),
      );
    }
    if (estimatedMonthlyHouseholdIncome != null) {
      _data.fields.add(
        MapEntry(
          'estimatedMonthlyHouseholdIncome',
          estimatedMonthlyHouseholdIncome,
        ),
      );
    }
    if (schoolName != null) {
      _data.fields.add(MapEntry('schoolName', schoolName));
    }
    if (educationLevel != null) {
      _data.fields.add(MapEntry('educationLevel', educationLevel));
    }
    if (yearOrGradeLevel != null) {
      _data.fields.add(MapEntry('yearOrGradeLevel', yearOrGradeLevel));
    }
    if (schoolIdNumber != null) {
      _data.fields.add(MapEntry('schoolIdNumber', schoolIdNumber));
    }
    _data.files.add(MapEntry('front_id', frontId));
    _data.files.add(MapEntry('back_id', backId));
    if (supportingFile != null) {
      _data.files.add(MapEntry('supporting_file', supportingFile));
    }
    final _options = _setStreamType<HttpResponse<dynamic>>(
      Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'multipart/form-data',
          )
          .compose(
            _dio.options,
            '/badge-requests/apply',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch(_options);
    final _value = _result.data;
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}

// dart format on
