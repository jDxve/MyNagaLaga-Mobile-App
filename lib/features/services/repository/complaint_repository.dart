import 'package:mynagalaga_mobile_app/core/network/data_state.dart';
import 'package:mynagalaga_mobile_app/features/services/models/complaint_model.dart';

abstract class ComplaintRepository {
  Future<DataState<List<ComplaintTypeModel>>> getComplaintTypes();
  Future<DataState<ComplaintResponseModel>> submitComplaint(ComplaintModel complaint);
}