import 'package:flutter/material.dart';
import 'package:formidable_app/models/form.dart';
import 'package:formidable_app/models/question.dart';
import 'package:formidable_app/models/response.dart';
import 'package:formidable_app/services/form_service.dart';
import 'package:formidable_app/services/response_service.dart';
import 'package:formidable_app/widgets/question_response_widget.dart';

class FormResponseScreen extends StatefulWidget {
  final String formId;

  FormResponseScreen({required this.formId});

  @override
  _FormResponseScreenState createState() => _FormResponseScreenState();
}

class _FormResponseScreenState extends State<FormResponseScreen> {
  final FormService _formService = FormService();
  final ResponseService _responseService = ResponseService();
  final _formKey = GlobalKey<FormState>();
  late FormModel _form;
  bool _isLoading = true;
  List<Answer> _answers = [];

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  _loadForm() async {
    try {
      _form = await _formService.getFormById(widget.formId);
      _answers = _form.questions.map((q) => Answer(questionId: q.title, value: null)).toList();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading form: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading form')));
    }
  }

  _updateAnswer(int index, dynamic value) {
    _answers[index].value = value;
  }

  _submitResponse() async {
    if (_formKey.currentState!.validate()) {
      final response = ResponseModel(
        formId: widget.formId,
        answers: _answers,
        submittedAt: DateTime.now(),
      );

      try {
        await _responseService.submitResponse(response);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Response submitted successfully!')));
        Navigator.pop(context);
      } catch (e) {
        print('Error submitting response: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error submitting response')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? 'Loading Form' : _form.title),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: _form.questions.length + 1,
          itemBuilder: (context, index) {
            if (index < _form.questions.length) {
              final question = _form.questions[index];
              return QuestionResponseWidget(
                question: question,
                onChanged: (value) => _updateAnswer(index, value),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: _submitResponse,
                  child: Text('Submit'),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}