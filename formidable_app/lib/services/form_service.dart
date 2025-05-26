import 'package:formidable_app/models/form.dart';
import 'package:formidable_app/services/api_service.dart';

class FormService {
  final ApiService _apiService = ApiService();

  Future<List<FormModel>> getForms() async {
    final data = await _apiService.get('forms');
    return (data as List).map((formJson) => FormModel.fromJson(formJson)).toList();
  }

  Future<FormModel> createForm(FormModel form) async {
    final data = await _apiService.post('forms', form.toJson());
    print('createForm response data: $data');
    return FormModel.fromJson(data);
  }

  Future<FormModel> getFormById(String id) async {
    final data = await _apiService.get('forms/$id');
    return FormModel.fromJson(data);
  }

  Future<FormModel> updateForm(String id, FormModel form) async {
    final data = await _apiService.patch('forms/$id', form.toJson());
    return FormModel.fromJson(data);
  }

  Future<void> deleteForm(String id) async {
    await _apiService.delete('forms/$id');
  }
}