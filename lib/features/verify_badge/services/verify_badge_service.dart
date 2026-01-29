import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import '../../../common/models/dio/api_client.dart';

part 'verify_badge_service.g.dart';

final verifyBadgeServiceProvider = Provider.autoDispose<VerifyBadgeService>((ref) {
  final apiClient = ApiClient.fromEnv();
  final dio = apiClient.create();
  return VerifyBadgeService(dio);
});

@RestApi()
abstract class VerifyBadgeService {
  factory VerifyBadgeService(Dio dio, {String? baseUrl}) = _VerifyBadgeService;

  @GET('/badge-requests/badge-types')
  Future<HttpResponse> getBadgeTypes();

  @POST('/badge-requests/apply')
  @MultiPart()
  Future<HttpResponse> createBadgeApplication({
    @Part(name: 'mobileUserId') required String mobileUserId,
    @Part(name: 'badgeTypeId') required String badgeTypeId,
    @Part(name: 'submittedByUserProfileId') String? submittedByUserProfileId,
    @Part(name: 'fullName') required String fullName,
    @Part(name: 'birthdate') required String birthdate,
    @Part(name: 'gender') required String gender,
    @Part(name: 'homeAddress') required String homeAddress,
    @Part(name: 'contactNumber') required String contactNumber,
    @Part(name: 'existingSeniorCitizenId') String? existingSeniorCitizenId,
    @Part(name: 'typeOfId') required String typeOfId,
    @Part(name: 'typeOfDisability') String? typeOfDisability,
    @Part(name: 'numberOfDependents') int? numberOfDependents,
    @Part(name: 'estimatedMonthlyHouseholdIncome') String? estimatedMonthlyHouseholdIncome,
    @Part(name: 'schoolName') String? schoolName,
    @Part(name: 'educationLevel') String? educationLevel,
    @Part(name: 'yearOrGradeLevel') String? yearOrGradeLevel,
    @Part(name: 'schoolIdNumber') String? schoolIdNumber,
    @Part(name: 'front_id') required MultipartFile frontId,
    @Part(name: 'back_id') required MultipartFile backId,
    @Part(name: 'supporting_file') MultipartFile? supportingFile,
  });
}