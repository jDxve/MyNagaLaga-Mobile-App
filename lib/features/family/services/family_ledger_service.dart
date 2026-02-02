import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import '../../../common/models/dio/api_client.dart';

part 'family_ledger_service.g.dart';

final familyLedgerServiceProvider = Provider.autoDispose<FamilyLedgerService>((ref) {
  final dio = ApiClient.fromEnv().create();
  return FamilyLedgerService(dio);
});

@RestApi()
abstract class FamilyLedgerService {
  factory FamilyLedgerService(Dio dio, {String? baseUrl}) = _FamilyLedgerService;

  // Get user's household ledger
  @GET('/family-ledger/my-ledger')  // ✅ Changed from /households
  Future<HttpResponse<dynamic>> getMyHousehold();

  // Get household by ID
  @GET('/family-ledger/{id}')  // ✅ Changed from /households
  Future<HttpResponse<dynamic>> getHouseholdById(@Path('id') String id);

  // Create household
  @POST('/family-ledger')  // ✅ Changed from /households
  Future<HttpResponse<dynamic>> createHousehold(@Body() Map<String, dynamic> data);

  // Update household
  @PATCH('/family-ledger/{id}')  // ✅ Changed from /households
  Future<HttpResponse<dynamic>> updateHousehold(
    @Path('id') String id,
    @Body() Map<String, dynamic> data,
  );

  // Delete household
  @DELETE('/family-ledger/{id}')  // ✅ Changed from /households
  Future<HttpResponse<dynamic>> deleteHousehold(@Path('id') String id);

  // Add household member
  @POST('/family-ledger/{householdId}/members')  // ✅ Changed from /households
  Future<HttpResponse<dynamic>> addHouseholdMember(
    @Path('householdId') String householdId,
    @Body() Map<String, dynamic> data,
  );

  // Update household member
  @PATCH('/family-ledger/members/{memberId}')  // ✅ Changed from /households
  Future<HttpResponse<dynamic>> updateHouseholdMember(
    @Path('memberId') String memberId,
    @Body() Map<String, dynamic> data,
  );

  // Remove household member
  @DELETE('/family-ledger/members/{memberId}')  // ✅ Changed from /households
  Future<HttpResponse<dynamic>> removeHouseholdMember(@Path('memberId') String memberId);

  // Decamp member
  @POST('/family-ledger/members/{memberId}/decamp')  // ✅ Changed from /households
  Future<HttpResponse<dynamic>> decampMember(
    @Path('memberId') String memberId,
    @Body() Map<String, dynamic> data,
  );

  // Get barangays
  @GET('/family-ledger/barangays/list')  // ✅ Changed from /households
  Future<HttpResponse<dynamic>> getBarangays();

  // Get link requests
  @GET('/family-ledger/link-requests')  // ✅ Changed from /households
  Future<HttpResponse<dynamic>> getLinkRequests({
    @Query('page') String? page,
    @Query('limit') String? limit,
    @Query('status') String? status,
  });

  // Request to link to household
  @POST('/family-ledger/link-requests')  // ✅ Changed from /households
  Future<HttpResponse<dynamic>> requestLink(@Body() Map<String, dynamic> data);

  // Approve link request
  @POST('/family-ledger/link-requests/{requestId}/approve')  // ✅ Changed from /households
  Future<HttpResponse<dynamic>> approveLinkRequest(
    @Path('requestId') String requestId,
    @Body() Map<String, dynamic> data,
  );

  // Reject link request
  @POST('/family-ledger/link-requests/{requestId}/reject')  // ✅ Changed from /households
  Future<HttpResponse<dynamic>> rejectLinkRequest(
    @Path('requestId') String requestId,
    @Body() Map<String, dynamic> data,
  );
}