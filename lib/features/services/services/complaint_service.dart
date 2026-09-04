import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mynagalaga_mobile_app/core/network/dio_factory.dart';

part 'complaint_service.g.dart';

final complaintServiceProvider = Provider.autoDispose<ComplaintService>((ref) {
  return ComplaintService(ref.watch(dioProvider));
});

@RestApi()
abstract class ComplaintService {
  factory ComplaintService(Dio dio, {String? baseUrl}) = _ComplaintService;

  @GET('/complaints/types')
  Future<HttpResponse<dynamic>> getComplaintTypes();

  @POST('/complaints/mobile')
  Future<HttpResponse<dynamic>> submitComplaint(@Body() FormData formData);
}