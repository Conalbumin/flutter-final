import 'package:flutter/material.dart';
import 'package:quizlet_final_flutter/study/firebase_study_page.dart';

class EditTopicPage extends StatefulWidget {
  final String topicId;
  final String initialTopicName;
  final String initialDescription;

  const EditTopicPage({
    Key? key,
    required this.initialTopicName,
    required this.initialDescription, required this.topicId,
  }) : super(key: key);

  @override
  _EditTopicPageState createState() => _EditTopicPageState();
}

class _EditTopicPageState extends State<EditTopicPage> {
  final _formKey = GlobalKey<FormState>();
  late String topicId; // Initialize topicId here

  late String _topicName;
  late String _description;

  @override
  void initState() {
    super.initState();
    _topicName = widget.initialTopicName;
    _description = widget.initialDescription;
    topicId = widget.topicId; // Assign the value from the constructor to topicId here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Create New Topic',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white, size: 40),
            onPressed: () {
              _submitForm();
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _topicName,
                decoration: InputDecoration(labelText: 'Topic Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a topic name';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _topicName = value;
                  });
                },
                // onSaved: (value) => _topicName = value!, // Remove this line
              ),

              SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) => _description = value!,
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      updateTopicInFirestore(topicId, _topicName, _description); // Assuming you have access to topicId in EditTopicPage
      Navigator.pop(context);
    }
  }

}
