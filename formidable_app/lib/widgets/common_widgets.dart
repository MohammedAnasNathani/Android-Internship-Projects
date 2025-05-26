import 'package:flutter/material.dart';

class QuestionWidget extends StatefulWidget {
  final Map<String, dynamic> question;
  final Function(Map<String, dynamic>) onUpdate;
  final Function onDelete;

  QuestionWidget({required this.question, required this.onUpdate, required this.onDelete});

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.question['title']);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  _updateTitle(String newTitle) {
    widget.question['title'] = newTitle;
    widget.onUpdate(widget.question);
  }

  _addOption() {
    setState(() {
      widget.question['options'].add('New Option');
    });
    widget.onUpdate(widget.question);
  }

  _updateOption(int index, String value) {
    widget.question['options'][index] = value;
    widget.onUpdate(widget.question);
  }

  _deleteOption(int index) {
    setState(() {
      widget.question['options'].removeAt(index);
    });
    widget.onUpdate(widget.question);
  }

  _toggleRequired(bool value) {
    setState(() {
      widget.question['isRequired'] = value;
    });
    widget.onUpdate(widget.question);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.question['type']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => widget.onDelete(),
                ),
              ],
            ),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Question Title'),
              onChanged: _updateTitle,
            ),
            if (widget.question['type'] == 'multiple-choice' ||
                widget.question['type'] == 'checkboxes' ||
                widget.question['type'] == 'dropdown')
              ...widget.question['options'].asMap().entries.map((entry) {
                int index = entry.key;
                String option = entry.value;
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: option,
                        decoration: InputDecoration(labelText: 'Option ${index + 1}'),
                        onChanged: (value) => _updateOption(index, value),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: () => _deleteOption(index),
                    ),
                  ],
                );
              }).toList(),
            if (widget.question['type'] == 'multiple-choice' ||
                widget.question['type'] == 'checkboxes' ||
                widget.question['type'] == 'dropdown')
              TextButton.icon(
                onPressed: _addOption,
                icon: Icon(Icons.add),
                label: Text('Add Option'),
              ),
            Row(
              children: [
                Checkbox(
                  value: widget.question['isRequired'],
                  onChanged: (value) => _toggleRequired(value!),
                ),
                Text('Required'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}