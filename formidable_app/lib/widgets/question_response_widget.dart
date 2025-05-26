import 'package:flutter/material.dart';
import 'package:formidable_app/models/question.dart';
import 'package:intl/intl.dart';

class QuestionResponseWidget extends StatefulWidget {
  final Question question;
  final Function(dynamic) onChanged;

  QuestionResponseWidget({required this.question, required this.onChanged});

  @override
  _QuestionResponseWidgetState createState() => _QuestionResponseWidgetState();
}

class _QuestionResponseWidgetState extends State<QuestionResponseWidget> {
  String? _selectedOption;
  List<String> _selectedOptions = [];
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    switch (widget.question.type) {
      case 'text':
        return TextFormField(
          decoration: InputDecoration(labelText: widget.question.title),
          onChanged: (value) => widget.onChanged(value),
          validator: (value) => widget.question.isRequired && (value == null || value.isEmpty) ? 'This field is required' : null,
        );
      case 'long-text':
        return TextFormField(
          decoration: InputDecoration(labelText: widget.question.title),
          onChanged: (value) => widget.onChanged(value),
          validator: (value) => widget.question.isRequired && (value == null || value.isEmpty) ? 'This field is required' : null,
          maxLines: 3,
        );
      case 'multiple-choice':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.question.title),
            ...widget.question.options!.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: _selectedOption,
                onChanged: (value) {
                  setState(() {
                    _selectedOption = value;
                  });
                  widget.onChanged(value);
                },
              );
            }).toList(),
          ],
        );
      case 'checkboxes':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.question.title),
            ...widget.question.options!.map((option) {
              return CheckboxListTile(
                title: Text(option),
                value: _selectedOptions.contains(option),
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      _selectedOptions.add(option);
                    } else {
                      _selectedOptions.remove(option);
                    }
                  });
                  widget.onChanged(_selectedOptions);
                },
              );
            }).toList(),
          ],
        );
      case 'dropdown':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.question.title),
            DropdownButtonFormField<String>(
              value: _selectedOption,
              items: widget.question.options!.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedOption = value;
                });
                widget.onChanged(value);
              },
            ),
          ],
        );
      case 'date':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.question.title),
            ElevatedButton(
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                  widget.onChanged(DateFormat('yyyy-MM-dd').format(_selectedDate!));
                }
              },
              child: Text(_selectedDate == null ? 'Select Date' : '${_selectedDate!.toLocal()}'.split(' ')[0]),
            ),
          ],
        );
      case 'time':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.question.title),
            ElevatedButton(
              onPressed: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime ?? TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    _selectedTime = pickedTime;
                  });
                  widget.onChanged(_selectedTime!.format(context));
                }
              },
              child: Text(_selectedTime == null ? 'Select Time' : _selectedTime!.format(context)),
            ),
          ],
        );
      default:
        return Text('Unsupported question type: ${widget.question.type}');
    }
  }
}