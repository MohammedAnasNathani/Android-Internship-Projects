import 'package:flutter/material.dart';
import 'package:formidable_app/models/form.dart';
import 'package:formidable_app/screens/create_form_screen.dart';
import 'package:formidable_app/services/form_service.dart';
import 'package:formidable_app/widgets/form_list_item.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FormService _formService = FormService();
  List<FormModel> _forms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchForms();
  }

  _fetchForms() async {
    try {
      final forms = await _formService.getForms();
      setState(() {
        _forms = forms;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching forms: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load forms')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SundarScaleless"),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _forms.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[500]),
            SizedBox(height: 20),
            Text(
              "No forms yet, let's show Sundar how it's done!",
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateFormScreen()),
                ).then((value) {
                  _fetchForms();
                });
              },
              icon: Icon(Icons.add),
              label: Text("Create Your First Form"),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        itemCount: _forms.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FormListItem(
              form: _forms[index],
              onDelete: () async {
                try {
                  if (_forms[index].id != null) {
                    await _formService.deleteForm(_forms[index].id!);
                    _fetchForms();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Form deleted successfully')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Form ID is not available for deletion')),
                    );
                  }
                } catch (e) {
                  print('Error deleting form: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete form')),
                  );
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateFormScreen()),
          ).then((value) {
            _fetchForms();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}