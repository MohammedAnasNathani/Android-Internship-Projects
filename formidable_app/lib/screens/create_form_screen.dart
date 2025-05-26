import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formidable_app/models/form.dart';
import 'package:formidable_app/models/question.dart';
import 'package:formidable_app/services/form_service.dart';
import 'package:formidable_app/services/socket_service.dart';
import 'package:formidable_app/widgets/question_widget.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class CreateFormScreen extends StatefulWidget {
  final String? formId;

  CreateFormScreen({this.formId});

  @override
  _CreateFormScreenState createState() => _CreateFormScreenState();
}

class _CreateFormScreenState extends State<CreateFormScreen> {
  final FormService _formService = FormService();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  List<Question> _questions = [];
  String? _formId;
  bool _isSaving = false;
  String? _shareableLink;

  @override
  void initState() {
    super.initState();
    _formId = widget.formId;
    if (_formId != null) {
      _loadForm(_formId!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final socketService = Provider.of<SocketService>(context);

    if (_formId != null &&
        socketService.socket != null &&
        !socketService.socket!.connected) {
      socketService.connectSocket();
    }

    socketService.listenToFormUpdates((data) {
      if (mounted) {
        _handleFormUpdate(data);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  _loadForm(String formId) async {
    try {
      final form = await _formService.getFormById(formId);
      setState(() {
        _titleController.text = form.title;
        _descriptionController.text = form.description ?? '';
        _questions = form.questions;
        _shareableLink =
        'http://localhost:3000/form/share/${form.shareableId}';
      });
      Provider.of<SocketService>(context, listen: false).joinForm(formId);
    } catch (e) {
      print('Error loading form: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error loading form')));
    }
  }

  _addQuestion(String type) {
    setState(() {
      _questions.add(Question(
        type: type,
        title: '',
        isRequired: false,
        options: type == 'text' || type == 'long-text' ? null : ['Option 1'],
      ));
    });
    _emitFormUpdate();
  }

  _updateQuestion(int index, Question updatedQuestion) {
    setState(() {
      _questions[index] = updatedQuestion;
    });
    _emitFormUpdate();
  }

  _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
    _emitFormUpdate();
  }

  _emitFormUpdate() {
    if (_formId != null) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      final updatedForm = FormModel(
        id: _formId,
        title: _titleController.text,
        description: _descriptionController.text,
        questions: _questions,
      );
      socketService.emitFormUpdate(
          {'formId': _formId, 'form': updatedForm.toJson()});
    }
  }

  _handleFormUpdate(dynamic data) {
    if (data['formId'] == _formId) {
      final updatedForm = FormModel.fromJson(data['form']);
      if (updatedForm.title != _titleController.text ||
          updatedForm.description != _descriptionController.text) {
        _titleController.text = updatedForm.title;
        _descriptionController.text = updatedForm.description ?? '';
      }
      if (updatedForm.questions.length != _questions.length) {
        _questions = updatedForm.questions;
      } else {
        for (int i = 0; i < _questions.length; i++) {
          if (_questions[i].title != updatedForm.questions[i].title ||
              _questions[i].type != updatedForm.questions[i].type ||
              _questions[i].isRequired != updatedForm.questions[i].isRequired ||
              _questions[i].options.toString() !=
                  updatedForm.questions[i].options.toString()) {
            _questions[i] = updatedForm.questions[i];
          }
        }
      }
      setState(() {});
    }
  }

  _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final formData = FormModel(
        title: _titleController.text,
        description: _descriptionController.text,
        questions: _questions,
      );

      try {
        if (_formId == null) {
          final newForm = await _formService.createForm(formData);
          if (newForm != null && newForm.id != null) {
            setState(() {
              _formId = newForm.id;
              _shareableLink =
              'http://localhost:3000/form/share/${newForm.shareableId}';
              print("Shareable link set to: $_shareableLink");
            });
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Form created successfully!')));
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to create form.')));
          }
        } else {
          formData.id = _formId;
          await _formService.updateForm(_formId!, formData);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Form updated successfully!')));
          Navigator.pop(context);
        }
      } catch (e) {
        print('Error saving form: $e');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error saving form: $e')));
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_formId == null ? 'Create Form' : 'Edit Form'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _saveForm,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Form Title',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
                labelStyle: TextStyle(
                    color: Colors.deepPurple
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
                labelStyle: TextStyle(
                    color: Colors.deepPurple
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ..._questions.asMap().entries.map((entry) {
              int index = entry.key;
              Question question = entry.value;
              return QuestionWidget(
                question: question,
                onUpdate: (updatedQuestion) =>
                    _updateQuestion(index, updatedQuestion),
                onDelete: () => _deleteQuestion(index),
              );
            }).toList(),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              hint: Text('Add Question',style: TextStyle(color: Colors.deepPurple)),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
              ),
              items: [
                'text',
                'long-text',
                'multiple-choice',
                'checkboxes',
                'dropdown',
                'date',
                'time',
                'file-upload',
                'linear-scale',
                'multiple-choice grid',
                'checkbox grid'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) => _addQuestion(value!),
            ),
            if (_shareableLink != null) ...[
              SizedBox(height: 20),
              Text('Shareable Link:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(_shareableLink!),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _shareableLink!))
                          .then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Link copied to clipboard!')),
                        );
                      });
                    },
                    icon: Icon(Icons.copy),
                    label: Text('Copy Link'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    onPressed: () {
                      Share.share(_shareableLink!);
                    },
                    icon: Icon(Icons.share),
                    label: Text('Share'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}