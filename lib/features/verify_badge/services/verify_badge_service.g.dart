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
  Future<HttpResponse<EmptyDataResponse>> createBadgeApplication({
    required String residentId,
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
    required File frontId,
    required File backId,
    File? supportingFile,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.fields.add(MapEntry('residentId', residentId));
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
    _data.files.add(
      MapEntry(
        'front_id',
        MultipartFile.fromFileSync(
          frontId.path,
          filename: frontId.path.split(Platform.pathSeparator).last,
        ),
      ),
    );
    _data.files.add(
      MapEntry(
        'back_id',
        MultipartFile.fromFileSync(
          backId.path,
          filename: backId.path.split(Platform.pathSeparator).last,
        ),
      ),
    );
    if (supportingFile != null) {
      _data.files.add(
        MapEntry(
          'supporting_file',
          MultipartFile.fromFileSync(
            supportingFile.path,
            filename: supportingFile.path.split(Platform.pathSeparator).last,
          ),
        ),
      );
    }
    final _options = _setStreamType<HttpResponse<EmptyDataResponse>>(
      Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'multipart/form-data',
          )
          .compose(
            _dio.options,
            '/badge-requests',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late EmptyDataResponse _value;
    try {
      _value = EmptyDataResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
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
