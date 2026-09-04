import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import '../../../core/network/dio_factory.dart';

part 'request_welfare_service.g.dart';

final requestWelfareServiceProvider = Provider.autoDispose<RequestWelfareService>((ref) {
  final dio = ref.watch(dioProvider);
  return RequestWelfareService(dio);
});

@RestApi()
abstract class RequestWelfareService {
  factory RequestWelfareService(Dio dio, {String? baseUrl}) = _RequestWelfareService;

  @POST('/welfare-programs/mobile/postings/{postingId}/requests')
  Future<HttpResponse<dynamic>> submitApplication({
    @Path('postingId') required String postingId,
    @Body() required FormData data,
  });
}