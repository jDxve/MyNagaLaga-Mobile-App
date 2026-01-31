import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import '../../../common/models/dio/api_client.dart';

part 'complaint_service.g.dart';

final complaintServiceProvider = Provider.autoDispose<ComplaintService>((ref) {
  final dio = ApiClient.fromEnv().create();
  return ComplaintService(dio);
});

@RestApi()
abstract class ComplaintService {
  factory ComplaintService(Dio dio, {String? baseUrl}) = _ComplaintService;

  @GET('/complaints/types')
  Future<HttpResponse<dynamic>> getComplaintTypes();

  @POST('/complaints')
  Future<HttpResponse<dynamic>> submitComplaint(
    @Body() FormData formData,
  );
}