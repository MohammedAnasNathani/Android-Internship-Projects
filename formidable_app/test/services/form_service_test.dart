import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_app/models/form.dart';
import 'package:formidable_app/services/api_service.dart';
import 'package:formidable_app/services/form_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'form_service_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  group('FormService', () {
    late FormService formService;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      formService = FormService();
      formService._apiService = mockApiService;
    });

    test('getForms returns forms on successful response', () async {
      final mockResponse = [
        {'id': '1', 'title': 'Form 1', 'description': 'Description 1', 'questions': []},
        {'id': '2', 'title': 'Form 2', 'description': 'Description 2', 'questions': []}
      ];

      when(mockApiService.get('forms')).thenAnswer((_) async => mockResponse);

      final forms = await formService.getForms();

      expect(forms.length, 2);
      expect(forms[0].title, 'Form 1');
      expect(forms[1].title, 'Form 2');
    });

    test('getForms throws an exception on failed response', () async {
      when(mockApiService.get('forms')).thenThrow(Exception('Failed to load forms'));

      expect(() async => await formService.getForms(), throwsException);
    });

    test('createForm returns a new form on successful response', () async {
      final newForm = FormModel(title: 'New Form', description: 'New Description', questions: []);
      final mockResponse = {'id': '3', 'title': 'New Form', 'description': 'New Description', 'questions': []};

      when(mockApiService.post('forms', any)).thenAnswer((_) async => mockResponse);

      final createdForm = await formService.createForm(newForm);

      expect(createdForm.id, '3');
      expect(createdForm.title, 'New Form');
    });

    test('getFormById returns a form on successful response', () async {
      final mockResponse = {'id': '1', 'title': 'Form 1', 'description': 'Description 1', 'questions': []};

      when(mockApiService.get('forms/1')).thenAnswer((_) async => mockResponse);

      final form = await formService.getFormById('1');

      expect(form.id, '1');
      expect(form.title, 'Form 1');
    });

    test('updateForm returns updated form on successful response', () async {
      final updatedForm = FormModel(id: '1', title: 'Updated Form', description: 'Updated Description', questions: []);
      final mockResponse = {'id': '1', 'title': 'Updated Form', 'description': 'Updated Description', 'questions': []};

      when(mockApiService.patch('forms/1', any)).thenAnswer((_) async => mockResponse);

      final result = await formService.updateForm('1', updatedForm);

      expect(result.title, 'Updated Form');
    });

    test('deleteForm calls delete endpoint', () async {
      when(mockApiService.delete('forms/1')).thenAnswer((_) async => null);

      await formService.deleteForm('1');

      verify(mockApiService.delete('forms/1')).called(1);
    });

  });
}