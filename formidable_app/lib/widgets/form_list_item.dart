import 'package:flutter/material.dart';
import 'package:formidable_app/models/form.dart';
import 'package:formidable_app/screens/create_form_screen.dart';
import 'package:formidable_app/screens/form_response_screen.dart';
import 'package:formidable_app/screens/view_responses_screen.dart';
import 'package:share_plus/share_plus.dart';

class FormListItem extends StatelessWidget {
  final FormModel form;
  final VoidCallback onDelete;

  FormListItem({required this.form, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(form.title),
        subtitle: Text(form.description ?? ''),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              print('Edit form ID: ${form.id}');
              if (form.id != null) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateFormScreen(formId: form.id),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Form ID is not available for editing')),
                );
              }
            } else if (value == 'delete') {
              onDelete();
            } else if (value == 'view_responses') {
              print('View responses form ID: ${form.id}');
              if (form.id != null) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewResponsesScreen(formId: form.id!),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Form ID is not available for viewing responses')),
                );
              }
            } else if (value == 'share') {
              if (form.shareableId != null) {
                String shareableLink = 'http://localhost:3000/form/share/${form.shareableId}';
                Share.share(shareableLink);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Shareable ID is not available for this form')),
                );
              }
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
            PopupMenuItem(
              value: 'view_responses',
              child: Text('View Responses'),
            ),
            PopupMenuItem(
              value: 'share',
              child: Text('Share'),
            ),
          ],
        ),
        onTap: () {
          print('FormListItem onTap called');
          print('Form ID: ${form.id}');
          if (form.id != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FormResponseScreen(formId: form.id!),
              ),
            );
          } else {
            print('Error: Form ID is null in onTap');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Form ID is not available yet.')),
            );
          }
        },
      ),
    );
  }
}