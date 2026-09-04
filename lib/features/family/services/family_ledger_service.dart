import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import '../../../core/network/dio_factory.dart';

part 'family_ledger_service.g.dart';

final familyLedgerServiceProvider = Provider.autoDispose<FamilyLedgerService>((ref) {
  final dio = ref.watch(dioProvider);
  return FamilyLedgerService(dio);
});

@RestApi()
abstract class FamilyLedgerService {
  factory FamilyLedgerService(Dio dio, {String? baseUrl}) = _FamilyLedgerService;
  
  @GET('/family-ledger/mobile-user/{mobileUserId}/household')
  Future<HttpResponse> getMyHousehold(@Path('mobileUserId') String mobileUserId);
}