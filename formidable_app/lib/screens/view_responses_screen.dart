import 'package:flutter/material.dart';
import 'package:formidable_app/models/form.dart';
import 'package:formidable_app/models/response.dart';
import 'package:formidable_app/services/form_service.dart';
import 'package:formidable_app/services/response_service.dart';
import 'package:formidable_app/widgets/response_summary.dart';

class ViewResponsesScreen extends StatefulWidget {
  final String formId;

  ViewResponsesScreen({required this.formId});

  @override
  _ViewResponsesScreenState createState() => _ViewResponsesScreenState();
}

class _ViewResponsesScreenState extends State<ViewResponsesScreen> {
  final ResponseService _responseService = ResponseService();
  final FormService _formService = FormService();
  FormModel? _form;
  List<ResponseModel> _responses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResponses();
  }

  _loadResponses() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _form = await _formService.getFormById(widget.formId);
      _responses = await _responseService.getResponsesForForm(widget.formId);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading responses: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error loading responses')));
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Responses'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _responses.length,
        itemBuilder: (context, index) {
          return ResponseSummary(
            response: _responses[index],
            form: _form,
          );
        },
      ),
    );
  }
}