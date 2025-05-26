import 'package:formidable_app/models/response.dart';
import 'package:formidable_app/services/api_service.dart';

class ResponseService {
  final ApiService _apiService = ApiService();

  Future<void> submitResponse(ResponseModel response) async {
    await _apiService.post('responses', response.toJson());
  }

  Future<List<ResponseModel>> getResponsesForForm(String formId) async {
    print('getResponsesForForm called with formId: $formId');
    final data = await _apiService.get('responses/form/$formId');
    print('getResponsesForForm response data: $data');

    if (data is List) {
      return data.map((responseJson) {
        print('Parsing response: $responseJson');
        try {
          return ResponseModel.fromJson(responseJson);
        } catch (e) {
          print('Error parsing response: $e');
          return ResponseModel(formId: '', answers: []);
        }
      }).toList();
    } else {
      print('Error: getResponsesForForm response data is not a List');
      return [];
    }
  }
}