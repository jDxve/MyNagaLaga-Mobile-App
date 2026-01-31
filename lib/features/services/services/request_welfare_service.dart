// request_welfare_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import '../../../common/models/dio/api_client.dart';

part 'request_welfare_service.g.dart';

final requestWelfareServiceProvider = Provider.autoDispose<RequestWelfareService>((ref) {
  final dio = ApiClient.fromEnv().create();
  return RequestWelfareService(dio);
});

@RestApi()
abstract class RequestWelfareService {
  factory RequestWelfareService(Dio dio, {String? baseUrl}) = _RequestWelfareService;

  @POST('/welfare-programs/mobile/postings/{postingId}/requests')
  Future<HttpResponse<dynamic>> submitServiceRequest(
    @Path('postingId') String postingId,
    @Body() FormData formData,
  );
}