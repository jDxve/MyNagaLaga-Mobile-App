// posting_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mynagalaga_mobile_app/core/network/dio_factory.dart';

part 'posting_service.g.dart';

final postingServiceProvider = Provider.autoDispose<PostingService>((ref) {
  final dio = ref.watch(dioProvider);
  return PostingService(dio);
});

@RestApi()
abstract class PostingService {
  factory PostingService(Dio dio, {String? baseUrl}) = _PostingService;

  @GET('/welfare-programs/postings/{id}')
  Future<HttpResponse<dynamic>> getPosting(@Path('id') String id);
}