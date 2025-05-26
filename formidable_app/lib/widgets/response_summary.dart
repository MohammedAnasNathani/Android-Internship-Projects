import 'package:flutter/material.dart';
import 'package:formidable_app/models/form.dart';
import 'package:formidable_app/models/question.dart';
import 'package:formidable_app/models/response.dart';
import 'package:intl/intl.dart';

class ResponseSummary extends StatelessWidget {
  final ResponseModel response;
  final FormModel? form;

  ResponseSummary({required this.response, required this.form});

  String _getQuestionTitle(String questionId) {
    if (form == null) {
      return questionId;
    }

    final question = form!.questions.firstWhere(
          (q) => q.id == questionId,
      orElse: () => Question(type: '', title: questionId, options: [], isRequired: false),
    );

    return question.title;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (response.name != null && response.name!.isNotEmpty)
              Text('Name: ${response.name}'),
            if (response.email != null && response.email!.isNotEmpty)
              Text('Email: ${response.email}'),
            SizedBox(height: 8),
            Text('Response ID: ${response.id}'),
            SizedBox(height: 8),
            Text(
                'Submitted at: ${response.submittedAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(response.submittedAt!.toLocal()) : 'N/A'}'),
            SizedBox(height: 8),
            ...response.answers.map((answer) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Question: ${_getQuestionTitle(answer.questionId)}'),
                  Text('Answer: ${answer.value ?? 'N/A'}'),
                  SizedBox(height: 8),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}